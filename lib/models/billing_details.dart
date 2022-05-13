// ignore_for_file: non_constant_identifier_names

class BillingDetails {
  String? whish_phone;
  String? first_name;
  String? last_name;
  String? phone;

  BillingDetails({
    this.whish_phone,
    this.first_name,
    this.last_name,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'whish_phone': whish_phone,
      'first_name': first_name,
      'last_name': last_name,
      'phone': phone,
    };
  }

  factory BillingDetails.fromMap(Map<String, dynamic> map) {
    return BillingDetails(
      whish_phone: map['whish_phone'],
      first_name: map['first_name'],
      last_name: map['last_name'],
      phone: map['phone'],
    );
  }
}
