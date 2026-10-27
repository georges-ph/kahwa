import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/widgets/page_body.dart';

/// A grey box that tells the user something about the page, such as the
/// answer to their last request.
class Notice extends StatelessWidget {
  const Notice(this.text, {super.key, this.title});

  final String text;

  /// Shown in bold above [text], to say what the notice is about.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            SectionTitle(title!),
            const SizedBox(height: 4),
          ],
          Text(text),
        ],
      ),
    );
  }
}
