import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class TabButtonWithBadge extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String icon;
  final bool isSelected;
  final int badgeCount;
  final bool showBadge;

  const TabButtonWithBadge({
    super.key, 
    required this.title, 
    required this.icon, 
    required this.onTap, 
    required this.isSelected,
    this.badgeCount = 0,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tab button base
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                width: 15,
                height: 15,
                color: isSelected ? TColor.primary : TColor.placeholder,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? TColor.primary : TColor.placeholder,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          
          // Badge (mostrado somente se tiver contador > 0 e showBadge = true)
          if (showBadge && badgeCount > 0)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
