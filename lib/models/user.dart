// ignore_for_file: non_constant_identifier_names

class User {
  final String? id;
  final String? name;
  final String? image;
  final int? kahwa_lbp;
  final int? kahwa_usd;
  final String? phone;

  User({
    this.id,
    this.name,
    this.image,
    this.kahwa_lbp,
    this.kahwa_usd,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'kahwa_lbp': kahwa_lbp,
      'kahwa_usd': kahwa_usd,
      'phone': phone,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      kahwa_lbp: map['kahwa_lbp']?.toInt(),
      kahwa_usd: map['kahwa_usd']?.toInt(),
      phone: map['phone'],
    );
  }
}
