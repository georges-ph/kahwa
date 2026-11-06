import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/models/category.dart';
import 'package:kahwa/models/social_link.dart';
import 'package:kahwa/models/tier.dart';
import 'package:kahwa/theme/palette.dart';

/// The public page of a user. Everyone has one; it becomes a creator page,
/// listed on Explore, once a kahwa price is set.
class Profile {
  const Profile({
    required this.id,
    required this.name,
    this.username,
    this.tagline = '',
    this.about = '',
    this.category,
    this.emoji,
    this.color = 0xFF7B1424,
    this.cover = 0,
    this.links = const [],
    this.priceLbp,
    this.priceUsd,
    this.tiers = const [],
    this.thanks = '',
    this.fanIds = const [],
    this.onboarded = false,
    this.createdAt,
  });

  final String id;
  final String name;

  /// Lower case handle, the address of the page: `kahwa.app/nour`.
  final String? username;

  /// One line under the name, such as "Illustrator in Beirut".
  final String tagline;
  final String about;
  final CreatorCategory? category;

  /// Picked instead of a picture. Initials are shown when null.
  final String? emoji;

  /// ARGB of the page color.
  final int color;

  /// Index of the pattern drawn on the banner, see `CoverPattern`.
  final int cover;
  final List<SocialLink> links;

  /// Price of one kahwa. Both are set together when the page opens.
  final int? priceLbp;
  final int? priceUsd;

  /// Monthly memberships offered on the page, cheapest first.
  final List<Tier> tiers;

  /// Shown to a supporter right after they buy a kahwa.
  final String thanks;
  final List<String> fanIds;

  /// Whether the user went through the first setup.
  final bool onboarded;
  final DateTime? createdAt;

  bool get isCreator => priceLbp != null && priceUsd != null;

  int get fans => fanIds.length;

  int? price(Currency currency) {
    return currency == Currency.lbp ? priceLbp : priceUsd;
  }

  Tier? tier(String id) => tiers.where((t) => t.id == id).firstOrNull;

  bool isFan(String? userId) => userId != null && fanIds.contains(userId);

  /// Matches a search typed on Explore: name, username or tagline.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final handle = q.startsWith('@') ? q.substring(1) : q;
    return name.toLowerCase().contains(q) ||
        (username?.contains(handle) ?? false) ||
        tagline.toLowerCase().contains(q);
  }

  Profile copyWith({
    String? name,
    String? Function()? username,
    String? tagline,
    String? about,
    CreatorCategory? Function()? category,
    String? Function()? emoji,
    int? color,
    int? cover,
    List<SocialLink>? links,
    int? Function()? priceLbp,
    int? Function()? priceUsd,
    List<Tier>? tiers,
    String? thanks,
    bool? onboarded,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      username: username == null ? this.username : username(),
      tagline: tagline ?? this.tagline,
      about: about ?? this.about,
      category: category == null ? this.category : category(),
      emoji: emoji == null ? this.emoji : emoji(),
      color: color ?? this.color,
      cover: cover ?? this.cover,
      links: links ?? this.links,
      priceLbp: priceLbp == null ? this.priceLbp : priceLbp(),
      priceUsd: priceUsd == null ? this.priceUsd : priceUsd(),
      tiers: tiers ?? this.tiers,
      thanks: thanks ?? this.thanks,
      fanIds: fanIds,
      onboarded: onboarded ?? this.onboarded,
      createdAt: createdAt,
    );
  }

  /// Fields the owner edits. The id, fans and creation time are left out:
  /// they are only written when the profile is created.
  Map<String, dynamic> toEditableMap() {
    return {
      'name': name,
      'username': username,
      'tagline': tagline,
      'about': about,
      'category': category?.name,
      'emoji': emoji,
      'color': color,
      'cover': cover,
      'links': [for (final link in links) link.toMap()],
      'price_lbp': priceLbp,
      'price_usd': priceUsd,
      'is_creator': isCreator,
      'tiers': {for (final tier in tiers) tier.id: tier.toMap()},
      'thanks': thanks,
      'onboarded': onboarded,
    };
  }

  Map<String, dynamic> toNewMap() {
    return {
      ...toEditableMap(),
      'id': id,
      'fan_ids': <String>[],
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map, {required String id}) {
    final tiers = <Tier>[
      if (map['tiers'] case final Map<String, dynamic> tierMap)
        for (final entry in tierMap.entries)
          if (entry.value case final Map<String, dynamic> value)
            Tier.fromMap(value, id: entry.key),
    ]..sort((a, b) => a.kahwas.compareTo(b.kahwas));
    final color = (map['color'] as num?)?.toInt();

    return Profile(
      id: id,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? map['name']
          : 'kahwa user',
      username: map['username'] as String?,
      tagline: map['tagline'] as String? ?? '',
      about: map['about'] as String? ?? '',
      category: CreatorCategory.fromName(map['category']),
      emoji: (map['emoji'] as String?)?.isNotEmpty == true
          ? map['emoji']
          : null,
      color: color != null && creatorColors.any((c) => c.toARGB32() == color)
          ? color
          : creatorColors.first.toARGB32(),
      cover: (map['cover'] as num?)?.toInt() ?? 0,
      links: [
        if (map['links'] case final List<dynamic> links)
          for (final link in links)
            if (link case final Map<String, dynamic> linkMap)
              ?SocialLink.fromMap(linkMap),
      ],
      priceLbp: (map['price_lbp'] as num?)?.toInt(),
      priceUsd: (map['price_usd'] as num?)?.toInt(),
      tiers: tiers,
      thanks: map['thanks'] as String? ?? '',
      fanIds: List<String>.from(map['fan_ids'] ?? const []),
      onboarded: map['onboarded'] == true,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
    );
  }
}
