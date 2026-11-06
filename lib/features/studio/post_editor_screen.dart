import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/models/post.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// Writes a new post, or edits the one with [postId].
class PostEditorScreen extends ConsumerStatefulWidget {
  const PostEditorScreen({super.key, this.postId});

  final String? postId;

  @override
  ConsumerState<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends ConsumerState<PostEditorScreen> {
  final _text = TextEditingController();
  bool _membersOnly = false;
  Post? _editing;
  bool _loaded = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _load(List<Post> posts) {
    if (_loaded) return;
    _loaded = true;
    final post = posts.where((p) => p.id == widget.postId).firstOrNull;
    if (post == null) return;
    _editing = post;
    _text.text = post.text;
    _membersOnly = post.membersOnly;
  }

  Future<void> _publish() async {
    final l10n = context.l10n;
    final me = ref.read(userIdProvider);
    final text = _text.text.trim();
    if (me == null) return;
    if (text.isEmpty) {
      showSnack(context, l10n.postEmpty);
      return;
    }
    final repo = ref.read(postRepositoryProvider);
    try {
      final editing = _editing;
      if (editing == null) {
        await repo.create(creatorId: me, text: text, membersOnly: _membersOnly);
      } else {
        await repo.edit(editing, text, membersOnly: _membersOnly);
      }
      ref.invalidate(postsOfProvider(me));
      if (!mounted) return;
      showSnack(context, editing == null ? l10n.posted : l10n.saved);
      context.pop();
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final me = ref.watch(myProfileProvider).valueOrNull;
    if (widget.postId != null) {
      final posts = ref.watch(postsOfProvider(me?.id ?? ''));
      if (!posts.hasValue) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      _load(posts.value!);
    }
    final hasTiers = me?.tiers.isNotEmpty ?? false;
    return TitledPage(
      title: _editing == null ? l10n.newPost : l10n.editPost,
      maxWidth: TitledPage.wideMaxWidth,
      bottom: BusyButton(
        label: _editing == null ? l10n.publish : l10n.save,
        icon: Icons.send_rounded,
        onPressed: _publish,
      ),
      // How the post will read on the page, beside the editor on a wide
      // screen. A phone shows the text as it is typed already.
      preview: ListenableBuilder(
        listenable: _text,
        builder: (context, _) => _PostPreview(
          me: me,
          text: _text.text.trim(),
          membersOnly: _membersOnly,
        ),
      ),
      previewOnPhone: PreviewOnPhone.hidden,
      side: [
        Panel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _membersOnly,
            // A post for members can always be opened to everyone.
            onChanged: hasTiers || _membersOnly
                ? (v) => setState(() => _membersOnly = v)
                : null,
            title: Text(l10n.membersOnlyPost),
            subtitle: Text(
              hasTiers || _membersOnly
                  ? l10n.membersOnlyHint
                  : l10n.membersOnlyNeedsTiers,
              style: TextStyle(color: context.kahwa.muted),
            ),
          ),
        ),
      ],
      children: [
        TextField(
          controller: _text,
          autofocus: true,
          maxLength: Post.maxLength,
          minLines: 8,
          maxLines: 20,
          decoration: InputDecoration(hintText: l10n.postHint),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// The post as supporters will see it.
class _PostPreview extends StatelessWidget {
  const _PostPreview({
    required this.me,
    required this.text,
    required this.membersOnly,
  });

  final Profile? me;
  final String text;
  final bool membersOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProfileAvatar(profile: me, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  me?.name ?? '',
                  style: context.text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (membersOnly)
                Chip(
                  avatar: const Icon(Icons.lock_rounded, size: 16),
                  label: Text(l10n.membersOnly),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text.isEmpty ? l10n.postHint : text,
            textDirection: text.isEmpty ? null : textDirectionOf(text),
            style: context.text.bodyLarge?.copyWith(
              color: text.isEmpty ? context.kahwa.muted : null,
            ),
          ),
        ],
      ),
    );
  }
}
