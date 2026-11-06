import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kahwa/core/text.dart';

/// Where else a creator can be found.
enum LinkKind {
  instagram('Instagram', FontAwesomeIcons.instagram, 'instagram.com'),
  tiktok('TikTok', FontAwesomeIcons.tiktok, 'tiktok.com'),
  youtube('YouTube', FontAwesomeIcons.youtube, 'youtube.com'),
  x('X', FontAwesomeIcons.xTwitter, 'x.com'),
  facebook('Facebook', FontAwesomeIcons.facebook, 'facebook.com'),
  twitch('Twitch', FontAwesomeIcons.twitch, 'twitch.tv'),
  spotify('Spotify', FontAwesomeIcons.spotify, 'spotify.com'),
  soundcloud('SoundCloud', FontAwesomeIcons.soundcloud, 'soundcloud.com'),
  behance('Behance', FontAwesomeIcons.behance, 'behance.net'),
  github('GitHub', FontAwesomeIcons.github, 'github.com'),
  linkedin('LinkedIn', FontAwesomeIcons.linkedin, 'linkedin.com'),
  website('Website', FontAwesomeIcons.globe, '');

  const LinkKind(this.label, this.icon, this.host);

  final String label;
  final IconData icon;

  /// The site the link should point to, empty for any site.
  final String host;

  static LinkKind fromName(Object? name) {
    return LinkKind.values.firstWhere(
      (kind) => kind.name == name,
      orElse: () => LinkKind.website,
    );
  }

  /// The kind of link [url] most likely is, by its address.
  static LinkKind guess(String url) {
    final uri = parseLink(url);
    if (uri == null) return LinkKind.website;
    final host = uri.host.toLowerCase();
    bool isOn(String site) => host == site || host.endsWith('.$site');
    if (isOn('youtu.be')) return LinkKind.youtube;
    if (isOn('twitter.com')) return LinkKind.x;
    return LinkKind.values.firstWhere(
      (kind) => kind.host.isNotEmpty && isOn(kind.host),
      orElse: () => LinkKind.website,
    );
  }
}

class SocialLink {
  const SocialLink({required this.kind, required this.url});

  final LinkKind kind;
  final String url;

  Uri? get uri => parseLink(url);

  Map<String, dynamic> toMap() => {'kind': kind.name, 'url': url};

  static SocialLink? fromMap(Map<String, dynamic> map) {
    final url = map['url'];
    if (url is! String || parseLink(url) == null) return null;
    return SocialLink(kind: LinkKind.fromName(map['kind']), url: url);
  }
}
