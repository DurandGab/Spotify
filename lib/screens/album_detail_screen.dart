import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_spotify_gorouter/providers/albumProvider.dart';
import 'package:projet_spotify_gorouter/providers/chansonProvider.dart';
import 'package:projet_spotify_gorouter/models/album.dart';
import 'package:just_audio/just_audio.dart';


class AlbumDetailScreen extends StatefulWidget {
  final String albumId;

  const AlbumDetailScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  _AlbumDetailScreenState createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  late Future<Album> _albumFuture;
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;


  @override
  void initState() {
    super.initState();
    _albumFuture = AlbumProvider().fetchAlbumDetails(widget.albumId);
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de l\'album')),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () => context.go('/a'),
          child: const Text('Retour'),
        ),
      ),
      body: FutureBuilder<Album>(
        future: _albumFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final album = snapshot.data!;
            _audioPlayer = AudioPlayer();
            _playlist = ConcatenatingAudioSource(
              useLazyPreparation: true,
              shuffleOrder: DefaultShuffleOrder(),
              children: album.chansons!.map((song) {
                return AudioSource.uri(Uri.parse(song.previewUrl!));
              }).toList(),
            );
            _audioPlayer.setAudioSource(_playlist);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    album.name ?? 'Inconnu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (album.imageUrl != null && album.imageUrl!.isNotEmpty)
                    Image.network(
                      album.imageUrl ?? '',
                      width: 100,
                      height: 700,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(
                      'Artistes (${album.artiste?.length ?? 0})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: album.artiste?.length ?? 0,
                        itemBuilder: (context, index) {
                          final artist = album.artiste![index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: artist.imageUrl != null ? NetworkImage(artist.imageUrl!) : null,
                            ),
                            title: Text(artist.name ?? ''),
                            onTap: () {
                              context.go('/a/artistedetails/${artist.id}');
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(
                      'Chansons (${album.chansons?.length ?? 0})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: album.chansons?.length ?? 0,
                        itemBuilder: (context, index) {
                          final song = album.chansons![index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: song.album?.imageUrl != null ? NetworkImage(song.album!.imageUrl!) : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(song.name ?? ''),
                                ),
                                IconButton(
                                  icon: Icon(_audioPlayer.playing ? Icons.pause : Icons.play_arrow),
                                  onPressed: () {
                                    if (_audioPlayer.playing) {
                                      _audioPlayer.pause();
                                    } else {
                                      _audioPlayer.play();
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              ChansonProvider().fetchChansonDetails(song.id!).then((chanson) {
                                context.go('/a/chansondetails/${chanson.id}');
                              }).catchError((error) {
                                print('Erreur lors de la récupération des détails de la chanson : $error');
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Album introuvable'));
          }
        },
      ),
    );
  }
}
