// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dribbble_challenge/src/core/constants/strings.dart';
import 'package:dribbble_challenge/src/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedTitleWidget extends StatelessWidget {
  final Duration titleDelayDuration;
  final Duration mainPlayDuration;
  final String restaurantName;

  const AnimatedTitleWidget({
    Key? key,
    required this.titleDelayDuration,
    required this.mainPlayDuration,
    required this.restaurantName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible( // Mudança principal: SizedBox por Flexible
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text.rich(
          TextSpan(
              style: Theme.of(context).textTheme.displaySmall,
              children: [
                TextSpan(
                  text: restaurantName.isNotEmpty ? restaurantName : Strings.onBoardingTitle,
                  style: TextStyle(color: AppColors.primarySpecial)
                ),
                TextSpan(
                    text: ' Menu Digital',
                    style: TextStyle(color: AppColors.timeLineColor)),
              ]),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible, // Permite overflow visível
        ),
      ),
    )
        .animate()
        .slideY(
            begin: -0.2,
            end: 0,
            delay: titleDelayDuration,
            duration: mainPlayDuration,
            curve: Curves.easeInOutCubic)
        .scaleXY(
            begin: 0,
            end: 1,
            delay: titleDelayDuration,
            duration: mainPlayDuration,
            curve: Curves.easeInOutCubic);
  }
}
