import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/widgets/page_body.dart';

class CreatorCard extends StatelessWidget {
  const CreatorCard({super.key, required this.creator, required this.onTap});

  final AppUser creator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = creator.color.color;
    final image = creator.image;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.square(
                  dimension: 56,
                  child: image != null
                      ? Image.network(image, fit: BoxFit.cover)
                      : ColoredBox(
                          color: color,
                          child: Center(
                            child: Text(
                              getInitials(creator.name),
                              style: TextStyle(color: foregroundOn(color)),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(creator.name),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text(plural(creator.fans.length, 'Fan')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
