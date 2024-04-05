import 'package:flutter/material.dart';

class ShowsPage extends StatelessWidget {
  const ShowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shows')),
      body: const Center(child: Text('Shows Page')),
    );
  }
}
