import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/user_avatar.dart';

enum FansSupportersKind { fans, supporters }

/// The people who are fans of a creator or who supported them. Only the
/// creator can open the lists of their own page.
class FansSupportersScreen extends StatefulWidget {
  const FansSupportersScreen({
    super.key,
    required this.creatorId,
    required this.kind,
  });

  final String creatorId;
  final FansSupportersKind kind;

  @override
  State<FansSupportersScreen> createState() => _FansSupportersScreenState();
}

class _FansSupportersScreenState extends State<FansSupportersScreen> {
  late Future<List<AppUser>> _users;

  @override
  void initState() {
    super.initState();
    _users = _load();
  }

  Future<List<AppUser>> _load() async {
    final userId = authRepository.userId;
    if (userId != widget.creatorId) throw accessDenied();

    switch (widget.kind) {
      case FansSupportersKind.fans:
        final creator = await userRepository.getUser(widget.creatorId);
        return userRepository.getUsers(creator?.fans ?? const []);
      case FansSupportersKind.supporters:
        final donations = await donationRepository.getDonations(
          creatorId: widget.creatorId,
          viewerId: userId,
        );
        final supporters = <String, AppUser>{
          for (final item in donations)
            if (item.supporter != null) item.supporter!.id: item.supporter!,
        };
        return supporters.values.toList();
    }
  }

  void _reload() => setState(() => _users = _load());

  String _title(int count) {
    return switch (widget.kind) {
      FansSupportersKind.fans => plural(count, 'Fan'),
      FansSupportersKind.supporters => plural(count, 'Supporter'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _users,
      builder: (context, snapshot) {
        final users = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                context.canPop()
                    ? context.pop()
                    : context.go(Routes.creator(widget.creatorId));
              },
            ),
            title: users == null ? null : Text(_title(users.length)),
          ),
          body: AsyncBody(
            future: _users,
            onRetry: _reload,
            builder: (context, users) {
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ContentWidth.list,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: context.pagePadding,
                          vertical: 4,
                        ),
                        onTap: () => context.push(Routes.creator(user.id)),
                        leading: UserAvatar(
                          name: user.name,
                          image: user.image,
                          color: user.color.color,
                        ),
                        title: Text(user.name),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
