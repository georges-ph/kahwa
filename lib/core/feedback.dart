import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows [message] in a snack bar, replacing the one on screen if any.
void showSnack(BuildContext context, String message, {SnackBarAction? action}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}

/// Opens [url] outside the app and tells the user when that fails.
Future<void> openLink(BuildContext context, Uri? url) async {
  final opened =
      url != null && await launchUrl(url, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) showSnack(context, 'Cannot open link');
}
