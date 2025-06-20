import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('pt'),
  ];

  // Strings gerais
  String get appName;
  String get loading;
  String get error;
  String get cancel;
  String get confirm;
  String get save;
  String get delete;
  String get edit;
  String get add;
  String get remove;
  String get clear;
  String get search;
  String get noResults;
  String get tryAgain;
  
  // Home screen
  String get hello;
  String get welcome;
  String get searchFood;
  String get mostPopular;
  String get menu;
  String get searchResults;
  String get noResultsFound;
  String get clearSearch;
  
  // Cart/Order
  String get myOrder;
  String get addToCart;
  String get removeFromCart;
  String get cart;
  String get checkout;
  String get total;
  String get subtotal;
  String get delivery;
  String get emptyCart;
  String get continueMenu;
  String get orderPlaced;
  
  // Restaurant info
  String get tableNumber;
  String get welcomeToRestaurant;
  String get menuDigital;
  
  // Language
  String get language;
  String get portuguese;
  String get english;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'pt':
        return AppLocalizationsPt();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}