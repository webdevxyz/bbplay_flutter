import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/movies_controller.dart';
import '../pages/details_page.dart'; // Import the DetailsPage

class MovieCardWidget extends StatelessWidget {
  final Movie movie;

  const MovieCardWidget({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.poster ?? '';
    final title = movie.title;

    double cardWidth = 105; // Adjust the width as needed
    double cardHeight =
        200; // Calculate card height based on the card width and the image's aspect ratio

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
        margin: const EdgeInsets.only(right: 16.0), // Add margin between cards
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0), // Add border-radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2), // Changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: posterUrl,
                fit: BoxFit.cover,
                width: double.infinity, // Use full width of the container
                height: double.infinity, // Use full height of the container
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Container(
                  color:
                      Colors.grey, // Background color for error or null image
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Loader shown only when image is loading
              if (posterUrl.isNotEmpty)
                FutureBuilder<void>(
                  future: precacheImage(
                    NetworkImage(posterUrl),
                    context,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
  }
}
