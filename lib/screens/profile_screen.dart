import 'package:flutter/material.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/creator_color.dart';
import 'package:kahwa/models/username.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/color_picker.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';
import 'package:kahwa/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AppUser> _user;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aboutController = TextEditingController();
  final _websiteController = TextEditingController();

  CreatorColor _color = CreatorColor.brown;
  String? _nameError;
  String? _usernameError;

  bool _isLoading = false;

  /// Username after the last save on this screen, empty when it was removed.
  /// Null until the first save.
  String? _savedUsername;

  @override
  void initState() {
    super.initState();
    _user = _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<AppUser> _load() async {
    final user = await userRepository.getUser(authRepository.userId);
    if (user == null) throw StateError('User not found');

    final account = authRepository.currentUser;
    _nameController.text = user.name;
    _usernameController.text = user.username ?? '';
    _emailController.text = account?.email ?? '';
    _aboutController.text = user.about ?? '';
    _websiteController.text = user.website ?? '';
    _color = user.color;
    return user;
  }

  void _reload() => setState(() => _user = _load());

  /// Where pages live, shown in front of the username.
  String get _pageHost {
    final host = Uri.tryParse(AppConfig.appUrl)?.host ?? '';
    return host.isEmpty ? 'kahwa' : host;
  }

  Future<void> _save(AppUser user) async {
    final name = _nameController.text.trim();
    final about = _aboutController.text.trim();
    final website = _websiteController.text.trim();

    final typed = Username.normalize(_usernameController.text);
    final username = typed.isEmpty ? null : typed;

    setState(() {
      _nameError = name.isEmpty ? 'Name cannot be empty' : null;
      _usernameError = username == null ? null : Username.validate(username);
    });
    if (_nameError != null || _usernameError != null) return;

    setState(() => _isLoading = true);
    try {
      final isFree = await userRepository.setUsername(
        userId: user.id,
        username: username,
        previous: switch (_savedUsername) {
          null => user.username,
          '' => null,
          final saved => saved,
        },
      );
      if (!mounted) return;
      if (!isFree) {
        setState(() => _usernameError = 'This username is taken');
        return;
      }
      _savedUsername = username ?? '';
      await userRepository.updateProfile(
        AppUser(
          id: user.id,
          name: name,
          about: about.isEmpty ? null : about,
          website: website.isEmpty ? null : website,
          color: _color,
        ),
      );
      if (mounted) showSnack(context, 'Updated successfully');
    } catch (_) {
      if (mounted) showSnack(context, 'Could not save, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.settings,
      body: AsyncBody(
        future: _user,
        onRetry: _reload,
        builder: (context, user) {
          return PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle('Profile'),
                const SizedBox(height: 40),
                Center(
                  child: UserAvatar(
                    name: _nameController.text,
                    radius: context.isCompact ? 64 : 80,
                    color: _color.color,
                  ),
                ),
                const SizedBox(height: 40),
                InputText(
                  controller: _nameController,
                  title: 'Name',
                  hint: 'John Doe',
                  icon: Icons.person_rounded,
                  errorText: _nameError,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _usernameController,
                  title: 'Username',
                  subtitle:
                      'The address of your page: $_pageHost/'
                      '${_usernameController.text.isEmpty ? 'username' : Username.normalize(_usernameController.text)}',
                  hint: 'username',
                  icon: Icons.alternate_email_rounded,
                  errorText: _usernameError,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _emailController,
                  title: 'Email',
                  icon: Icons.mail_rounded,
                  readOnly: true,
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _aboutController,
                  title: 'About Me',
                  hint:
                      'Hey 👋 I just created a page here. You can now buy me '
                      'a kahwa!',
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _websiteController,
                  title: 'Website',
                  hint: 'example.com',
                  icon: Icons.link_rounded,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                const SectionTitle('Change your page theme'),
                const SizedBox(height: 16),
                ColorPicker(
                  selected: _color,
                  onChanged: (color) => setState(() => _color = color),
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Save',
                  isLoading: _isLoading,
                  onPressed: () => _save(user),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
