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
      theme: ThemeData.dark().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Colors.blue,
        hintColor: Colors.purple,
        appBarTheme: AppBarTheme(
          color: Colors.black45,
          iconTheme: IconThemeData(color: Colors.white),
          toolbarTextStyle: TextTheme(
            headline6: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ).bodyText2,
          titleTextStyle: TextTheme(
            headline6: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ).headline6,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor:
              Colors.grey[900], // Choose a color that contrasts well with white
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(
              0.6), // Slightly dim unselected items for better visual distinction
        ),
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
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        title: Text('BBPlay', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
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
                if (index == 0) {
                  return SectionCarousel(section: snapshot.data![index]);
                }
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Shows'),
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
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        aspectRatio: 16 / 9,
      ),
      items: section.list.map((movie) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10), // Apply border radius to the image
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            10), // Apply border radius here
                        child: CachedNetworkImage(
                          imageUrl: movie.banner!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            alignment: Alignment.center,
                            color: Colors.grey,
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.5), // Tint color with opacity
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(
                                  10), // Match bottom corners of the image
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            movie.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  )),
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
            child: Text(section.name,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
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
                builder: (context) => DetailsPage(contentId: movie.id)));
      },
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 120.0,
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
                child: Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
