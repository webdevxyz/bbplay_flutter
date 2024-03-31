import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'details.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBPlay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Section>> sections;
  int _selectedIndex =
      0; // Add this line to manage the bottom navigation bar index

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
    // Add navigation logic based on the index if necessary
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // Implement search functionality
          },
        ),
        title: Text('BBPlay'),
        actions: <Widget>[
          TextButton(
            child: Text('Login',
                style: TextStyle(
                    color: Colors
                        .white)), // TextButton uses the default text style, so we need to explicitly set the color to white
            onPressed: () {
              // Navigate to login screen
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Section>>(
        future: sections,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                // Use CarouselSlider for the first section
                if (index == 0) {
                  return SectionCarousel(section: snapshot.data![index]);
                }
                // Use horizontal list view for other sections
                return SectionWidget(section: snapshot.data![index]);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

    return Section(
      name: json['name'],
      list: movieList,
    );
  }
}

class Movie {
  final String _id;
  final String title;
  final String? poster;
  final String? banner;

  Movie({required this.title, this.poster, this.banner, required String id})
      : _id = id; // Initialize the _id in the constructor

  // Add a getter for _id
  String get id => _id;

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
    );
  }
}

class SectionCarousel extends StatelessWidget {
  final Section section;

  SectionCarousel({required this.section});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
      ),
      items: section.list.map((movie) {
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: movie.banner!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  alignment: Alignment.center,
                  color: Colors.grey,
                  child: Text(
                    movie.title,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final Section section;

  SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              section.name,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.list.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: section.list[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;

  MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
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
        width: 140.0,
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CachedNetworkImage(
            imageUrl: movie.poster!,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey,
              child: Center(
                child: Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
