class Artiste {
  String? id;
  String? name;
  String? imageUrl;

  Artiste({this.id, this.name, this.imageUrl});

  Artiste.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageUrl = (json['images'] as List<dynamic>?)
        ?.map((image) => image['url'] as String)
        ?.first;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
