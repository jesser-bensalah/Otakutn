// hedha fih gestion d'états 
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/anime.dart';
import '../services/anime_service.dart';
import '../utils/debouncer.dart';

class AnimeProvider with ChangeNotifier {
  final AnimeService _animeService = AnimeService();
  final Debouncer _searchDebouncer = Debouncer(delay: Duration(milliseconds: 800));
  
  List<Anime> _animes = [];
  List<Anime> _searchResults = [];
  Anime? _selectedAnime;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  String _error = '';
  int _currentPage = 1;
  bool _hasMore = true;
  String _currentSearchQuery = '';
  static const int _itemsPerPage = 20;
  
  // Getters
  List<Anime> get animes => _animes;
  List<Anime> get searchResults => _searchResults;
  Anime? get selectedAnime => _selectedAnime;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  String get error => _error;
  bool get hasMore => _hasMore;
  String get currentSearchQuery => _currentSearchQuery;
  
  // popular anime
  Future<void> loadTopAnimes() async {
    _currentPage = 1;
    _isLoading = true;
    _hasMore = true;
    _error = '';
    notifyListeners();
    
    try {
      final result = await _animeService.getTopAnimes(page: _currentPage);
      _animes = result;
      _hasMore = result.length >= _itemsPerPage;
      _error = '';
    } catch (e) {
      _error = 'Erreur de chargement: $e';
      _animes = [];
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // load more anime ( pagination)
  Future<void> loadMoreAnimes() async {
    if (_isLoadingMore || !_hasMore) return;
    
    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();
    
    try {
      final result = await _animeService.getTopAnimes(page: _currentPage);
      if (result.isNotEmpty) {
        _animes.addAll(result);
        _hasMore = result.length >= _itemsPerPage;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _currentPage--; // Revert page on error
      _hasMore = false;
      _error = 'Erreur lors du chargement supplémentaire: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  // search anime
  void searchAnimes(String query) {
    _currentSearchQuery = query;
    
    _searchDebouncer(() async {
      if (query.isEmpty) {
        _searchResults = [];
        _isSearching = false;
        _currentSearchQuery = '';
        notifyListeners();
        return;
      }
      
      _isLoading = true;
      _isSearching = true;
      _error = '';
      notifyListeners();
    
      try {
        _searchResults = await _animeService.searchAnimes(query);
        _error = '';
      } catch (e) {
        _error = 'Erreur de recherche: $e';
        _searchResults = [];
      } finally {
        _isLoading = false;
        _isSearching = _searchResults.isNotEmpty;
        notifyListeners();
      }
    });
  }
  
  // anime details
  Future<void> loadAnimeDetails(String animeId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      final anime = await _animeService.getAnimeDetails(int.parse(animeId));
      _selectedAnime = anime;
      _error = '';
    } catch (e) {
      _error = 'Erreur de chargement des détails: $e';
      _selectedAnime = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // current season anime
  Future<void> loadCurrentSeasonAnimes() async {
    _currentPage = 1;
    _isLoading = true;
    _hasMore = true;
    _error = '';
    notifyListeners();
    
    try {
      _animes = await _animeService.getCurrentSeasonAnimes(page: _currentPage);
      _hasMore = _animes.length >= _itemsPerPage;
      _error = '';
    } catch (e) {
      _error = 'Erreur de chargement: $e';
      _animes = [];
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
  
  // clear search
  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }
  
  // reset provider state
  void reset() {
    _animes = [];
    _searchResults = [];
    _selectedAnime = null;
    _isLoading = false;
    _isLoadingMore = false;
    _isSearching = false;
    _error = '';
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  } 

  Future<List<Anime>> getAnimeByTitles(List<String> titles) async {
    List<Anime> results = [];
    for (var title in titles) {
      try {
        // Add delay between requests to avoid rate limiting
        await Future.delayed(const Duration(seconds: 1));
        final animeList = await _animeService.searchAnimes(title);
        if (animeList.isNotEmpty) {
          results.add(animeList.first);
        }
      } catch (e) {
        debugPrint('Error fetching anime $title: $e');
        // Add a placeholder if the request fails with all required parameters
        results.add(Anime(
          id: title.hashCode.toString(),
          title: title,
          description: 'Description not available',
          imageUrl: 'https://placehold.co/400x600?text=${Uri.encodeComponent(title)}',          rating: 0.0,
          episodeCount: 0,
          genres: [],
          status: 'Unknown',
          releaseYear: DateTime.now().year,
        ));
      }
    }
    return results;
  }

  // Toggle favorite status of an anime
  void toggleFavorite(String animeId) {
    final index = _animes.indexWhere((anime) => anime.id == animeId);
    if (index != -1) {
      _animes[index] = _animes[index].copyWith(
        isFavorite: !(_animes[index].isFavorite),
      );
      notifyListeners();
    }
    
    // update in search results if it exists there
    final searchIndex = _searchResults.indexWhere((anime) => anime.id == animeId);
    if (searchIndex != -1) {
      _searchResults[searchIndex] = _searchResults[searchIndex].copyWith(
        isFavorite: !(_searchResults[searchIndex].isFavorite),
      );
      notifyListeners();
    }
  }
}