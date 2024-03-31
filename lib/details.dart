// details.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'player.dart';

class DetailsPage extends StatefulWidget {
  final String contentId;

  DetailsPage({Key? key, required this.contentId}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class ContentDetails {
  final String title;
  final String? desc;
  final String? content;
  final String? imageUrl;
  final String? fileUrl;
  final String? videoHlsUrl;
  final String? trailerHlsUrl;

  ContentDetails({
    required this.title,
    this.desc,
    this.content,
    this.imageUrl,
    this.fileUrl,
    this.videoHlsUrl,
    this.trailerHlsUrl,
  });

  factory ContentDetails.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> content = json['content'];

    // Helper function to convert relative HLS URL to an absolute URL
    String makeAbsoluteHlsUrl(String relativeUrl) {
      if (relativeUrl.startsWith('/files/')) {
        // Replace the initial part of the path and prepend the base URL
        return 'https://cdn.webdevxyz.com/media/' +
            relativeUrl.substring('/files/'.length);
      }
      return relativeUrl; // Return as-is if not matching expected pattern
    }

    return ContentDetails(
      title: content['title'] ?? 'N/A',
      imageUrl: content.containsKey('poster')
          ? "https://cdn.webdevxyz.com/" + content['poster']
          : null, // Adjust according to your JSON and server setup
      desc: content['desc'] ?? 'No description provided.',
      content: content['content'] ?? 'No content provided.',
      videoHlsUrl:
          content.containsKey('video') && content['video']['hlsUrl'] != null
              ? makeAbsoluteHlsUrl(content['video']['hlsUrl'])
              : null,
      trailerHlsUrl:
          content.containsKey('trailer') && content['trailer']['hlsUrl'] != null
              ? makeAbsoluteHlsUrl(content['trailer']['hlsUrl'])
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

                    SizedBox(
                        height:
                            20), // Add space between the image and the button

                    // Inside the Column of your DetailsPage UI builder:
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(
                              hlsUrl: details
                                  .trailerHlsUrl!, // Ensure this is the correct property for the HLS URL
                              title: details
                                  .title, // Pass the title from your details object
                              isTrailer:
                                  true, // Indicating this is for playing a trailer
                            ),
                          ),
                        );
                      },
                      child: Text('Watch Trailer'),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(
                              hlsUrl: details
                                  .videoHlsUrl!, // Ensure this is the correct property for the HLS URL
                              title: details
                                  .title, // Pass the title from your details object
                              isTrailer:
                                  false, // Indicating this is not a trailer, but the main content
                            ),
                          ),
                        );
                      },
                      child: Text('Play'),
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
                          ),
                          Text(
                            details.content ??
                                'No content provided.', // Provide a fallback value if desc is null
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
