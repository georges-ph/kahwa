// ignore_for_file: non_constant_identifier_names

import 'package:kahwa/enums/colors.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? image;
  String? about; // NEW
  String? website; // NEW
  // enum
  Colors? color; // NEW
  int? kahwa_lbp;
  int? kahwa_usd;
  String? phone;
  // String? link_id;

  User({
    this.id,
    this.name,
    this.email,
    this.image,
    this.about,
    this.website,
    this.color,
    this.kahwa_lbp,
    this.kahwa_usd,
    this.phone,
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
      'kahwa_lbp': kahwa_lbp,
      'kahwa_usd': kahwa_usd,
      'phone': phone,
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
      kahwa_lbp: map['kahwa_lbp']?.toInt(),
      kahwa_usd: map['kahwa_usd']?.toInt(),
      phone: map['phone'],
    );
  }
}
