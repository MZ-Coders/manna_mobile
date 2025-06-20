import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/l10n/language_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/color_extension.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations.of(context);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language,
        color: TColor.primaryText,
      ),
      onSelected: (String languageCode) {
        languageService.changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'pt',
          child: Row(
            children: [
              Text('🇧🇷'),
              const SizedBox(width: 8),
              Text(localizations.portuguese),
              if (languageService.currentLocale.languageCode == 'pt')
                const SizedBox(width: 8),
              if (languageService.currentLocale.languageCode == 'pt')
                Icon(Icons.check, color: TColor.primary, size: 16),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text('🇺🇸'),
              const SizedBox(width: 8),
              Text(localizations.english),
              if (languageService.currentLocale.languageCode == 'en')
                const SizedBox(width: 8),
              if (languageService.currentLocale.languageCode == 'en')
                Icon(Icons.check, color: TColor.primary, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}