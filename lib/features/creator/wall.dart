import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// The kahwas a creator received, with their messages: the wall of a page.
class Wall extends ConsumerStatefulWidget {
  const Wall({
    super.key,
    required this.creator,
    required this.donations,
    required this.onChanged,
  });

  final Profile creator;
  final List<Donation> donations;
  final VoidCallback onChanged;

  @override
  ConsumerState<Wall> createState() => _WallState();
}

class _WallState extends ConsumerState<Wall> {
  static const _pageSize = 10;
  int _shown = _pageSize;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shown = widget.donations.take(_shown).toList();
    if (shown.isEmpty) {
      return EmptyState(
        icon: Icons.coffee_rounded,
        title: l10n.wallEmptyTitle,
        message: l10n.wallEmptyBody(widget.creator.name),
      );
    }
    final ids = ProfileIds(shown.map((d) => d.supporterId).nonNulls);
    final supporters = ref.watch(profilesProvider(ids)).valueOrNull ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final donation in shown) ...[
          DonationTile(
            donation: donation,
            supporter: supporters[donation.supporterId],
            creator: widget.creator,
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 10),
        ],
        if (widget.donations.length > _shown)
          Center(
            child: TextButton(
              onPressed: () => setState(() => _shown += _pageSize),
              child: Text(l10n.showMore),
            ),
          ),
      ],
    );
  }
}

class DonationTile extends ConsumerWidget {
  const DonationTile({
    super.key,
    required this.donation,
    required this.supporter,
    required this.creator,
    required this.onChanged,
  });

  final Donation donation;
  final Profile? supporter;
  final Profile creator;
  final VoidCallback onChanged;

  Future<void> _reply(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final me = ref.read(myProfileProvider).valueOrNull;
    if (me == null) return;
    final text = await showDialog<String>(
      context: context,
      builder: (context) => _ReplyDialog(initial: donation.reply),
    );
    if (text == null) return;
    try {
      await ref
          .read(supportRepositoryProvider)
          .reply(donation: donation, me: me, text: text);
      refreshMyData(ref.invalidate);
      onChanged();
    } catch (_) {
      if (context.mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  Future<void> _removeMessage(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.removeMessageTitle,
      message: l10n.removeMessageBody,
      confirm: l10n.remove,
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(supportRepositoryProvider).removeMessage(donation);
      refreshMyData(ref.invalidate);
      onChanged();
    } catch (_) {
      if (context.mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isOwner = ref.watch(userIdProvider) == creator.id;
    final s = supporter;
    final name = s?.name ?? l10n.someone;
    final action = donation.kind == DonationKind.membership
        ? l10n.paidMembership(donation.tierName ?? '')
        : l10n.boughtKahwas(donation.kahwas);

    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (s != null)
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push(Routes.page(s)),
                  child: ProfileAvatar(profile: s, size: 42),
                )
              else
                Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: context.kahwa.subtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const KahwaCup(),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: ' $action'),
                        ],
                      ),
                      style: context.text.bodyLarge,
                    ),
                    Row(
                      children: [
                        Text(
                          context.ago(donation.timestamp),
                          style: context.text.bodySmall?.copyWith(
                            color: context.kahwa.muted,
                          ),
                        ),
                        if (donation.keepPrivate) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.lock_rounded,
                            size: 13,
                            color: context.kahwa.muted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            l10n.private,
                            style: context.text.bodySmall?.copyWith(
                              color: context.kahwa.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isOwner && donation.hasMessage)
                PopupMenuButton<String>(
                  onSelected: (choice) => choice == 'reply'
                      ? _reply(context, ref)
                      : _removeMessage(context, ref),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'reply',
                      child: Text(
                        donation.hasReply ? l10n.editReply : l10n.reply,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Text(l10n.removeMessage),
                    ),
                  ],
                )
              else
                const SizedBox(width: 8),
            ],
          ),
          if (donation.hasMessage) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _Bubble(text: donation.message),
            ),
          ],
          if (donation.hasReply) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 28, end: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(profile: creator, size: 26),
                  const SizedBox(width: 8),
                  Expanded(child: _Bubble(text: donation.reply, tinted: true)),
                ],
              ),
            ),
          ] else if (isOwner && donation.hasMessage) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => _reply(context, ref),
              icon: const Icon(Icons.reply_rounded, size: 18),
              label: Text(l10n.sayThanks),
              style: TextButton.styleFrom(minimumSize: const Size(0, 36)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, this.tinted = false});

  final String text;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tinted ? context.colors.primaryContainer : context.kahwa.subtle,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textDirection: textDirectionOf(text),
        style: context.text.bodyMedium,
      ),
    );
  }
}

class _ReplyDialog extends StatefulWidget {
  const _ReplyDialog({required this.initial});

  final String initial;

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.reply),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _text,
          autofocus: true,
          maxLength: 500,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(hintText: l10n.replyHint),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _text.text.trim()),
          child: Text(l10n.send),
        ),
      ],
    );
  }
}
