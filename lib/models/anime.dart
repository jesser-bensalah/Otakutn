class Anime {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? synopsis;
  final double rating;
  final int episodeCount;
  final List<String> genres;
  final String status; // Ongoing, Completed, Upcoming
  final String? type; // TV, Movie, OVA, etc.
  final int releaseYear;
  final bool isFavorite;

  Anime({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.rating = 0.0,
    this.episodeCount = 0,
    List<String>? genres,
    this.status = 'Unknown',
    this.type,
    this.releaseYear = 2024,
    this.isFavorite = false,
    this.synopsis,
  }) : genres = genres ?? [];

  // Convertir depuis JSON
  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Titre inconnu',
      description: json['description'] ?? json['synopsis'],
      imageUrl: json['imageUrl'] ?? json['images']?['jpg']?['image_url'],
      rating: (json['score'] ?? json['rating'] ?? 0.0).toDouble(),
      episodeCount: json['episodes'] ?? json['episodeCount'] ?? 0,
      genres: (json['genres'] as List<dynamic>?)?.map((g) => g['name'].toString()).toList() ?? [],
      status: json['status'] ?? 'Unknown',
      type: json['type'],
      releaseYear: json['year'] ?? json['releaseYear'] ?? 2024,
      isFavorite: json['isFavorite'] ?? false,
      synopsis: json['synopsis'] ?? json['description'],
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'rating': rating,
      'episodeCount': episodeCount,
      'genres': genres,
      'status': status,
      'type': type,
      'releaseYear': releaseYear,
      'isFavorite': isFavorite,
    };
  }

  // Copier avec modifications
  Anime copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? rating,
    int? episodeCount,
    List<String>? genres,
    String? status,
    String? type,
    int? releaseYear,
    bool? isFavorite,
  }) {
    return Anime(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      episodeCount: episodeCount ?? this.episodeCount,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      type: type ?? this.type,
      releaseYear: releaseYear ?? this.releaseYear,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}