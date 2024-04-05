// Your existing imports
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'pages/details_page.dart'; // Ensure this path is correct
import 'pages/player_page.dart';
import 'pages/movies_page.dart';
import 'pages/shows_page.dart';
import 'pages/categories_page.dart';
import 'pages/account_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MaterialApp setup as before
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
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}

// HomePage widget as you defined it, ensuring it includes all necessary functionalities

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<Section>> sections;

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
      throw Exception(
          'Failed to load sections with status code: ${response.statusCode}');
    }
  }

  void onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      FutureBuilder<List<Section>>(
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
      const MoviesPage(),
      const ShowsPage(),
      const CategoriesPage(),
      const AccountPage(),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'BBPlay',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Intentionally left blank for demonstration
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.titleText, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Image.asset('assets/images/logo.png'),
      ),
      title: Text(titleText),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
        BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Shows'),
        BottomNavigationBarItem(
            icon: Icon(Icons.category), label: 'Categories'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
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
    super.key,
    required this.section,
    this.isSlider = false,
  });

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
          fit: BoxFit.cover, // Adjust the fit to cover the whole container
          width: double.infinity,
          height: double.infinity,
          errorWidget: (context, url, error) => Container(
            color: Colors.grey, // Background color for error or null image
            alignment: Alignment.center,
            child: Text(
              movie.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // When the image is fully loaded, hide the loader
          // Otherwise, show the loader
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return const Center(
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
                        String updatedHlsUrl =
                            "https://cdn.webdevxyz.com${movie.hlsUrl!.replaceFirst('/files', '/media')}";
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
      padding: const EdgeInsets.only(left: 16.0), // Add padding to the left
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
            margin:
                const EdgeInsets.only(right: 16.0), // Add margin between cards
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0), // Add border-radius
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2), // changes position of shadow
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
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
                          return const CircularProgressIndicator();
                        } else {
                          return const SizedBox.shrink();
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
