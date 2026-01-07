import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CloudinaryVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;

  const CloudinaryVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.autoPlay = true,
    this.looping = false,
  }) : super(key: key);

  @override
  _CloudinaryVideoPlayerState createState() => _CloudinaryVideoPlayerState();
}

class _CloudinaryVideoPlayerState extends State<CloudinaryVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint('Initializing video player with URL: ${widget.videoUrl}');
      
      // Check if URL is valid
      if (widget.videoUrl.isEmpty) {
        throw 'Video URL is empty';
      }

      String videoUrl = widget.videoUrl;
      if (kIsWeb) {
        // Fix Cloudinary URL if it contains double Cloudinary domain
        if (videoUrl.contains('res.cloudinary.com//video/upload/')) {
          // Extract the part after the double domain
          final parts = videoUrl.split('res.cloudinary.com//video/upload/');
          if (parts.length > 1) {
            // Remove any leading 'https:' or 'http:' if present
            String fixedUrl = parts[1].replaceFirst(RegExp(r'^https?://'), '');
            // Ensure it starts with https://
            fixedUrl = 'https://$fixedUrl';
            videoUrl = fixedUrl;
            debugPrint('Fixed Cloudinary URL: $videoUrl');
          }
        }
        
        // Ensure the URL is absolute
        if (!videoUrl.startsWith(RegExp(r'https?://'))) {
          throw 'Video URL must be an absolute URL (start with http:// or https://)';
        }
        
        // Log the video URL for debugging
        debugPrint('Web video URL: $videoUrl');
      }

      _videoPlayerController = VideoPlayerController.network(
        videoUrl,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );

      // Add listener for player errors
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.hasError) {
          debugPrint('Video player error: ${_videoPlayerController.value.errorDescription}');
        }
      });

      await _videoPlayerController.initialize().catchError((error) {
        debugPrint('Error initializing video player: $error');
        throw 'Failed to initialize video player: ${error.toString()}';
      });

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControlsOnInitialize: true,
        placeholder: Container(
          color: Colors.black12,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          debugPrint('Chewie error: $errorMessage');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading video',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () {
                    _initializePlayer();
                  },
                ),
              ],
            ),
          );
        },
      );
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error in _initializePlayer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _initializePlayer();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Chewie(controller: _chewieController!),
    );
  }
}