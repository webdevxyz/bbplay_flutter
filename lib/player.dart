import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends StatefulWidget {
  final String hlsUrl;
  final String title;
  final bool isTrailer;

  const PlayerScreen({
    Key? key,
    required this.hlsUrl,
    required this.title,
    this.isTrailer = false,
  }) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.hlsUrl),
    );
    // Set landscape orientation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setLandscapeOrientation();
    });
  }

  @override
  void dispose() {
    flickManager.dispose();
    // Set orientation back to portrait when exiting the player
    _resetOrientation();
    super.dispose();
  }

  Future<void> _setLandscapeOrientation() async {
    await Future.wait([
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]),
    ]);
  }

  Future<void> _resetOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Set the background color of the AppBar with 20% opacity black
        backgroundColor: Colors.black.withOpacity(0),
        // Set the icon theme to ensure back button and other icons are white
        iconTheme: IconThemeData(
            color: const Color.fromARGB(0, 255, 255, 255).withOpacity(0.8)),
        // Set the title with custom text style
        title: Text(
          widget.isTrailer ? '${widget.title} - Trailer' : widget.title,
          // Apply a TextStyle to change the color to white with 80% opacity
          style: TextStyle(
              color: Color.fromARGB(255, 173, 166, 166).withOpacity(0.8)),
        ),
        // Ensures that the text and icons (if any) in the AppBar are white with the desired opacity
        foregroundColor: Colors.white.withOpacity(0.8),
      ),
      body: FlickVideoPlayer(
        flickManager: flickManager,
      ),
    );
  }
}
