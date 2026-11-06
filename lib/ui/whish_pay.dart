import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/link.dart';

/// How to pay a WHISH pay link [code]: on a phone, a button that opens the
/// payment in the WHISH app, and the code to scan from another phone.
///
/// The person paid shows by their name in WHISH, never by their number.
class WhishPayBox extends StatelessWidget {
  const WhishPayBox({super.key, required this.code});

  /// The text inside a "Whish Me" QR code, such as
  /// `https://whish.money/pay/abc123`.
  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The WHISH app cannot scan a code shown on its own phone, so phones get
    // a button that opens the payment in the app instead.
    final isPhone =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final appLink = whishAppLink(code);
    final hasButton = isPhone && appLink != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasButton) ...[
          Link(
            uri: appLink,
            // A browser follows the link as a plain one, in the same tab. The
            // apps hand it to the phone, which would otherwise show it inside
            // kahwa.
            target: kIsWeb ? LinkTarget.self : LinkTarget.blank,
            builder: (context, followLink) => FilledButton.icon(
              onPressed: followLink == null ? null : () => followLink(),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(l10n.payWithWhish),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.whishUpdate,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
          ),
          const SizedBox(height: 20),
          Text(l10n.scanFromOtherPhone, textAlign: TextAlign.center),
        ] else
          Text(l10n.scanCode, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.tile),
              border: Border.all(color: context.kahwa.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: QrImageView(
              data: code,
              size: 220,
              // Scanners need dark squares on a light ground with a margin.
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }
}
