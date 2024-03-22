import 'package:flutter/material.dart';
import 'package:projet_spotify_gorouter/providers/albumProvider.dart';
import 'package:projet_spotify_gorouter/models/chanson.dart';
import 'package:projet_spotify_gorouter/providers/chansonProvider.dart';
import 'package:just_audio/just_audio.dart';

class ChansonDetailScreen extends StatefulWidget {
  final String chansonId;

  const ChansonDetailScreen({Key? key, required this.chansonId}) : super(key: key);

  @override
  _ChansonDetailScreenState createState() => _ChansonDetailScreenState();
}

class _ChansonDetailScreenState extends State<ChansonDetailScreen> {
  late Future<Chanson> _chansonFuture;
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;


  @override
void initState() {
  super.initState();
  _chansonFuture = ChansonProvider().fetchChansonDetails(widget.chansonId);
  _audioPlayer = AudioPlayer();
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Détails de la chanson'),
    ),
    body: FutureBuilder<Chanson>(
      future: _chansonFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final chanson = snapshot.data!;
          _playlist = ConcatenatingAudioSource(
            useLazyPreparation: true,
            shuffleOrder: DefaultShuffleOrder(),
            children: [
              AudioSource.uri(Uri.parse(chanson.previewUrl!)),
            ],
          );
          _audioPlayer.setAudioSource(_playlist);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  chanson.name ?? 'Inconnu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (chanson.album?.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      chanson.album!.imageUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
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
                // Reste du contenu de la page...
              ],
            ),
          );
        } else {
          return Center(child: Text('Chanson introuvable'));
        }
      },
    ),
  );
}
}
