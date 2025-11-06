import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class CategoryCell extends StatelessWidget {
  final Map cObj;
  final VoidCallback onTap;
  final bool isSelected;
  
  const CategoryCell({
    super.key, 
    required this.cObj, 
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? TColor.primary : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: TColor.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : [],
            ),
            child: Text(
              cObj["name"].toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}