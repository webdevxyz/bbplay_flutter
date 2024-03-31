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
        title:
            Text(widget.isTrailer ? '${widget.title} - Trailer' : widget.title),
      ),
      body: FlickVideoPlayer(
        flickManager: flickManager,
      ),
    );
  }
}
