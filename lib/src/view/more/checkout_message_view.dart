import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common_widget/round_button.dart';
import 'package:flutter/material.dart';

import '../../common/color_extension.dart';

class CheckoutMessageView extends StatefulWidget {
  const CheckoutMessageView({super.key});

  @override
  State<CheckoutMessageView> createState() => _CheckoutMessageViewState();
}

class _CheckoutMessageViewState extends State<CheckoutMessageView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return  Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        width: media.width,
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: TColor.primaryText,
                    size: 25,
                  ),
                )
              ],
            ),
            Image.asset(
              "assets/img/thank_you.png",
              width: media.width * 0.55,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              AppLocalizations.of(context).thankYou,
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              AppLocalizations.of(context).forYourOrder,
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              AppLocalizations.of(context).orderProcess,
              textAlign: TextAlign.center,
              style: TextStyle(color: TColor.primaryText, fontSize: 14),
            ),
            const SizedBox(
              height: 35,
            ),
            RoundButton(title: AppLocalizations.of(context).trackOrder, onPressed: () {}),
            TextButton(
              onPressed: () {},
              child: Text(
                AppLocalizations.of(context).backToHome,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      
    );
  }
}
