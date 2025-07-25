// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dribbble_challenge/src/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedDescriptionWidget extends StatelessWidget {
  final Duration descriptionPlayDuration;
  final Duration descriptionDelayDuration;
  final String restaurantAddress; // ADICIONAR ESTE PARÂMETRO
  final String restaurantCity; // ADICIONAR ESTE PARÂMETRO

  const AnimatedDescriptionWidget({
    Key? key,
    required this.descriptionPlayDuration,
    required this.descriptionDelayDuration,
    required this.restaurantAddress, // ADICIONAR ESTE PARÂMETRO
    required this.restaurantCity, // ADICIONAR ESTE PARÂMETRO
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String locationText = '';
    if (restaurantAddress.isNotEmpty && restaurantCity.isNotEmpty) {
      locationText = '$restaurantAddress, $restaurantCity';
    } else if (restaurantAddress.isNotEmpty) {
      locationText = restaurantAddress;
    } else if (restaurantCity.isNotEmpty) {
      locationText = restaurantCity;
    } else {
      locationText = Strings.onBoardingSlogan; // Fallback para o texto original
    }

    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
        ),
        child: Text(
          locationText,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        )
            .animate()
            .slideY(
                begin: 0.1,
                end: 0,
                delay: 350.ms + 400.ms,
                duration: descriptionPlayDuration,
                curve: Curves.easeInOutCubic)
            .scaleXY(
                begin: 0,
                end: 1,
                delay: descriptionDelayDuration,
                duration: descriptionPlayDuration,
                curve: Curves.easeInOutCubic));
  }
}
