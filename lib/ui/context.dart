import 'package:flutter/material.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

extension L10nContext on BuildContext {
  L10n get l10n => L10n.of(this);

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  /// [amount] in [currency], written for the language of the app.
  String money(num amount, Currency currency) {
    return currency.format(amount, arabic: isArabic);
  }

  String moneyCompact(num amount, Currency currency) {
    return currency.compact(amount, arabic: isArabic);
  }

  /// "2 hours ago", in the language of the app.
  String ago(DateTime? time) {
    if (time == null) return l10n.justNow;
    return timeago.format(
      time,
      locale: Localizations.localeOf(this).languageCode,
    );
  }

  /// A date such as "12 Oct 2026".
  String date(DateTime? time) {
    if (time == null) return '';
    return MaterialLocalizations.of(this).formatMediumDate(time);
  }
}

/// Screen widths where the layout changes.
abstract final class Breakpoints {
  /// Two columns on pages, a navigation rail instead of a bottom bar.
  static const wide = 840.0;

  /// Room for the labels of the navigation rail.
  static const desktop = 1200.0;
}

extension LayoutContext on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  bool get isWide => width >= Breakpoints.wide;
}

/// A date and time to the minute, such as "Nov 5, 2026 9:47 PM", for
/// checking a transfer in WHISH.
String dateTime(BuildContext context, DateTime? time) {
  if (time == null) return '';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_jm().format(time);
}
