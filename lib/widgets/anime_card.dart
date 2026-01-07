import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anime.dart';
import '../pages/anime_detail_page.dart';
import '../providers/anime_provider.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onFavoriteToggle;

  const AnimeCard({
    Key? key,
    required this.anime,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        shadowColor: Colors.deepPurple.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => AnimeDetailPage(
                  animeId: anime.id,
                  animeTitle: anime.title ?? 'Unknown Title',
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image with gradient overlay
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Stack(
                    children: [
                      if (anime.imageUrl?.isNotEmpty ?? false)
                        Image.network(
                          anime.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.withOpacity(0.7),
                                  Colors.pink.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: const Icon(Icons.movie_rounded, size: 50, color: Colors.white),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.withOpacity(0.3),
                                    Colors.pink.withOpacity(0.3),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.withOpacity(0.7),
                                Colors.pink.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: const Icon(Icons.movie_rounded, size: 50, color: Colors.white),
                        ),
                      
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      
                      // Rating badge
                      if (anime.rating > 0)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  anime.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Favorite button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            final provider = Provider.of<AnimeProvider>(context, listen: false);
                            provider.toggleFavorite(anime.id);
                            if (onFavoriteToggle != null) {
                              onFavoriteToggle!();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              anime.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: anime.isFavorite ? Colors.red : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Title and info
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title ?? 'Titre inconnu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (anime.episodeCount > 0)
                      Text(
                        '${anime.episodeCount} Episodes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}