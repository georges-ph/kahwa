import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Shows the address of a creator page with its QR code, to copy, share or
/// scan from another phone.
Future<void> showPageLink(BuildContext context, {required String link}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _PageLinkDialog(link: link),
  );
}

class _PageLinkDialog extends StatelessWidget {
  const _PageLinkDialog({required this.link});

  final String link;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    Navigator.of(context).pop();
    showSnack(context, 'Link copied');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share this page'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: link,
            size: 220,
            // Scanners need dark squares on a light ground with a margin.
            backgroundColor: kWhiteColor,
            padding: const EdgeInsets.all(12),
          ),
          const SizedBox(height: 12),
          SelectableText(link, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(onPressed: () => _copy(context), child: const Text('Copy')),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            SharePlus.instance.share(ShareParams(uri: Uri.parse(link)));
          },
          child: const Text('Share'),
        ),
      ],
    );
  }
}
