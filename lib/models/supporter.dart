class Supporter {
  String? id;
  String? image;
  String? name;

  Supporter({
    this.id,
    this.image,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
    };
  }

  factory Supporter.fromMap(Map<String, dynamic> map) {
    return Supporter(
      id: map['id'],
      image: map['image'],
      name: map['name'],
    );
  }
}
