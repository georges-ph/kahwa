class BillingDetails {
  const BillingDetails({
    this.whishPhone = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
  });

  final String whishPhone;
  final String firstName;
  final String lastName;
  final String phone;

  bool get isEmpty =>
      whishPhone.isEmpty &&
      firstName.isEmpty &&
      lastName.isEmpty &&
      phone.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'whish_phone': whishPhone,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    };
  }

  factory BillingDetails.fromMap(Map<String, dynamic> map) {
    return BillingDetails(
      whishPhone: map['whish_phone'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
