import 'package:flutter/material.dart';
import 'package:kahwa/enums/colors.dart';
import 'package:kahwa/models/user.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';

class CreatorCard extends StatelessWidget {
  const CreatorCard({
    Key? key,
    required this.creator,
  }) : super(key: key);

  final User creator;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        routeCreator,
        arguments: creator.id,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.square(
                  dimension: 56,
                  child: creator.image != null
                      ? Image(
                          image: NetworkImage(creator.image!),
                          fit: BoxFit.fitWidth,
                        )
                      : ColoredBox(
                          color: getColor(creator.color!),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              getInitials(creator.name!),
                              style: const TextStyle(
                                color: kWhiteColor,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              horizontalSpace(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creator.name!,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: kSemiBoldFontWeight,
                        ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                      ),
                      horizontalSpace(width: 4),
                      Text(
                          "${creator.fans!.length} ${creator.fans!.length == 1 ? "Fan" : "Fans"}"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
