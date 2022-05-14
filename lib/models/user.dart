// ignore_for_file: non_constant_identifier_names

import 'package:kahwa/enums/colors.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/models/fan_supporter.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/kahwa_prices.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? image;
  String? about;
  String? website;
  // enum
  Colors? color; 
  // String? link_id;
  KahwaPrices? kahwa_prices;
  Balance? balance;
  BillingDetails? billing_details;
  Goal? goal;
  List<FanSupporter>? fans;

  User({
    this.id,
    this.name,
    this.email,
    this.image,
    this.about,
    this.website,
    this.color,
    this.kahwa_prices,
    this.balance,
    this.billing_details,
    this.goal,
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
      'kahwa_prices': kahwa_prices?.toMap(),
      'balance': balance?.toMap(),
      'billing_details': billing_details?.toMap(),
      'goal': goal?.toMap(),
      'fans': fans?.map((x) => x.toMap()).toList(),
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
      kahwa_prices: map['kahwa_prices'] != null
          ? KahwaPrices.fromMap(map['kahwa_prices'])
          : null,
      balance: map['balance'] != null ? Balance.fromMap(map['balance']) : null,
      billing_details: map['billing_details'] != null
          ? BillingDetails.fromMap(map['billing_details'])
          : null,
      goal: map['goal'] != null ? Goal.fromMap(map['goal']) : null,
      fans: map['fans'] != null
          ? List<FanSupporter>.from(
              map['fans']?.map((x) => FanSupporter.fromMap(x)))
          : null,
    );
  }

  // User.fromFirestore(
  //     DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options)
  //     : id = snapshot.data()?['id'],
  //       name = snapshot.data()?['name'],
  //       email = snapshot.data()?['email'],
  //       image = snapshot.data()?['image'],
  //       about = snapshot.data()?['about'],
  //       website = snapshot.data()?['website'],
  //       color = snapshot.data()?['color'],
  //       // kahwa_lbp = snapshot.data()?['kahwa_lbp'],
  //       // kahwa_usd = snapshot.data()?['kahwa_usd'],
  //       phone = snapshot.data()?['phone'],
  //       kahwa_prices = snapshot.data()?['kahwa_prices'],
  //       balance = snapshot.data()?['balance'],
  //       billing_details = snapshot.data()?['billing_details'],
  //       goal = snapshot.data()?['goal'];

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'email': email,
  //     'image': image,
  //     'about': about,
  //     'website': website,
  //     'color': color?.name,
  //     // 'kahwa_lbp': kahwa_lbp,
  //     // 'kahwa_usd': kahwa_usd,
  //     'phone': phone,
  //     'kahwa_prices': kahwa_prices,
  //     'balance': balance,
  //     'billing_details': billing_details,
  //     'goal': goal,
  //   };
  // }
}
