import 'package:projet_spotify_gorouter/models/chanson-no-sql.dart';

class Playlist {
  final int id;
  final String name;
  final List<ChansonNoSql> chansons;
  
  Playlist({required this.id, required this.name, required this.chansons});
}