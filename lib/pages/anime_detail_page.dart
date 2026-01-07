import 'package:flutter/material.dart';
import 'package:otakutn/pages/episode_list_page.dart';
import 'package:otakutn/providers/anime_provider.dart';
import 'package:provider/provider.dart';
import '../models/anime.dart';

class AnimeDetailPage extends StatelessWidget {
  final String animeId;
  final String animeTitle;

  const AnimeDetailPage({
    Key? key,
    required this.animeId,
    required this.animeTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animeTitle),
      ),
      body: Consumer<AnimeProvider>(
        builder: (context, animeProvider, _) {
          // Find the anime in the list
          final anime = animeProvider.animes.firstWhere(
            (a) => a.id == animeId,
            orElse: () => Anime(
              id: animeId,
              title: animeTitle,
              episodeCount: 0,
            ),
          );

          final description = anime.synopsis ?? anime.description;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Anime poster and basic info
                Center(
                  child: Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          anime.imageUrl ?? 'https://via.placeholder.com/200x300',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  anime.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                if (anime.rating > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${anime.rating}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                // Description section
                if (description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Synopsis:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                ],
                // Watch Now button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('WATCH NOW'),
                    onPressed: anime.episodeCount > 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EpisodeListPage(
                                  animeTitle: animeTitle,
                                  totalEpisodes: anime.episodeCount,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
                // View All Episodes button
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    child: const Text('VIEW ALL EPISODES'),
                    onPressed: anime.episodeCount > 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EpisodeListPage(
                                  animeTitle: animeTitle,
                                  totalEpisodes: anime.episodeCount,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
                if (anime.episodeCount <= 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'No episodes available',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}