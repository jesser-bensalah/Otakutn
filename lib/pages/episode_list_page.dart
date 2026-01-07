import 'package:flutter/material.dart';
import 'video_player_page.dart';

class EpisodeListPage extends StatelessWidget {
  final String animeTitle;
  final int totalEpisodes;

  const EpisodeListPage({
    Key? key,
    required this.animeTitle,
    required this.totalEpisodes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$animeTitle Episodes'),
      ),
      body: ListView.builder(
        itemCount: totalEpisodes,
        itemBuilder: (context, index) {
          final episodeNumber = index + 1;
          return ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text('Episode $episodeNumber'),
            subtitle: Text('$animeTitle - Episode $episodeNumber'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(
                    episodeId: 'episode$episodeNumber',
                    episodeTitle: '$animeTitle - Episode $episodeNumber',
                    animeTitle: animeTitle,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}