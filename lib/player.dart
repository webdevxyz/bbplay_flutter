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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setLandscapeOrientation();
    });
  }

  @override
  void dispose() {
    flickManager.dispose();
    _resetOrientation();
    super.dispose();
  }

  Future<void> _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
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
        backgroundColor: Colors.black.withOpacity(0.4),
        iconTheme: IconThemeData(
            color: const Color.fromARGB(0, 255, 255, 255).withOpacity(0.8)),
        title: Text(
          widget.isTrailer ? '${widget.title} - Trailer' : widget.title,
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        foregroundColor: Colors.white.withOpacity(0.8),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: FlickVideoPlayer(
          flickManager: flickManager,
          flickVideoWithControls: FlickVideoWithControls(
            videoFit: BoxFit.cover, // Make video fill the container
            controls: FlickLandscapeControls(),
          ),
          flickVideoWithControlsFullscreen: FlickVideoWithControls(
            videoFit: BoxFit.cover, // Use BoxFit.cover to fill the screen
            controls: FlickLandscapeControls(),
          ),
        ),
      ),
    );
  }
}
