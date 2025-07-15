import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class MostPopularCell extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;
  const MostPopularCell({super.key, required this.mObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: mObj["image"] != null && mObj["image"].toString().isNotEmpty
      ? Image.network(
          mObj["image"].toString(),
          width: 220,
          height: 130,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'images/dish.png',
              width: 220,
              height: 130,
              fit: BoxFit.cover,
            );
          },
        )
      : Image.asset(
          'image/dish.png',
          width: 220,
          height: 130,
          fit: BoxFit.cover,
        ),
),
            const SizedBox(
              height: 8,
            ),
            Text(
              mObj["name"].length > 20
              ? mObj["name"].substring(0, 20) + '...'
              : mObj["name"],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  mObj["type"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12),
                ),

                Text(
                " . ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.primary, fontSize: 12),
                ),

                Text(
                  mObj["food_type"],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.secondaryText, fontSize: 12),
                ),

                const SizedBox(
                  width: 8,
                ),
            
              //   Image.asset(
              //   "assets/img/rate.png",
              //   width: 10,
              //   height: 10,
              //   fit: BoxFit.cover,
              // ) ,
              const SizedBox(
                  width: 4,
                ),
                Text(
                  mObj["price"].toString()+"\MZN",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.primary, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
