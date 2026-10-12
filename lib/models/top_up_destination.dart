import 'package:kahwa/models/currency.dart';

/// Where users send money to top up, set by an admin in the `Config/top_up`
/// document.
class TopUpDestination {
  const TopUpDestination({this.whishQr = const {}});

  /// The text inside the admin's "Whish Me" QR codes, links such as
  /// `https://whish.money/pay/abc123`. WHISH gives one code per currency and
  /// only pays it from a balance in that currency. The sender sees the
  /// admin's name in the WHISH app, never a phone number.
  final Map<Currency, String> whishQr;

  /// False when top ups have not been set up.
  bool get isSet => whishQr.isNotEmpty;

  /// The currencies top ups can be made in: those that have a code.
  List<Currency> get currencies => [
    for (final currency in Currency.values)
      if (whishQr.containsKey(currency)) currency,
  ];

  /// Address that opens the payment in [currency] in the WHISH app on a
  /// phone that has it installed, so nobody has to scan a code shown on
  /// their own screen.
  ///
  /// WHISH registers `whish.money/app/pay/...` as the form of the link that
  /// its app opens, on Android and on iPhone. The app has to be up to date:
  /// an older one leaves the link on a web page with nothing to pay on.
  /// Null when the code is not a WHISH pay link.
  Uri? appLink(Currency currency) {
    final uri = Uri.tryParse(whishQr[currency] ?? '');
    if (uri == null) return null;
    if (uri.host != 'whish.money' && uri.host != 'www.whish.money') return null;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length != 2 || segments.first != 'pay') return null;
    return Uri.https('whish.money', '/app/pay/${segments.last}');
  }

  factory TopUpDestination.fromMap(Map<String, dynamic> map) {
    return TopUpDestination(
      whishQr: {
        for (final currency in Currency.values)
          if (map['whish_qr_${currency.name}'] case final String qr
              when qr.trim().isNotEmpty)
            currency: qr.trim(),
      },
    );
  }
}
