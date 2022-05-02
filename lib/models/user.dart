// ignore_for_file: non_constant_identifier_names

class User {
  String? id;
  String? name;
  String? email;
  String? image;
  int? kahwa_lbp;
  int? kahwa_usd;
  String? phone;
  bool? creator;
  // String? link_id;

  User({
    this.id,
    this.name,
    this.email,
    this.image,
    this.kahwa_lbp,
    this.kahwa_usd,
    this.phone,
    this.creator,
    // this.link_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'kahwa_lbp': kahwa_lbp,
      'kahwa_usd': kahwa_usd,
      'phone': phone,
      'creator': creator,
      // 'link_id': link_id,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      image: map['image'],
      kahwa_lbp: map['kahwa_lbp']?.toInt(),
      kahwa_usd: map['kahwa_usd']?.toInt(),
      phone: map['phone'],
      creator: map['creator'],
      // link_id: map['link_id'],
    );
  }
}
