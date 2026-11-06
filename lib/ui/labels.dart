import 'package:flutter/widgets.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/core/username.dart';
import 'package:kahwa/models/category.dart';
import 'package:kahwa/ui/context.dart';

/// Names of things that come from enums, in the language of the app.
String categoryLabel(BuildContext context, CreatorCategory category) {
  final l10n = context.l10n;
  return switch (category) {
    CreatorCategory.art => l10n.categoryArt,
    CreatorCategory.music => l10n.categoryMusic,
    CreatorCategory.writing => l10n.categoryWriting,
    CreatorCategory.video => l10n.categoryVideo,
    CreatorCategory.photography => l10n.categoryPhotography,
    CreatorCategory.gaming => l10n.categoryGaming,
    CreatorCategory.podcast => l10n.categoryPodcast,
    CreatorCategory.food => l10n.categoryFood,
    CreatorCategory.education => l10n.categoryEducation,
    CreatorCategory.tech => l10n.categoryTech,
    CreatorCategory.comedy => l10n.categoryComedy,
    CreatorCategory.community => l10n.categoryCommunity,
    CreatorCategory.other => l10n.categoryOther,
  };
}

String usernameProblem(BuildContext context, UsernameProblem problem) {
  final l10n = context.l10n;
  return switch (problem) {
    UsernameProblem.length => l10n.usernameLength(
      Username.minLength,
      Username.maxLength,
    ),
    UsernameProblem.characters => l10n.usernameCharacters,
    UsernameProblem.reserved => l10n.usernameReserved,
    UsernameProblem.taken => l10n.usernameTaken,
  };
}

/// The name of [currency], such as "Lebanese lira".
String currencyName(BuildContext context, Currency currency) {
  return switch (currency) {
    Currency.lbp => context.l10n.currencyLbp,
    Currency.usd => context.l10n.currencyUsd,
  };
}
