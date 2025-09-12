import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'service_call.dart';

/// Serviço singleton para gerenciar os dados do menu do restaurante
/// e evitar múltiplos carregamentos dos mesmos dados.
class MenuDataService {
  // Singleton instance
  static final MenuDataService _instance = MenuDataService._internal();
  factory MenuDataService() => _instance;
  MenuDataService._internal();

  // Estado dos dados
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // Dados em cache
  List _menuItems = [];
  List _events = [];
  List _dailySpecials = [];
  String _restaurantName = '';

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List get menuItems => _menuItems;
  List get events => _events;
  List get dailySpecials => _dailySpecials;
  String get restaurantName => _restaurantName;

  /// Inicializa o serviço carregando os dados do restaurante
  /// Retorna true se os dados foram carregados com sucesso ou já estavam carregados
  Future<bool> initialize() async {
    // Se já estiver inicializado, retorna imediatamente
    if (_isInitialized) {
      return true;
    }

    // Se já estiver carregando, aguarda a conclusão
    if (_isLoading) {
      // Espera até que _isLoading seja false
      int attempts = 0;
      while (_isLoading && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      return _isInitialized;
    }

    _isLoading = true;
    _error = null;

    try {
      // Carregar nome do restaurante
      final prefs = await SharedPreferences.getInstance();
      _restaurantName = prefs.getString('restaurant_name') ?? '';
      String? restaurantUUID = prefs.getString('restaurant_id');

      if (restaurantUUID == null || restaurantUUID.isEmpty) {
        _error = 'ID do restaurante não encontrado';
        _isLoading = false;
        return false;
      }

      // Usando um Completer para tornar a chamada assíncrona em síncrona
      final completer = Completer<bool>();

      // Carregar dados do menu e eventos
      ServiceCall.getMenuItems(restaurantUUID,
          withSuccess: (Map<String, dynamic> data) {
            // Processar menu
            if (data.containsKey('menu') && data['menu'] != null) {
              if (data['menu'] is List && (data['menu'] as List).isNotEmpty) {
                _menuItems = data['menu'];
                debugPrint("Menu carregado com ${_menuItems.length} categorias");
              }
            }

            // Processar eventos
            if (data.containsKey('events') && data['events'] != null) {
              if (data['events'] is List) {
                List rawEvents = data['events'];
                List formattedEvents = [];

                for (var event in rawEvents) {
                  formattedEvents.add({
                    "id": event['id'],
                    "image": event['image_url'] ?? "assets/img/offer_3.png",
                    "name": event['title'],
                    "description": event['description'],
                    "event_date": event['event_date'],
                    "type": event['type'],
                  });
                }
                _events = formattedEvents;
                debugPrint("Eventos carregados: ${_events.length}");
              }
            }

            // Processar daily_specials
            if (data.containsKey('daily_specials') && data['daily_specials'] != null) {
              if (data['daily_specials'] is List) {
                List rawDailySpecials = data['daily_specials'];
                List formattedDailySpecials = [];

                for (var special in rawDailySpecials) {
                  formattedDailySpecials.add({
                    "id": special['id'],
                    "image": special['image_url'] ?? "assets/img/offer_3.png",
                    "name": special['name'],
                    "description": special['description'],
                    "price": double.tryParse(special['price'].toString()) ?? 0.0,
                    "type": "daily_special",
                  });
                }
                _dailySpecials = formattedDailySpecials;
                debugPrint("Ofertas do dia carregadas: ${_dailySpecials.length}");
              }
            }

            _isInitialized = true;
            _isLoading = false;
            completer.complete(true);
          },
          failure: (String error) {
            debugPrint("Erro ao buscar dados: $error");
            _error = error;
            _isLoading = false;
            completer.complete(false);
          });

      return await completer.future;
    } catch (e) {
      debugPrint("Error loading menu data: $e");
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  /// Obtém uma lista de itens em promoção do menu
  List getPromotionItems() {
    if (!_isInitialized || _menuItems.isEmpty) {
      return [];
    }

    List promoItems = [];

    // Percorrer todas as categorias e produtos
    for (var category in _menuItems) {
      if (category['products'] != null) {
        List products = category['products'];

        for (var product in products) {
          // Verificar se o produto está em promoção
          if (product['is_on_promotion'] == true) {
            promoItems.add({
              "id": product['id'],
              "image": product['image_url'] ?? "assets/img/dess_1.png",
              "name": product['name'],
              "rate": "4.9",
              "rating": "124",
              "type": category['category_name'],
              "food_type": category['category_name'],
              "description": product['description'] ?? '',
              "price": double.tryParse(product['current_price'].toString()) ?? 0.0,
              "regular_price": double.tryParse(product['regular_price'].toString()) ?? 0.0,
              "is_on_promotion": true,
            });
          }
        }
      }
    }

    return promoItems;
  }

  /// Força uma atualização dos dados do menu
  Future<bool> refreshData() async {
    _isInitialized = false;
    return initialize();
  }

  /// Limpa os dados em cache
  void clearData() {
    _isInitialized = false;
    _menuItems = [];
    _events = [];
    _restaurantName = '';
    _error = null;
  }
}
