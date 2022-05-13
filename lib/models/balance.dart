// ignore_for_file: non_constant_identifier_names

class Balance {
  int? current_lbp;
  int? current_usd;
  int? spent_lbp;
  int? spent_usd;
  int? received_lbp;
  int? received_usd;
  int? available_withdraw_lbp;
  int? available_withdraw_usd;

  Balance({
    this.current_lbp,
    this.current_usd,
    this.spent_lbp,
    this.spent_usd,
    this.received_lbp,
    this.received_usd,
    this.available_withdraw_lbp,
    this.available_withdraw_usd,
  });

  Map<String, dynamic> toMap() {
    return {
      'current_lbp': current_lbp,
      'current_usd': current_usd,
      'spent_lbp': spent_lbp,
      'spent_usd': spent_usd,
      'received_lbp': received_lbp,
      'received_usd': received_usd,
      'available_withdraw_lbp': available_withdraw_lbp,
      'available_withdraw_usd': available_withdraw_usd,
    };
  }

  factory Balance.fromMap(Map<String, dynamic> map) {
    return Balance(
      current_lbp: map['current_lbp']?.toInt(),
      current_usd: map['current_usd']?.toInt(),
      spent_lbp: map['spent_lbp']?.toInt(),
      spent_usd: map['spent_usd']?.toInt(),
      received_lbp: map['received_lbp']?.toInt(),
      received_usd: map['received_usd']?.toInt(),
      available_withdraw_lbp: map['available_withdraw_lbp']?.toInt(),
      available_withdraw_usd: map['available_withdraw_usd']?.toInt(),
    );
  }
}
