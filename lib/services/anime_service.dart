import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/anime.dart';

class AnimeService {
  static const String baseUrl = 'https://api.jikan.moe/v4';
  
  // Rate limiting
  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(seconds: 10);
  static final Random _random = Random();
  
  // Cache for search results
  final Map<String, List<Anime>> _searchCache = {};
  final Map<int, List<Anime>> _pageCache = {};
  
  // get poplar anime with pagination
  Future<List<Anime>> getTopAnimes({int page = 1, int limit = 20}) async {
    // Return cached results if available
    if (_pageCache.containsKey(page)) {
      return _pageCache[page]!;
    }
    
    int attempt = 0;
    Duration delay = _initialDelay;
    
    while (attempt < _maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/top/anime?page=$page&limit=$limit'),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final animes = (data['data'] as List).map((json) => _convertJikanToAnime(json)).toList();
          _pageCache[page] = animes; // Cache the results
          return animes;
        } else if (response.statusCode == 429) {
          // Rate limited - implement exponential backoff with jitter
          await _handleRateLimit(attempt);
          attempt++;
          continue;
        } else {
          throw Exception('Failed to load animes: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          throw Exception('Failed to load animes after $_maxRetries attempts: $e');
        }
        await Future.delayed(delay);
        delay = _getNextDelay(delay);
        attempt++;
      }
    }
    
    throw Exception('Failed to load animes after $_maxRetries attempts');
  }
  
  // search anime with cache and rate limiting
  Future<List<Anime>> searchAnimes(String query, {int page = 1, int limit = 20}) async {
    if (query.isEmpty) return [];
    
    final cacheKey = '${query.toLowerCase()}_$page';
    
    // Return cached results if available
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }
    
    int attempt = 0;
    Duration delay = _initialDelay;
    
    while (attempt < _maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/anime?q=${Uri.encodeQueryComponent(query)}&page=$page&limit=$limit'),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final animes = (data['data'] as List).map((json) => _convertJikanToAnime(json)).toList();
          _searchCache[cacheKey] = animes; // Cache the results
          return animes;
        } else if (response.statusCode == 429) {
          // Rate limited - implement exponential backoff with jitter
          await _handleRateLimit(attempt);
          attempt++;
          continue;
        } else {
          throw Exception('Failed to search animes: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          throw Exception('Failed to search animes after $_maxRetries attempts: $e');
        }
        await Future.delayed(delay);
        delay = _getNextDelay(delay);
        attempt++;
      }
    }
    
    throw Exception('Failed to search animes after $_maxRetries attempts');
  }
  
  // get anime details
  Future<Anime> getAnimeDetails(int animeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anime/$animeId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _convertJikanToAnime(data['data']);
      } else {
        throw Exception('Failed to load anime details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // get current season animes with pagination
  Future<List<Anime>> getCurrentSeasonAnimes({int page = 1, int limit = 20}) async {
    final cacheKey = 'current_season_$page';
    
    // Return cached results if available
    if (_pageCache.containsKey(-page)) { // Using negative keys for season cache
      return _pageCache[-page]!;
    }
    
    int attempt = 0;
    Duration delay = _initialDelay;
    
    while (attempt < _maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/seasons/now?page=$page&limit=$limit'),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final animes = (data['data'] as List).map((json) => _convertJikanToAnime(json)).toList();
          _pageCache[-page] = animes; // Cache the results with negative key
          return animes;
        } else if (response.statusCode == 429) {
          // Rate limited - implement exponential backoff with jitter
          await _handleRateLimit(attempt);
          attempt++;
          continue;
        } else {
          throw Exception('Failed to load current season: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          throw Exception('Failed to load current season after $_maxRetries attempts: $e');
        }
        await Future.delayed(delay);
        delay = _getNextDelay(delay);
        attempt++;
      }
    }
    
    throw Exception('Failed to load current season after $_maxRetries attempts');
  }
  
  // convert jikan json to anime model
  Anime _convertJikanToAnime(Map<String, dynamic> json) {
    return Anime(
      id: json['mal_id'].toString(),
      title: json['title'] ?? json['title_english'] ?? 'Titre inconnu',
      description: _cleanDescription(json['synopsis'] ?? 'Aucune description disponible'),
      imageUrl: json['images']?['jpg']?['image_url'] ?? '',
      rating: (json['score'] ?? 0.0).toDouble(),
      episodeCount: json['episodes'] ?? 0,
      genres: (json['genres'] as List?)?.map((g) => g['name'].toString()).toList() ?? [],
      status: _convertStatus(json['status']),
      releaseYear: json['year'] ?? _getYearFromDate(json['aired']?['from']),
    );
  }
  
  String _cleanDescription(String description) {
    // delete spoilers and clean description
    return description
        .replaceAll('[Written by MAL Rewrite]', '')
        .replaceAll(RegExp(r'\\n'), ' ')
        .trim();
  }
  
  String _convertStatus(String? status) {
    switch (status) {
      case 'Currently Airing': return 'En cours';
      case 'Finished Airing': return 'Terminé';
      case 'Not yet aired': return 'À venir';
      default: return 'Inconnu';
    }
  }
  
  // rate limiting with backoff exponentiel
  Future<void> _handleRateLimit(int attempt) async {
    final delay = Duration(seconds: pow(2, attempt).toInt());
    final jitter = Duration(milliseconds: _random.nextInt(1000));
    await Future.delayed(delay + jitter);
  }
  
  // get next delay with backoff exponentiel and jitter
  Duration _getNextDelay(Duration currentDelay) {
    final nextDelay = currentDelay * 2;
    final jitter = _random.nextInt(1000); // Add up to 1 second of jitter
    return nextDelay + Duration(milliseconds: jitter);
  }
  
  int _getYearFromDate(String? dateString) {
    if (dateString == null) return DateTime.now().year;
    try {
      final date = DateTime.parse(dateString);
      return date.year;
    } catch (e) {
      return DateTime.now().year;
    }
  }
  
  // clear cache if needed
  void clearCache() {
    _searchCache.clear();
    _pageCache.clear();
    if (kDebugMode) {
      print('AnimeService cache cleared');
    }
  }
}