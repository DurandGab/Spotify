import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chanson.dart';
import 'package:projet_spotify_gorouter/token.dart';

class ChansonProvider {
  String bearer = token;
  static const String _baseUrl = 'https://api.spotify.com/v1';

  
Future<List<Chanson>> fetchTopTracks(String artistId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/artists/$artistId/top-tracks?market=FR'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': bearer,
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body)['tracks'];
    final List<Chanson> topTracks = responseData.map((trackJson) => Chanson.fromJson(trackJson)).toList();
    return topTracks;
  } else {
    throw Exception('Failed to load top tracks for artist');
  }
}

Future<Chanson> fetchChansonDetails(String chansonId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/tracks/$chansonId'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': bearer,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final Chanson chanson = Chanson.fromJson(responseData);
    return chanson;
  } else {
    throw Exception('Failed to load artist details');
  }
}

Future<List<Chanson>> searchChanson(String query) async {
  final String url = 'https://api.spotify.com/v1/search?type=track&market=FR&q=$query';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': bearer,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final List<dynamic> chansonList = responseData['tracks']['items'];
    final List<Chanson> chansons = chansonList
        .map((chansonJson) => Chanson.fromJson(chansonJson))
        .toList();
    return chansons;
  } else {
    throw Exception('Failed to search chansons');
  }
}

}
