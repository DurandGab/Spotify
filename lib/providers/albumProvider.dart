import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/album.dart';
import '../models/chanson.dart';
import 'package:projet_spotify_gorouter/token.dart';

class AlbumProvider {
  String bearer = token;
  static const String _baseUrl = 'https://api.spotify.com/v1';

  Future<List<Album>> fetchNewAlbums() async {
  final response = await http.get(
    Uri.parse('$_baseUrl/browse/new-releases'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': bearer,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final List<dynamic> albumList = responseData['albums']['items'];
    final List<Album> albums = albumList
        .map((albumJson) => Album.fromJson(albumJson))
        .toList();
    return albums;
  } else {
    throw Exception('Failed to load new albums');
  }
}

Future<Album> fetchAlbumDetails(String albumId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/albums/$albumId'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': bearer,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final Album album = Album.fromJson(responseData);

    return album;
  } else {
    throw Exception('Failed to load album details');
  }
}

Future<List<Album>> searchAlbums(String query) async {
  final String url = 'https://api.spotify.com/v1/search?type=album&market=FR&q=$query';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': bearer,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final List<dynamic> albumList = responseData['albums']['items'];
    final List<Album> albums = albumList
        .map((albumJson) => Album.fromJson(albumJson))
        .toList();
    return albums;
  } else {
    throw Exception('Failed to search albums');
  }
}
}
