import 'package:kahwa/models/creator_color.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.username,
    this.image,
    this.about,
    this.website,
    this.color = CreatorColor.brown,
    this.fans = const [],
    this.linkId,
  });

  final String id;
  final String name;

  /// Handle the creator picked for the address of their page, if any.
  final String? username;
  final String? image;
  final String? about;
  final String? website;
  final CreatorColor color;
  final List<String> fans;
  final String? linkId;

  bool hasFan(String userId) => fans.contains(userId);

  AppUser copyWith({
    String? name,
    String? image,
    String? about,
    String? website,
    CreatorColor? color,
    List<String>? fans,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      username: username,
      image: image ?? this.image,
      about: about ?? this.about,
      website: website ?? this.website,
      color: color ?? this.color,
      fans: fans ?? this.fans,
      linkId: linkId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'image': image,
      'about': about,
      'website': website,
      'color': color.name,
      'fans': fans,
      'link_id': linkId,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      username: map['username'],
      image: map['image'],
      about: map['about'],
      website: map['website'],
      color: CreatorColor.fromName(map['color']),
      fans: List<String>.from(map['fans'] ?? const []),
      linkId: map['link_id'],
    );
  }
}
