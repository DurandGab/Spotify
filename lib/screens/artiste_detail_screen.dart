import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_spotify_gorouter/models/artiste.dart';
import 'package:projet_spotify_gorouter/providers/albumProvider.dart';
import 'package:projet_spotify_gorouter/providers/artisteProvider.dart';
import 'package:projet_spotify_gorouter/providers/chansonProvider.dart';
import 'package:projet_spotify_gorouter/models/chanson.dart';
import 'package:just_audio/just_audio.dart';

class ArtisteDetailScreen extends StatefulWidget {
  final String artistId;

  const ArtisteDetailScreen({Key? key, required this.artistId}) : super(key: key);

  @override
  _ArtisteDetailScreenState createState() => _ArtisteDetailScreenState();
}

class _ArtisteDetailScreenState extends State<ArtisteDetailScreen> {
  late Future<List<Chanson>> _topTracksFuture;
  late Future<Artiste> _artistFuture;
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;

  @override
  void initState() {
    super.initState();
    _artistFuture = ArtisteProvider().fetchArtistDetails(widget.artistId);
    _topTracksFuture = ChansonProvider().fetchTopTracks(widget.artistId);
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de l\'artiste')),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () => context.go('/a'),
          child: const Text('Retour'),
        ),
      ),
      body: FutureBuilder<Artiste>(
        future: _artistFuture,
        builder: (context, artistSnapshot) {
          if (artistSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (artistSnapshot.hasError) {
            return Center(child: Text('Erreur: ${artistSnapshot.error}'));
          } else if (artistSnapshot.hasData && artistSnapshot.data != null) {
            final artist = artistSnapshot.data!;
            return FutureBuilder<List<Chanson>>(
              future: _topTracksFuture,
              builder: (context, tracksSnapshot) {
                if (tracksSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (tracksSnapshot.hasError) {
                  return Center(child: Text('Erreur: ${tracksSnapshot.error}'));
                } else if (tracksSnapshot.hasData && tracksSnapshot.data != null) {
                  final List<Chanson> topTracks = tracksSnapshot.data!.take(5).toList();
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          artist.name ?? 'Inconnu',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (artist.imageUrl != null)
                          Image.network(
                            artist.imageUrl!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Top 5 chansons de l\'artiste',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: topTracks.length,
                            itemBuilder: (context, index) {
                              final Chanson track = topTracks[index];
                              return ListTile(
                                leading: track.album?.imageUrl != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(track.album!.imageUrl!),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                    ),
                                title: Text(track.name ?? ''),
                                trailing: IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: () {
                                    _playChanson(track.id!);
                                  },
                                ),
                                onTap: () {
                                  ChansonProvider().fetchChansonDetails(track.id!).then((chanson) {
                                    context.go('/a/chansondetails/${chanson.id}');
                                  }).catchError((error) {
                                    print('Erreur lors de la récupération des détails de la chanson : $error');
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('Chansons populaires non trouvées'));
                }
              },
            );
          } else {
            return Center(child: Text('Artiste introuvable'));
          }
        },
      ),
    );
  }

  void _playChanson(String chansonId) async {
    try {
      final chanson = await ChansonProvider().fetchChansonDetails(chansonId);
      _playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: [
          AudioSource.uri(Uri.parse(chanson.previewUrl!)),
        ],
      );
      await _audioPlayer.setAudioSource(_playlist);
      _audioPlayer.play();
    } catch (error) {
      print('Erreur lors de la lecture de la chanson : $error');
    }
  }
}
