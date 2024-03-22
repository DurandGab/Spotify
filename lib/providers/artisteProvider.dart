import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artiste.dart';
import 'package:projet_spotify_gorouter/token.dart';

class ArtisteProvider {
  String bearer = token;
  static const String _baseUrl = 'https://api.spotify.com/v1';

Future<Artiste> fetchArtistDetails(String artistId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/artists/$artistId'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': bearer,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final Artiste artiste = Artiste.fromJson(responseData);
    return artiste;
  } else {
    throw Exception('Failed to load artist details');
  }
}

Future<List<Artiste>> searchArtist(String query) async {
  final String url = 'https://api.spotify.com/v1/search?type=artist&market=FR&q=$query';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': bearer,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    
    final List<dynamic> artistList = responseData['artists']['items'];
    
    final List<Artiste> artists = artistList.map((artistJson) {
        print (artistJson);
        return (Artiste.fromJson(artistJson));
        })
        .toList();
    
    return artists;
  } else {
    throw Exception('Failed to search artists');
  }
  
}

}
