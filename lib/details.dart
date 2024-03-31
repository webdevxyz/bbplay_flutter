// details.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailsPage extends StatefulWidget {
  final String contentId;

  DetailsPage({Key? key, required this.contentId}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class ContentDetails {
  final String title;
  final String? desc;
  final String? imageUrl;
  final String? fileUrl;

  ContentDetails({
    required this.title,
    this.desc,
    this.imageUrl,
    this.fileUrl,
  });

  factory ContentDetails.fromJson(Map<String, dynamic> json) {
    // First access the 'content' key of the response
    Map<String, dynamic> content = json['content'];

    return ContentDetails(
      title: content['title'] ?? 'N/A',
      imageUrl: content.containsKey('poster')
          ? "https://cdn.webdevxyz.com/" + content['poster']
          : null, // Adjust according to your JSON and server setup
      desc: content['desc'] ?? 'No description provided.',
      fileUrl:
          content.containsKey('video') && content['video']['fileUrl'] != null
              ? "https://cdn.webdevxyz.com/" + content['video']['fileUrl']
              : null,
    );
  }
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<ContentDetails> contentDetails;

  @override
  void initState() {
    super.initState();
    contentDetails = fetchContentDetails(widget.contentId);
  }

  Future<ContentDetails> fetchContentDetails(String contentId) async {
    final response = await http
        .get(Uri.parse('https://encoder.webdevxyz.com/content/$contentId'));
    if (response.statusCode == 200) {
      return ContentDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load content details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: FutureBuilder<ContentDetails>(
        future: contentDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final details = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.network(
                      details.imageUrl ??
                          'https://cdn.webdevxyz.com/uploads/7-1711638783833.jpg',
                      height: 300.0,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.title,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          Text(
                            details.desc ??
                                'No description provided.', // Provide a fallback value if desc is null
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
