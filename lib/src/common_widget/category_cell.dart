import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class CategoryCell extends StatelessWidget {
  final Map cObj;
  final VoidCallback onTap;
  const CategoryCell({super.key, required this.cObj, required this.onTap });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: cObj["image"] != null && cObj["image"].toString().isNotEmpty
      ? Image.network(
          cObj["image"].toString(),
          width: 85,
          height: 85,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/dish.png',
              width: 85,
              height: 85,
              fit: BoxFit.cover,
            );
          },
        )
      : Image.asset(
          'assets/images/dish.png',
          width: 85,
          height: 85,
          fit: BoxFit.cover,
        ),
),
            const SizedBox(
              height: 8,
            ),
            Text(
              cObj["name"].length > 15
              ? cObj["name"].substring(0, 15) + '...'
              : cObj["name"],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}