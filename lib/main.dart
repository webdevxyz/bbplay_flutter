import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'details.dart'; // Make sure this path correctly leads to your DetailsPage
import 'player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Section>> sections;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    sections = fetchSections();
  }

  Future<List<Section>> fetchSections() async {
    final response = await http
        .get(Uri.parse('https://encoder.webdevxyz.com/featured-section'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['data'];
      return body.map((dynamic item) => Section.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load sections');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: const Text('BBPlay', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<Section>>(
        future: sections,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Text('No data found');
          }
          return ListView(
            children: snapshot.data!.asMap().entries.map((entry) {
              int idx = entry.key;
              Section section = entry.value;
              return SectionWidget(
                section: section,
                isSlider: idx == 0, // Only the first section will be a slider
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Shows'),
          BottomNavigationBarItem(
              icon: Icon(Icons.download), label: 'Downloads'),
        ],
      ),
    );
  }
}

class Section {
  final String name;
  final List<Movie> list;

  Section({required this.name, required this.list});

  factory Section.fromJson(Map<String, dynamic> json) {
    var list = json['list'] as List;
    List<Movie> movieList = list.map((i) => Movie.fromJson(i)).toList();
    return Section(name: json['name'], list: movieList);
  }
}

class Movie {
  final String id;
  final String title;
  final String? poster;
  final String? banner;
  final String? hlsUrl; // Added HLS URL property

  Movie(
      {required this.id,
      required this.title,
      this.poster,
      this.banner,
      this.hlsUrl});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['_id'],
      title: json['title'],
      poster: json.containsKey('poster')
          ? "https://cdn.webdevxyz.com/" + json['poster']
          : null,
      banner: json.containsKey('banner')
          ? "https://cdn.webdevxyz.com/" + json['banner']
          : null,
      hlsUrl: json['video'] != null ? json['video']['hlsUrl'] : null,
    );
  }
}

class SectionWidget extends StatelessWidget {
  final Section section;
  final bool isSlider;

  const SectionWidget({
    Key? key,
    required this.section,
    this.isSlider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSlider) {
      return buildSlider(context);
    } else {
      return SizedBox(
        height: 190,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                section.name,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: buildListView(context)),
          ],
        ),
      );
    }
  }

  Widget buildImageWidget(Movie movie, BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: movie.banner ?? '',
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(
            color: Colors.grey, // Background color for error or null image
            alignment: Alignment.center,
            child: Text(
              movie.title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // When the image is fully loaded, hide the loader
          // Otherwise, show the loader
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ],
    );
  }

  Widget buildSlider(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: section.list.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        final movie = section.list[itemIndex];
        return GestureDetector(
          onTap: () {}, // Tap handling is done on the play button
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildImageWidget(movie, context),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: 50.0,
                    icon:
                        const Icon(Icons.play_circle_fill, color: Colors.white),
                    onPressed: () {
                      if (movie.hlsUrl != null) {
                        String updatedHlsUrl = "https://cdn.webdevxyz.com" +
                            movie.hlsUrl!.replaceFirst('/files', '/media');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(
                              hlsUrl: updatedHlsUrl,
                              title: movie.title,
                              isTrailer: false,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('HLS URL not available')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 16 / 7,
        enlargeCenterPage: true,
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    double cardWidth = 105; // Adjust the width as needed

    return ListView.builder(
      padding: EdgeInsets.only(left: 16.0), // Add padding to the left
      scrollDirection: Axis.horizontal,
      itemCount: section.list.length,
      itemBuilder: (context, index) {
        final movie = section.list[index];

        // Calculate card height based on the card width and the image's aspect ratio
        double cardHeight = 200;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(contentId: movie.id),
              ),
            );
          },
          child: Container(
            width: cardWidth,
            height: cardHeight,
            margin: EdgeInsets.only(right: 16.0), // Add margin between cards
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0), // Add border-radius
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.poster ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity, // Use full width of the container
                    height: double.infinity, // Use full height of the container
                    errorWidget: (context, url, error) => Container(
                      color: Colors
                          .grey, // Background color for error or null image
                      alignment: Alignment.center,
                      child: Text(
                        movie.title,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Loader shown only when image is loading
                  if (movie.poster != null)
                    FutureBuilder<void>(
                      future: precacheImage(
                        NetworkImage(movie.poster!),
                        context,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
