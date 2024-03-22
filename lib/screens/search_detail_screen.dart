import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_spotify_gorouter/providers/albumProvider.dart'; // Importez votre provider
import 'package:projet_spotify_gorouter/models/album.dart'; // Importez votre modèle d'album

class SearchDetailsScreen extends StatelessWidget {
  final String albumId; // L'ID de l'album sélectionné

  const SearchDetailsScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Album Details')),
      body: FutureBuilder<Album>(
        future: AlbumProvider().fetchAlbumDetails(albumId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final Album album = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (album.imageUrl != null)
                    Image.network(
                      album.imageUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    album.name ?? 'Unknown',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          } else {
            return Center(child: Text('Album not found'));
          }
        },
      ),
    );
  }
}
