import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiController {
  final String _baseUrl = "https://encoder.webdevxyz.com/featured-section/";

  Future<List<Section>> fetchSections(String key) async {
    final response = await http.get(Uri.parse('$_baseUrl$key'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      // Correcting the way to access the 'list' within 'data'
      List<dynamic> movieListData = decodedBody['data']['list'];

      // Create a Section with the name and list of movies
      Section section = Section(
        name: decodedBody['name'],
        list: movieListData.map<Movie>((item) => Movie.fromJson(item)).toList(),
      );

      return [section]; // Return a list containing the single section
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

  // Assuming the Section.fromJson is not needed anymore as the updated method handles creation
}

class Movie {
  final String id;
  final String title;
  final String? poster;
  final String? banner;
  final String? hlsUrl; // HLS URL property

  Movie({
    required this.id,
    required this.title,
    this.poster,
    this.banner,
    this.hlsUrl,
  });

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
