import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/user.dart';

class DonationSupporter {
  Donation? donation;
  User? supporter;

  DonationSupporter({
    this.donation,
    this.supporter,
  });

  Map<String, dynamic> toMap() {
    return {
      'donation': donation?.toMap(),
      'supporter': supporter?.toMap(),
    };
  }

  factory DonationSupporter.fromMap(Map<String, dynamic> map) {
    return DonationSupporter(
      donation:
          map['donation'] != null ? Donation.fromMap(map['donation']) : null,
      supporter:
          map['supporter'] != null ? User.fromMap(map['supporter']) : null,
    );
  }
}
