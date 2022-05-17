import 'package:kahwa/enums/colors.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? image;
  String? about;
  String? website;
  // enum
  Colors? color;
  List<String>? fans;

  User({
    this.id,
    this.name,
    this.email,
    this.image,
    this.about,
    this.website,
    this.color,
    this.fans,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'about': about,
      'website': website,
      'color': color?.name,
      'fans': fans,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    Colors color =
        Colors.values.firstWhere((element) => element.name == map['color']);
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      image: map['image'],
      about: map['about'],
      website: map['website'],
      color: map['color'] != null ? color : null,
      fans: List<String>.from(map['fans']),
    );
  }
}
