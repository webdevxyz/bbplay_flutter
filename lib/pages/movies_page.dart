// Update your movies_page.dart
import 'package:flutter/material.dart';
import '../controller/movies_controller.dart';
import '../widgets/movie_card_widget.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({Key? key}) : super(key: key);

  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  late Future<List<Section>> sections;

  @override
  void initState() {
    super.initState();
    // Assuming '660a8afec3938c5385d3d173' is the key you mentioned; replace it as necessary
    sections = ApiController().fetchSections('660a8afec3938c5385d3d173');

    print(sections);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Section>>(
      future: sections,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // Flatten all movies into a single list
        final allMovies =
            snapshot.data?.expand((section) => section.list).toList() ?? [];

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7, // Adjust based on your card's content
          ),
          itemCount: allMovies.length,
          itemBuilder: (context, index) {
            // Assuming you have a MovieCardWidget, or replace with your own widget
            return MovieCardWidget(movie: allMovies[index]);
          },
        );
      },
    );
  }
}
