// details.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'player.dart';
import 'casts.dart';

class DetailsPage extends StatefulWidget {
  final String contentId;

  DetailsPage({Key? key, required this.contentId}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

// Define a Cast class to model each cast member's details
class Cast {
  final String name;
  final String bio;
  final String type;
  final String imageUrl;

  Cast(
      {required this.name,
      required this.bio,
      required this.type,
      required this.imageUrl});

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      name: json['name'],
      bio: json['bio'],
      type: json['type'],
      imageUrl: "https://cdn.webdevxyz.com/" + json['image'],
    );
  }
}

// Assuming you don't have a model for RelatedContent, here's a simple one.
class RelatedContent {
  final String id;
  final String title;
  final String posterUrl;
  final String bannerUrl;

  RelatedContent({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.bannerUrl,
  });

  factory RelatedContent.fromJson(Map<String, dynamic> json) {
    return RelatedContent(
      id: json['_id'],
      title: json['title'],
      posterUrl: "https://cdn.webdevxyz.com/" + json['poster'],
      bannerUrl: "https://cdn.webdevxyz.com/" + json['banner'],
    );
  }
}

class ContentDetails {
  final String title;
  final String? desc;
  final String? content;
  final String? imageUrl;
  final String? fileUrl;
  final String? videoHlsUrl;
  final String? trailerHlsUrl;
  final List<Cast> cast;
  final List<RelatedContent> relatedContent;

  ContentDetails({
    required this.title,
    this.desc,
    this.content,
    this.imageUrl,
    this.fileUrl,
    this.videoHlsUrl,
    this.trailerHlsUrl,
    required this.cast,
    required this.relatedContent,
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

    List<Cast> castList = (json['content']['cast'] as List)
        .map((castJson) => Cast.fromJson(castJson))
        .toList();

    List<RelatedContent> relatedContentList =
        (json['content']['relatedContent'] as List)
            .map((relatedJson) => RelatedContent.fromJson(relatedJson))
            .toList();

    return ContentDetails(
      title: content['title'] ?? 'N/A',
      imageUrl: content.containsKey('banner')
          ? "https://cdn.webdevxyz.com/" + content['banner']
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
      cast: castList,
      relatedContent: relatedContentList,
    );
  }
}

class RelatedContentCard extends StatelessWidget {
  final RelatedContent content;

  RelatedContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Assuming each content item has a unique ID that can be used to fetch its details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(contentId: content.id),
          ),
        );
      },
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          width: 120,
          height: 160,
          padding: const EdgeInsets.all(4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: content.posterUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                child: Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
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
                            10), // Add space between the image and the button

                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.play_arrow),
                            label: Text('Watch Trailer'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayerScreen(
                                    hlsUrl: details
                                        .trailerHlsUrl!, // Make sure this is correctly retrieved
                                    title: details.title,
                                    isTrailer: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.movie),
                            label: Text('Play Now'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayerScreen(
                                    hlsUrl: details
                                        .videoHlsUrl!, // Make sure this is correctly retrieved
                                    title: details.title,
                                    isTrailer: false,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.title,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          SizedBox(height: 10),
                          Text(
                            details.desc ??
                                '', // Provide a fallback value if desc is null
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          SizedBox(height: 10),
                          if (details.cast.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: Text(
                                'Casts',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Container(
                              height: 170,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: details.cast.length,
                                itemBuilder: (context, index) {
                                  Cast castMember = details.cast[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CastDetailsPage(
                                              castMember: castMember),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                castMember.imageUrl),
                                            radius: 50,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            castMember.name,
                                            style: TextStyle(fontSize: 12),
                                            overflow: TextOverflow
                                                .ellipsis, // Add this line
                                            maxLines: 1,
                                          ),
                                          Text(
                                            castMember.type,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // Inside the DetailsPage widget, after loading the content details
                          if (details.relatedContent.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.only(left: 0, top: 20),
                              child: Text(
                                'Related Content',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Container(
                              height: 180, // Adjust based on your UI needs
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: details.relatedContent.length,
                                itemBuilder: (context, index) {
                                  RelatedContent content =
                                      details.relatedContent[index];
                                  return RelatedContentCard(content: content);
                                },
                              ),
                            ),
                          ],

                          SizedBox(height: 10),
                          Text(
                            details.content ??
                                '', // Provide a fallback value if desc is null
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
