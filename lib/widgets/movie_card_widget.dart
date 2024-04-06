// movie_card_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/movies_controller.dart';

class MovieCardWidget extends StatelessWidget {
  final Movie movie;

  const MovieCardWidget({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assuming your Movie class contains a poster URL in a field called `poster`
    final posterUrl = movie.poster ?? '';
    final title = movie.title;

    return GestureDetector(
      onTap: () {
        // Insert your navigation logic here, e.g., to a detailed movie page
      },
      child: GridTile(
        footer: Material(
          color: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
          ),
          clipBehavior: Clip.antiAlias,
          child: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        child: posterUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: posterUrl,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              )
            : const Center(
                child: Icon(Icons.movie),
              ),
      ),
    );
  }
}
