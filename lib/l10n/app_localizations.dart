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
  String get offers;
  
  // Restaurant info
  String get tableNumber;
  String get welcomeToRestaurant;
  String get menuDigital;
  
  // Language
  String get language;
  String get portuguese;
  String get english;

  // Order management
String get orderItems;
String get orderSummary;
String get deliveryCost;
String get confirmOrderTitle;
String get orderProcess;
String get thankYou;
String get forYourOrder;
String get orderPlacedMessage;
String get trackOrder;
String get backToHome;
String get printBills;
String get tax;
String get continueShopping;
String get itemsInCart;
String get addSomeItems;

  //Food Details
  String get description;
  String get numberPortions;
  String get offerText;
  String get perPortion;
  String get adding;
  String get addedToCart;
  String get portions;
  String get promotion;
  String get totalPrice;
  String get findOffers;

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