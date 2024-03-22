import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_spotify_gorouter/providers/albumProvider.dart';
import 'package:projet_spotify_gorouter/providers/artisteProvider.dart';
import 'package:projet_spotify_gorouter/providers/chansonProvider.dart';
import 'package:projet_spotify_gorouter/models/album.dart';
import 'package:projet_spotify_gorouter/models/artiste.dart';
import 'package:projet_spotify_gorouter/models/chanson.dart';
import 'package:just_audio/just_audio.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedType = 'album'; // Type de recherche par défaut
  String _searchQuery = '';
  List<dynamic>? _searchResults;
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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

  void _search() async {
    // Vérifier que la requête de recherche n'est pas vide
    if (_searchQuery.isNotEmpty) {
      try {
        // Récupérer les résultats de la recherche en fonction du type sélectionné
        switch (_selectedType) {
          case 'album':
            _searchResults = await AlbumProvider().searchAlbums(_searchQuery);
            break;
          case 'artiste':
            _searchResults = await ArtisteProvider().searchArtist(_searchQuery);
            break;
          case 'chanson':
            _searchResults = await ChansonProvider().searchChanson(_searchQuery);
            break;
          default:
            throw Exception('Invalid search type');
        }
        // Mettre à jour l'état pour reconstruire l'interface utilisateur avec les nouveaux résultats
        setState(() {});
      } catch (e) {
        // Gérer les erreurs de recherche
        print('Error searching: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                    items: <String>['album', 'artiste', 'chanson']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.toUpperCase(),
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 7,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onFieldSubmitted: (value) {
                      _search();
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Recherche...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _search,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searchResults != null
                ? ListView.builder(
                    itemCount: _searchResults!.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults![index];
                      String? imageUrl;
                      String? artistName;

                      // Déterminer le type de résultat et extraire l'URL de l'image et le nom de l'artiste en conséquence
                      if (result is Album) {
                        imageUrl = result.imageUrl;
                        if (result.artiste != null && result.artiste!.isNotEmpty) {
                          // Supposons qu'un album peut avoir plusieurs artistes, nous prenons le premier artiste ici
                          artistName = result.artiste![0].name;
                        }
                      } else if (result is Artiste) {
                        imageUrl = result.imageUrl;
                        artistName = result.name;
                      } else if (result is Chanson) {
                        imageUrl = result.album?.imageUrl ?? '';
                        if (result.artists != null && result.artists!.isNotEmpty) {
                          // Supposons qu'une chanson peut avoir plusieurs artistes, nous prenons le premier artiste ici
                          artistName = result.artists![0].name;
                        }
                      }
                      return ListTile(
                        leading: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey,
                              ),
                        title: Text(result.name ?? 'Inconnu'),
                        subtitle: Text(artistName ?? 'Artiste inconnu'),
                        trailing: result is Chanson ? IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () {
                            _playChanson(result.id!);
                          },
                        ) : null, // Ajoutez cette condition pour afficher le bouton play uniquement pour les chansons
                        onTap: () {
                          // Action différente en fonction du type de résultat
                          if (result is Album) {
                            context.go('/a/albumdetails/${result.id}');
                          } else if (result is Artiste) {
                            context.go('/a/artistedetails/${result.id}');
                          } else if (result is Chanson) {
                            context.go('/a/chansondetails/${result.id}');
                          }
                        },
                      );
                    },
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
