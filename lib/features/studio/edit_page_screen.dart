import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/core/username.dart';
import 'package:kahwa/data/profile_repository.dart';
import 'package:kahwa/features/studio/page_editors.dart';
import 'package:kahwa/models/category.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/social_link.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/cover.dart';
import 'package:kahwa/ui/labels.dart';
import 'package:kahwa/ui/widgets.dart';

/// Everything about how a page looks and reads.
class EditPageScreen extends ConsumerWidget {
  const EditPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(myProfileProvider).valueOrNull;
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _EditPage(me: me);
  }
}

class _EditPage extends ConsumerStatefulWidget {
  const _EditPage({required this.me});

  final Profile me;

  @override
  ConsumerState<_EditPage> createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<_EditPage> {
  late final _name = TextEditingController(text: widget.me.name);
  late final _username = TextEditingController(text: widget.me.username ?? '');
  late final _tagline = TextEditingController(text: widget.me.tagline);
  late final _about = TextEditingController(text: widget.me.about);
  late final List<TextEditingController> _links = [
    for (final link in widget.me.links) TextEditingController(text: link.url),
  ];
  late String? _emoji = widget.me.emoji;
  late int _color = widget.me.color;
  late CoverPattern _cover = CoverPattern.of(widget.me.cover);
  late CreatorCategory? _category = widget.me.category;
  String? _nameError;
  String? _usernameError;
  final _linkErrors = <int, String>{};

  @override
  void dispose() {
    for (final c in [_name, _username, _tagline, _about, ..._links]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final username = Username.normalize(_username.text);
    final problem = username.isEmpty ? null : Username.validate(username);
    _linkErrors.clear();
    final links = <SocialLink>[];
    for (final (i, controller) in _links.indexed) {
      final url = controller.text.trim();
      if (url.isEmpty) continue;
      if (parseLink(url) == null) {
        _linkErrors[i] = l10n.linkInvalid;
      } else {
        links.add(SocialLink(kind: LinkKind.guess(url), url: url));
      }
    }
    setState(() {
      _nameError = name.isEmpty ? l10n.nameMissing : null;
      _usernameError = problem == null
          ? null
          : usernameProblem(context, problem);
    });
    if (_nameError != null ||
        _usernameError != null ||
        _linkErrors.isNotEmpty) {
      return;
    }

    final updated = widget.me.copyWith(
      name: name,
      username: () => username.isEmpty ? null : username,
      tagline: _tagline.text.trim(),
      about: _about.text.trim(),
      category: () => _category,
      emoji: () => _emoji,
      color: _color,
      cover: _cover.index,
      links: links,
    );
    try {
      await ref
          .read(profileRepositoryProvider)
          .save(updated, previousUsername: widget.me.username);
      await reloadMyProfile(ref);
      if (!mounted) return;
      showSnack(context, l10n.saved);
      context.pop();
    } on UsernameTakenException {
      if (mounted) {
        setState(
          () =>
              _usernameError = usernameProblem(context, UsernameProblem.taken),
        );
      }
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = PagePreview(
      name: _name.text.trim(),
      color: Color(_color),
      cover: _cover,
      emoji: _emoji,
      initials: initialsOf(_name.text),
      tagline: _tagline.text.trim(),
    );
    // The preview stays in sight while the form scrolls, so every change
    // shows at once, as in onboarding; on a wide screen the look of the page
    // sits under it.
    return TitledPage(
      title: l10n.editPage,
      maxWidth: TitledPage.wideMaxWidth,
      bottom: BusyButton(label: l10n.save, onPressed: _save),
      preview: preview,
      side: [
        FieldLabel(
          l10n.avatar,
          child: EmojiPicker(
            value: _emoji,
            initials: initialsOf(_name.text),
            onChanged: (e) => setState(() => _emoji = e),
          ),
        ),
        FieldLabel(
          l10n.pageColor,
          child: ColorPicker(
            value: _color,
            onChanged: (c) => setState(() => _color = c),
          ),
        ),
        FieldLabel(
          l10n.bannerPattern,
          child: PatternPicker(
            value: _cover,
            color: Color(_color),
            onChanged: (p) => setState(() => _cover = p),
          ),
        ),
        Text(
          l10n.pageColorHint,
          style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
        ),
      ],
      children: [
        FieldLabel(
          l10n.yourName,
          child: TextField(
            controller: _name,
            maxLength: 60,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'John Doe',
              errorText: _nameError,
              counterText: '',
            ),
          ),
        ),
        FieldLabel(
          l10n.username,
          hint: l10n.usernameHint,
          child: TextField(
            controller: _username,
            autocorrect: false,
            decoration: InputDecoration(
              prefixIcon: const AtSign(),
              prefixIconConstraints: const BoxConstraints(),
              hintText: 'johndoe',
              errorText: _usernameError,
            ),
          ),
        ),
        FieldLabel(
          l10n.taglineLabel,
          hint: l10n.taglineHint,
          child: TextField(
            controller: _tagline,
            maxLength: 120,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.taglineExample,
              counterText: '',
            ),
          ),
        ),
        FieldLabel(
          l10n.about,
          hint: l10n.aboutHint,
          child: TextField(
            controller: _about,
            maxLength: 3000,
            minLines: 4,
            maxLines: 12,
            decoration: InputDecoration(hintText: l10n.aboutExample),
          ),
        ),
        FieldLabel(
          l10n.whatYouMake,
          child: CategoryPicker(
            value: _category,
            onChanged: (c) => setState(() => _category = c),
          ),
        ),
        FieldLabel(
          l10n.links,
          hint: l10n.linksHint,
          child: Column(
            children: [
              for (final (i, controller) in _links.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'instagram.com/johndoe',
                      errorText: _linkErrors[i],
                      prefixIcon: Icon(
                        LinkKind.guess(controller.text).icon,
                        size: 18,
                      ),
                      suffixIcon: IconButton(
                        tooltip: l10n.remove,
                        onPressed: () => setState(() {
                          _links.removeAt(i).dispose();
                        }),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ),
                ),
              if (_links.length < 8)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _links.add(TextEditingController())),
                    icon: const Icon(Icons.add_link_rounded),
                    label: Text(l10n.addLink),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
