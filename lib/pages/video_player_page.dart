import 'package:flutter/material.dart';
import '../services/cloudinary_service.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/comment_section.dart'; 
import '../models/comment.dart'; 

class VideoPlayerPage extends StatefulWidget {
  final String episodeId;
  final String episodeTitle;
  final String animeTitle;

  const VideoPlayerPage({
    Key? key,
    required this.episodeId,
    required this.episodeTitle,
    required this.animeTitle,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  
  final List<Comment> _comments = [
    Comment(
      id: '1',
      userId: 'user1',
      userName: 'JesserDjo',
      userAvatar: '',
      text: 'The character development in this episode is exceptional! The animations are top-notch',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      likes: 24,
    ),
    Comment(
      id: '2',
      userId: 'user2',
      userName: 'AnimeLover42',
      userAvatar: '',
      text: 'This scene is amazing! The animations are top-notch',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 24,
    ),
    Comment(
      id: '3',
      userId: 'user3',
      userName: 'OtakuMaster',
      userAvatar: '',
      text: 'Does anyone know where I can find the original soundtrack?',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 8,
    ),
    Comment(
      id: '4',
      userId: 'user4',
      userName: 'SakuraFan',
      userAvatar: '',
      text: 'The character development in this episode is exceptional',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likes: 15,
    ),
  ];

  static const Map<String, Map<int, String>> _animeEpisodes = <String, Map<int, String>>{
    'Sousou no Frieren': <int, String>{
      1: 'https://res.cloudinary.com/dhth3wpkz/video/upload/v1763633705/Frieren_Magic_Exam_Best_Moments_Frieren_Beyond_Journey_s_End_jkrudd.mp4',
      2: 'https://res.cloudinary.com/dhth3wpkz/video/upload/v1763635375/Frieren_-_ALL_DEMON_FIGHTS_Aura_Linie_Lugner_fn5xik.mp4',
    },
    'Gintama': <int, String>{
      1: 'https://res.cloudinary.com/dhth3wpkz/video/upload/v1763640823/Gintaman_Full_HD_Engsub_d85ocs.mp4',
    },
  };

  String _getVideoUrl() {
    final episodeNumber = int.tryParse(widget.episodeId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    
    final animeEntry = _animeEpisodes.entries.firstWhere(
      (entry) => widget.animeTitle.toLowerCase().contains(entry.key.toLowerCase()),
      orElse: () => _animeEpisodes.entries.first,
    );
    
    return animeEntry.value[episodeNumber] ?? animeEntry.value.values.first;
  }

  void _addComment(String text) {
    if (text.trim().isEmpty) return;
    
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      userName: 'You',      // In production, use the actual username
      userAvatar: '',
      text: text.trim(),
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _comments.insert(0, newComment);
    });
  }

  void _toggleLike(int commentIndex) {
    setState(() {
      final comment = _comments[commentIndex];
      final newLikes = comment.isLiked ? comment.likes - 1 : comment.likes + 1;
      
      _comments[commentIndex] = comment.copyWith(
        likes: newLikes,
        isLiked: !comment.isLiked,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoUrl = _getVideoUrl();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.episodeTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Video player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CloudinaryVideoPlayer(
              videoUrl: videoUrl,
              autoPlay: true,
              looping: false,
            ),
          ),
          
          // Episode title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Text(
              widget.episodeTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Comments section
          Expanded(
            child: CommentSection(
              comments: _comments,
              onAddComment: _addComment,
              onToggleLike: _toggleLike,
            ),
          ),
        ],
      ),
    );
  }
}