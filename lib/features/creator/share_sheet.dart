import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// The link to a page, its QR code, and ways to pass it on.
Future<void> showShareSheet(BuildContext context, Profile profile) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ShareSheet(profile: profile),
  );
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final link = AppConfig.creatorLink(
      id: profile.id,
      username: profile.username,
    );
    final accent = Color(profile.color);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatar(profile: profile, size: 56),
                const SizedBox(height: 10),
                Text(
                  l10n.shareTitle(profile.name),
                  style: context.text.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Radii.card),
                    border: Border.all(color: context.kahwa.border),
                  ),
                  child: QrImageView(
                    data: link,
                    size: 200,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: accent,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Color(0xFF17141A),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.kahwa.subtle,
                    borderRadius: BorderRadius.circular(Radii.field),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          link,
                          style: context.text.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.copyLink,
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () async {
                          // The browser can refuse, such as on a page
                          // that is not focused.
                          final copied = await Clipboard.setData(
                            ClipboardData(text: link),
                          ).then((_) => true, onError: (_) => false);
                          if (context.mounted) {
                            showSnack(
                              context,
                              copied ? l10n.linkCopied : l10n.copyFailed,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: l10n.shareText(profile.name, link)),
                    ),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l10n.share),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
