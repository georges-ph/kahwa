import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/creator_color.dart';
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
  final _emailController = TextEditingController();
  final _aboutController = TextEditingController();
  final _websiteController = TextEditingController();

  CreatorColor _color = CreatorColor.brown;
  String? _image;
  String? _nameError;

  bool _isLoading = false;

  /// Progress of the picture upload from 0 to 1, null when not uploading.
  double? _uploadProgress;

  @override
  void initState() {
    super.initState();
    _user = _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    _emailController.text = account?.email ?? user.email ?? '';
    _aboutController.text = user.about ?? '';
    _websiteController.text = user.website ?? '';
    _color = user.color;
    _image = account?.photoURL ?? user.image;
    return user;
  }

  void _reload() => setState(() => _user = _load());

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final Uint8List bytes;
    if (kIsWeb) {
      bytes = await picked.readAsBytes();
    } else {
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            cropStyle: CropStyle.circle,
            hideBottomControls: true,
          ),
        ],
      );
      if (cropped == null) return;
      bytes = await cropped.readAsBytes();
    }

    if (!mounted) return;
    setState(() => _uploadProgress = 0);
    try {
      final url = await userRepository.uploadProfilePicture(
        userId: authRepository.userId,
        bytes: bytes,
        onProgress: (progress) {
          if (mounted) setState(() => _uploadProgress = progress);
        },
      );
      if (mounted) setState(() => _image = url);
    } catch (_) {
      if (mounted) showSnack(context, 'Error uploading image');
    } finally {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  Future<void> _save(AppUser user) async {
    final name = _nameController.text.trim();
    final about = _aboutController.text.trim();
    final website = _websiteController.text.trim();

    setState(() => _nameError = name.isEmpty ? 'Name cannot be empty' : null);
    if (_nameError != null) return;

    setState(() => _isLoading = true);
    try {
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
                Center(child: _buildPicture(context)),
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

  Widget _buildPicture(BuildContext context) {
    final radius = context.isCompact ? 64.0 : 80.0;
    final progress = _uploadProgress;

    return Stack(
      children: [
        UserAvatar(
          name: _nameController.text,
          image: _image,
          radius: radius,
          color: _color.color,
        ),
        if (progress != null)
          Positioned.fill(
            child: CircularProgressIndicator(
              value: progress == 0 ? null : progress,
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton.filled(
            onPressed: progress == null ? _pickImage : null,
            tooltip: 'Change picture',
            icon: const Icon(Icons.camera_alt_rounded),
          ),
        ),
      ],
    );
  }
}
