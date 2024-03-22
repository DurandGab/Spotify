import 'artiste.dart';
import 'chanson.dart';

class Album {
  String? id;
  String? name;
  String? imageUrl;
  List<Artiste>? artiste;
  List<Chanson>? chansons; // Modifier le type ici

  Album({this.id, this.name, this.imageUrl, this.artiste, this.chansons});

  Album.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageUrl = json['images'] != null && json['images'].isNotEmpty
        ? json['images'][0]['url']
        : null;
    if (json['artists'] != null) {
      artiste = <Artiste>[];
      json['artists'].forEach((v) {
        artiste!.add(Artiste.fromJson(v));
      });
    }
    if (json['tracks'] != null && json['tracks']['items'] != null) {
      chansons = <Chanson>[]; // Initialiser la liste de chansons
      json['tracks']['items'].forEach((track) {
        chansons!.add(Chanson.fromJson(track));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['imageUrl'] = imageUrl;
    if (artiste != null) {
      data['artists'] = artiste!.map((v) => v.toJson()).toList();
    }
    if (chansons != null) {
      data['tracks'] = chansons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
