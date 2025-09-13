import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class ViewAllTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  const ViewAllTitleRow({super.key, required this.title, required this.onView });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.length > 25 ? title.substring(0, 25) + '...' : title,
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w900),
        ),
        TextButton(
          onPressed: onView,
          child: Text(
            "",
            style: TextStyle(
                color: TColor.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}