import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/models/category.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/creator_card.dart';
import 'package:kahwa/ui/labels.dart';
import 'package:kahwa/ui/widgets.dart';

enum _Sort { popular, newest }

/// Every creator page: search, filter by what they make, sort.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.category});

  final String? category;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _search = TextEditingController();
  late CreatorCategory? _category = CreatorCategory.fromName(widget.category);
  var _sort = _Sort.popular;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Profile> _filter(List<Profile> all) {
    final query = _search.text;
    // Your own page is in Me, not among the creators to discover.
    final me = ref.read(userIdProvider);
    final list = all
        .where((p) => p.id != me)
        .where((p) => _category == null || p.category == _category)
        .where((p) => p.matches(query))
        .toList();
    final far = DateTime(0);
    switch (_sort) {
      case _Sort.popular:
        list.sort((a, b) => b.fans.compareTo(a.fans));
      case _Sort.newest:
        list.sort((a, b) => (b.createdAt ?? far).compareTo(a.createdAt ?? far));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signedIn = ref.watch(userIdProvider) != null;
    final creators = ref.watch(creatorsProvider);

    return Scaffold(
      appBar: signedIn
          ? null
          : AppBar(
              title: Text(l10n.tabExplore),
              actions: [
                FilledButton(
                  onPressed: () => context.push(Routes.signIn),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
                  child: Text(l10n.signIn),
                ),
                const SizedBox(width: 16),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(creatorsProvider);
          await ref.read(creatorsProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PageFrame(
                maxWidth: 1080,
                padding: EdgeInsets.fromLTRB(20, signedIn ? 24 : 4, 20, 0),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (signedIn) ...[
                        Text(
                          l10n.exploreTitle,
                          style: context.text.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: l10n.clear,
                                  onPressed: () =>
                                      setState(() => _search.clear()),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: ChoiceChip(
                                selected: _category == null,
                                onSelected: (_) =>
                                    setState(() => _category = null),
                                label: Text(l10n.all),
                              ),
                            ),
                            for (final c in CreatorCategory.values)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: ChoiceChip(
                                  selected: _category == c,
                                  onSelected: (s) =>
                                      setState(() => _category = s ? c : null),
                                  avatar: Icon(
                                    c.icon,
                                    size: 18,
                                    color: _category == c
                                        ? context.colors.onPrimary
                                        : context.colors.primary,
                                  ),
                                  label: Text(categoryLabel(context, c)),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              creators.hasValue
                                  ? l10n.creatorsCount(
                                      _filter(creators.value!).length,
                                    )
                                  : '',
                              style: context.text.labelLarge?.copyWith(
                                color: context.kahwa.muted,
                              ),
                            ),
                          ),
                          DropdownButton<_Sort>(
                            value: _sort,
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(Radii.tile),
                            onChanged: (s) => setState(() => _sort = s!),
                            items: [
                              DropdownMenuItem(
                                value: _Sort.popular,
                                child: Text(l10n.sortPopular),
                              ),
                              DropdownMenuItem(
                                value: _Sort.newest,
                                child: Text(l10n.sortNewest),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            ...creators.when(
              skipLoadingOnRefresh: true,
              data: (all) {
                final list = _filter(all);
                if (list.isEmpty) {
                  return [
                    SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: l10n.noResultsTitle,
                        message: l10n.noResultsBody,
                      ),
                    ),
                  ];
                }
                return [
                  SliverLayoutBuilder(
                    builder: (context, constraints) {
                      // Lines up with the 1080 wide header above.
                      final width = constraints.crossAxisExtent;
                      final side = width > 1080
                          ? (width - 1080) / 2 + 20
                          : 20.0;
                      return SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: side,
                          vertical: 8,
                        ),
                        sliver: SliverGrid.extent(
                          maxCrossAxisExtent: 280,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.9,
                          children: [
                            for (final p in list) CreatorCard(profile: p),
                          ],
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ];
              },
              loading: () => [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
              error: (_, _) => [
                SliverToBoxAdapter(
                  child: ErrorView(
                    onRetry: () => ref.invalidate(creatorsProvider),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
