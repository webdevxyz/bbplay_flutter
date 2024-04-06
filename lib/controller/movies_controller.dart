// api_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiController {
  final String _baseUrl = "https://encoder.webdevxyz.com/featured-section/";

  Future<List<Section>> fetchSections(String key) async {
    final response = await http.get(Uri.parse('$_baseUrl$key'));
    if (response.statusCode == 200) {
      // Print the entire response body for debugging
      print("Response body: ${response.body}");

      final Map<String, dynamic> decodedBody = jsonDecode(response.body);
      // Assuming 'name' is at the same level as 'data' based on your response sample
      final String sectionName = decodedBody['name'];
      List<dynamic> body = decodedBody['data'];

      // Create a Section with the name and list of movies
      List<Section> sections = [
        Section(
            name: sectionName,
            list: body.map((dynamic item) => Movie.fromJson(item)).toList())
      ];

      return sections;
    } else {
      throw Exception(
          'Failed to load sections with status code: ${response.statusCode}');
    }
  }
}

class Section {
  final String name;
  final List<Movie> list;

  Section({required this.name, required this.list});
  factory Section.fromJson(Map<String, dynamic> json) {
    // Use a null-aware operator before casting to handle null safely
    var list = (json['list'] as List?) ?? [];
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
