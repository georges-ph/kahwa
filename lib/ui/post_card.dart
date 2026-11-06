import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/models/post.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// A creator's post, on their page and in the Home feed.
class PostCard extends ConsumerStatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.creator,
    this.onChanged,
    this.showCreator = false,
  });

  final Post post;
  final Profile? creator;

  /// Called after the post was edited, deleted or liked.
  final VoidCallback? onChanged;

  /// Shows who wrote it, for the Home feed.
  final bool showCreator;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  late Post _post = widget.post;

  @override
  void didUpdateWidget(PostCard old) {
    super.didUpdateWidget(old);
    if (old.post != widget.post) _post = widget.post;
  }

  Future<void> _like() async {
    final me = ref.read(userIdProvider);
    if (me == null) {
      context.push(Routes.signInThen(GoRouterState.of(context).uri.toString()));
      return;
    }
    final before = _post;
    setState(() => _post = _post.toggledLike(me));
    try {
      await ref
          .read(postRepositoryProvider)
          .setLike(before, me, like: !before.isLikedBy(me));
      refreshMyData(ref.invalidate);
    } catch (_) {
      if (!mounted) return;
      setState(() => _post = before);
      showSnack(context, context.l10n.somethingWrong);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.deletePostTitle,
      message: l10n.deletePostBody,
      confirm: l10n.delete,
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(postRepositoryProvider).delete(_post);
      widget.onChanged?.call();
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final me = ref.watch(userIdProvider);
    final isMine = me != null && me == _post.creatorId;
    final creator = widget.creator;
    final liked = _post.isLikedBy(me);

    return Panel(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.showCreator && creator != null) ...[
                InkWell(
                  onTap: () => context.push(Routes.page(creator)),
                  borderRadius: BorderRadius.circular(12),
                  child: ProfileAvatar(profile: creator, size: 38),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showCreator && creator != null)
                      Text(creator.name, style: context.text.titleSmall),
                    Text(
                      [
                        context.ago(_post.createdAt),
                        if (_post.editedAt != null) l10n.edited,
                      ].join(' · '),
                      style: context.text.bodySmall?.copyWith(
                        color: context.kahwa.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (_post.membersOnly)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 14,
                        color: context.colors.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.membersOnly,
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isMine)
                PopupMenuButton<String>(
                  onSelected: (choice) {
                    if (choice == 'edit') {
                      context
                          .push(Routes.editPost(_post.id))
                          .then((_) => widget.onChanged?.call());
                    } else {
                      _delete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
                )
              else
                const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: _post.locked
                ? _Locked(creator: creator, onJoined: widget.onChanged)
                : SelectableText(
                    _post.text,
                    textDirection: textDirectionOf(_post.text),
                    style: context.text.bodyLarge,
                  ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                // Only readers like: a locked post shows nothing to like.
                onPressed: _post.locked ? null : _like,
                tooltip: liked ? l10n.unlike : l10n.like,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(liked),
                    color: liked ? context.colors.primary : context.kahwa.muted,
                  ),
                ),
              ),
              Text(
                '${_post.likes}',
                style: context.text.labelLarge?.copyWith(
                  color: context.kahwa.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Locked extends StatelessWidget {
  const _Locked({required this.creator, this.onJoined});

  final Profile? creator;

  /// Called back from the membership screen.
  final VoidCallback? onJoined;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = creator;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.kahwa.subtle,
        borderRadius: BorderRadius.circular(Radii.tile),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_rounded, color: context.colors.primary),
          const SizedBox(height: 8),
          Text(
            l10n.lockedPost,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
          if (c != null && c.tiers.isNotEmpty) ...[
            const SizedBox(height: 10),
            FilledButton(
              // Reloads the posts on return, so the post opens once joined.
              onPressed: () => context
                  .push(
                    Routes.support(
                      c.id,
                      username: c.username,
                      tier: c.tiers.first.id,
                    ),
                  )
                  .then((_) => onJoined?.call()),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
              child: Text(l10n.becomeMember),
            ),
          ],
        ],
      ),
    );
  }
}
