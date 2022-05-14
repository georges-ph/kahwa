class FanSupporter {
  String? id;
  String? name;
  String? image;

  FanSupporter({
    this.id,
    this.name,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  factory FanSupporter.fromMap(Map<String, dynamic> map) {
    return FanSupporter(
      id: map['id'],
      name: map['name'],
      image: map['image'],
    );
  }
}
