import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/movies_controller.dart';
import '../pages/details_page.dart'; // Import the DetailsPage

class MovieCardWidget extends StatelessWidget {
  final Movie movie;

  const MovieCardWidget({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.poster ?? '';
    final title = movie.title;

    double cardWidth = 105; // Adjust the width as needed
    double cardHeight = 200; // Height is set to maintain aspect ratio

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
            const EdgeInsets.all(8.0), // Adjusted margin for uniform spacing
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
              12.0), // Slightly larger border-radius for a smoother look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Softer shadow
              spreadRadius: 0, // No spread for a tighter shadow
              blurRadius: 6, // Softer blur effect
              offset: const Offset(
                  0, 4), // Slightly lower shadow for a lifting effect
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(12.0), // Match container border-radius
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CachedNetworkImage(
                imageUrl: posterUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[400], // Softer color for error background
                  alignment: Alignment.center,
                  child: const Icon(Icons.error,
                      color: Colors.white), // Icon to indicate an error
                ),
              ),
              // Semi-transparent overlay with the movie title at the bottom
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
