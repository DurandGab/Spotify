import 'artiste.dart';
import 'album.dart';
class Chanson {
  Album? album;
  String? id;
  String? name;
  String? imageUrl;
  List<Artiste>? artists;
  String? previewUrl;

  Chanson({this.id, this.name, this.imageUrl, this.previewUrl});

  Chanson.fromJson(Map<String, dynamic> json) {
    album = json['album'] != null ? new Album.fromJson(json['album']) : null;
		if (json['artists'] != null) {
			artists = <Artiste>[];
			json['artists'].forEach((v) { artists!.add(new Artiste.fromJson(v)); });
		}
    id = json['id'];
    name = json['name'];
    previewUrl = json['preview_url'];
    imageUrl = (json['images'] as List<dynamic>?)
        ?.map((image) => image['url'] as String)
        .first; // Prend la première image
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.album != null) {
      data['album'] = this.album!.toJson();
    }
		if (this.artists != null) {
      data['artists'] = this.artists!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['name'] = name;
    data['preview_url'] = this.previewUrl;
    // L'image n'est pas incluse car elle ne devrait pas être sérialisée
    return data;
  }
}
