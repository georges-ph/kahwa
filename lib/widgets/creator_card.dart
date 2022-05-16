import 'package:flutter/material.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';

class CreatorCard extends StatelessWidget {
  const CreatorCard({
    Key? key,
    required this.creator,
  }) : super(key: key);

  final user_model.User creator;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        routeCreator,
        arguments: creator.id,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.square(
                  dimension: 64,
                  child: creator.image != null
                      ? Image(
                          image: NetworkImage(
                              "https://images.unsplash.com/photo-1650038132376-5bb0e549e19f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=685&q=80"),
                          fit: BoxFit.fitWidth,
                        )
                      : ColoredBox(
                          color: kBrownColor,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              getInitials(creator.name!),
                              style: TextStyle(
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
                      Image(
                        image: AssetImage("assets/fenjen.png"),
                        width: 24,
                      ),
                      horizontalSpace(width: 8),
                      Text(
                        "70 kahwas received",
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.favorite_border_rounded),
                      horizontalSpace(width: 8),
                      Text("${creator.fans!.length} Fans"),
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
