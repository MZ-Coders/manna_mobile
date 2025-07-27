import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class MenuItemRow extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;
  const MenuItemRow({super.key, required this.mObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Detectar se a tela é larga (web/tablet) ou estreita (mobile)
    bool isWideScreen = MediaQuery.of(context).size.width > 600;
    
    // Altura do item dependendo do tipo de tela
    double itemHeight = isWideScreen ? 180 : 200;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: mObj["image"] != null && mObj["image"].toString().isNotEmpty ?
              Image.network(
                mObj["image"].toString(),
                width: double.maxFinite,
                height: itemHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/dish.png',
                  width: double.maxFinite,
                  height: itemHeight,
                  fit: BoxFit.cover,
                );},
              ) : 
                Image.asset(
              'assets/images/dish.png',
              width: double.maxFinite,
              height: itemHeight,
              fit: BoxFit.cover,
            ),
            ),
            Container(
              width: double.maxFinite,
              height: itemHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black
                  ], 
                  begin: Alignment.topCenter, 
                  end: Alignment.bottomCenter
                )
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mObj["name"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: isWideScreen ? 16 : 18,
                      fontWeight: FontWeight.w700
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${mObj["price"]} MZN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.primary, 
                          fontSize: isWideScreen ? 18 : 24,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mObj["type"],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: TColor.white, 
                            fontSize: 11
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
