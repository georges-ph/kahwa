import 'package:flutter/material.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/username.dart';
import 'package:kahwa/screens/creator_screen.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/sub_page.dart';

/// Opens the page of the creator who owns [username], for addresses like
/// `/rima`.
class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key, required this.username});

  final String username;

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  late Future<String?> _creatorId;

  @override
  void initState() {
    super.initState();
    _creatorId = _load();
  }

  @override
  void didUpdateWidget(UsernameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) _creatorId = _load();
  }

  Future<String?> _load() async {
    final username = Username.normalize(widget.username);
    if (Username.validate(username) != null) return null;
    return userRepository.getUserIdByUsername(username);
  }

  void _reload() => setState(() => _creatorId = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _creatorId,
      builder: (context, snapshot) {
        final creatorId = snapshot.data;
        if (creatorId != null) return CreatorScreen(creatorId: creatorId);

        return SubPage(
          fallback: Routes.home,
          body: AsyncBody(
            future: _creatorId,
            onRetry: _reload,
            builder: (context, _) {
              return const IllustratedMessage(
                asset: 'assets/undraw_not_found.svg',
                message: 'There is no page at this address',
              );
            },
          ),
        );
      },
    );
  }
}
