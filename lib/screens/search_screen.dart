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
    if (_searchQuery.isNotEmpty) {
      try {
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
        setState(() {});
      } catch (e) {
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

                     
                      if (result is Album) {
                        imageUrl = result.imageUrl;
                        if (result.artiste != null && result.artiste!.isNotEmpty) {
                          
                          artistName = result.artiste![0].name;
                        }
                      } else if (result is Artiste) {
                        imageUrl = result.imageUrl;
                        artistName = result.name;
                      } else if (result is Chanson) {
                        imageUrl = result.album?.imageUrl ?? '';
                        if (result.artists != null && result.artists!.isNotEmpty) {
                          
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
                        ) : null,
                        onTap: () {
                        
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
