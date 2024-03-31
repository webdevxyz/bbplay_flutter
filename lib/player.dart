import 'package:flutter/material.dart';
// Import your chosen video player package

class PlayerScreen extends StatelessWidget {
  final String hlsUrl;

  const PlayerScreen({Key? key, required this.hlsUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use your chosen video player widget here, passing hlsUrl to it
    return Scaffold(
      appBar: AppBar(
        title: Text('Player'),
      ),
      body: Center(
        child: Text('Implement video player here'),
      ),
    );
  }
}
