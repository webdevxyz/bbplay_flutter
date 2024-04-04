// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'details.dart'; // Make sure this path correctly leads to your DetailsPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
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
  const HomePage({super.key});

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
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        title: Text('BBPlay', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<Section>>(
        future: sections,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Text('No data found');
          }
          return ListView(
            children: snapshot.data!.map((section) {
              return SectionWidget(
                  section:
                      section); // Adjusted to correctly reference SectionWidget
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

  Movie({required this.id, required this.title, this.poster, this.banner});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['_id'],
      title: json['title'],
      poster: json.containsKey('poster')
          // ignore: prefer_interpolation_to_compose_strings
          ? "https://cdn.webdevxyz.com/" + json['poster']
          : null,
      banner: json.containsKey('banner')
          // ignore: prefer_interpolation_to_compose_strings
          ? "https://cdn.webdevxyz.com/" + json['banner']
          : null,
    );
  }
}

class SectionWidget extends StatelessWidget {
  final Section section;

  const SectionWidget({Key? key, required this.section}) : super(key: key);

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
            child: Text(section.name,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.list.length,
              itemBuilder: (context, index) {
                final movie = section.list[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailsPage(
                                contentId: movie
                                    .id))); // Make sure this navigates correctly
                  },
                  child: CachedNetworkImage(
                    imageUrl: movie.poster ?? '',
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
