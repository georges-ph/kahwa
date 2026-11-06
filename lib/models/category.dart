import 'package:flutter/material.dart';

/// What a creator makes, to browse creators on Explore.
enum CreatorCategory {
  art(Icons.palette_rounded),
  music(Icons.music_note_rounded),
  writing(Icons.edit_note_rounded),
  video(Icons.videocam_rounded),
  photography(Icons.photo_camera_rounded),
  gaming(Icons.sports_esports_rounded),
  podcast(Icons.mic_rounded),
  food(Icons.restaurant_rounded),
  education(Icons.school_rounded),
  tech(Icons.code_rounded),
  comedy(Icons.theater_comedy_rounded),
  community(Icons.diversity_3_rounded),
  other(Icons.auto_awesome_rounded);

  const CreatorCategory(this.icon);

  final IconData icon;

  static CreatorCategory? fromName(Object? name) {
    return CreatorCategory.values.where((c) => c.name == name).firstOrNull;
  }
}
