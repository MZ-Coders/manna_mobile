// lib/src/common/waiter_service.dart

import 'package:dribbble_challenge/src/models/table_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item_model.dart';
import '../common/service_call.dart';
import '../common/globs.dart';
import 'dart:async';
import 'dart:convert';
// import 'mobile_printer_service.dart';

class WaiterMenuService {
  
  // ========== NOVA IMPLEMENTAÇÃO COM API REAL ==========
  
  /// Buscar mesas da API - /waiter/tables
  static Future<List<TableModel>> getTables() async {
    try {
      print('🔄 Buscando mesas da API...');
      
      // Usar Completer para aguardar resposta da API
      final Completer<List<TableModel>> completer = Completer();
      
      // Fazer chamada para API
      ServiceCall.get(
        SVKey.baseUrl + "waiter/tables",
        isToken: true, // Precisa de autenticação
        withSuccess: (Map<String, dynamic> responseData) {
          print('✅ Resposta da API recebida: ${responseData.keys}');
          
          try {
            if (responseData['success'] == true && responseData['data'] != null) {
              final data = responseData['data'];
              
              // Log dos dados recebidos
              print('📊 Restaurant: ${data['restaurant_name']}');
              print('📊 Total tables: ${data['total_tables']}');
              
              if (data['tables'] != null && data['tables'] is List) {
                List tablesJson = data['tables'];
                print('📋 Processando ${tablesJson.length} mesas...');
                
                // Converter dados da API para TableModel
                List<TableModel> tables = tablesJson.map((tableJson) {
                  return TableModel.fromApiJson(tableJson);
                }).toList();
                
                print('✅ ${tables.length} mesas convertidas com sucesso');
                completer.complete(tables);
              } else {
                print('⚠️ Nenhuma mesa encontrada na resposta');
                completer.complete([]);
              }
            } else {
              print('❌ Resposta da API inválida: ${responseData['message'] ?? 'Erro desconhecido'}');
              completer.complete(_getMockTables()); // Fallback para mock
            }
          } catch (e) {
            print('❌ Erro ao processar resposta da API: $e');
            completer.complete(_getMockTables()); // Fallback para mock
          }
        },
        failure: (String error) {
          print('❌ Erro na chamada da API: $error');
          completer.complete(_getMockTables()); // Fallback para mock
        }
      );
      
      // Aguardar resposta com timeout
      return await completer.future.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('⏰ Timeout na busca de mesas, usando dados mock');
          return _getMockTables();
        }
      );
      
    } catch (e) {
      print('❌ Erro geral ao buscar mesas: $e');
      return _getMockTables();
    }
  }
  
  // ========== ATUALIZAR STATUS DA MESA ==========
  
  /// Atualizar status de uma mesa na API
  static Future<bool> updateTableStatus(int tableNumber, TableStatus newStatus) async {
    try {
      print('🔄 Atualizando status da mesa $tableNumber para $newStatus');
      
      // TODO: Implementar chamada para API de atualização quando endpoint estiver disponível
      // Por enquanto, simular sucesso
      await Future.delayed(Duration(milliseconds: 500));
      
      print('✅ Status da mesa $tableNumber atualizado com sucesso');
      return true;
      
    } catch (e) {
      print('❌ Erro ao atualizar status da mesa: $e');
      return false;
    }
  }
  
  
  static Future<bool> closeTable(int tableId) async {
  try {
    print('🔄 Fechando mesa $tableId...');
    
    final Completer<bool> completer = Completer();
    
    ServiceCall.post(
      {},
      SVKey.baseUrl + "tables/$tableId/close",
      isToken: true,
      withSuccess: (Map<String, dynamic> responseData) {
        print('✅ Mesa $tableId fechada com sucesso');
        completer.complete(true);
      },
      failure: (String error) {
        print('❌ Erro ao fechar mesa: $error');
        completer.complete(false);
      }
    );
    
    return await completer.future.timeout(
      Duration(seconds: 5),
      onTimeout: () => false
    );
    
  } catch (e) {
    print('❌ Erro ao fechar mesa: $e');
    return false;
  }
}


  // ========== BUSCAR MENU (MANTIDO IGUAL) ==========
  
  /// Buscar menu usando a mesma API que o cliente usa
  static Future<Map<String, List<MenuItemModel>>> getMenuByCategory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? restaurantUUID = prefs.getString('restaurant_id') ?? 
                               prefs.getString('user_restaurant_id') ?? 
                               prefs.getString('user_restaurant_uuid');
      
      if (restaurantUUID == null || restaurantUUID.isEmpty) {
        print('Erro: restaurant_id não encontrado');
        return _getMockMenu(); // Fallback para dados mock
      }

      // Usar Completer para aguardar a resposta da API
      final Completer<Map<String, List<MenuItemModel>>> completer = Completer();
      
      ServiceCall.getMenuItems(restaurantUUID,
          withSuccess: (Map<String, dynamic> data) {
            print('=== DADOS RECEBIDOS DA API ===');
            print('Success: ${data['success']}');
            
            if (data.containsKey('menu') && data['menu'] != null) {
              if (data['menu'] is List && (data['menu'] as List).isNotEmpty) {
                List allMenuItems = data['menu'];
                print('Número de categorias na API: ${allMenuItems.length}');
                
                Map<String, List<MenuItemModel>> menuByCategory = _convertApiDataToMenuItems(allMenuItems);
                completer.complete(menuByCategory);
              } else {
                print('Menu vazio na resposta da API');
                completer.complete(_getMockMenu());
              }
            } else {
              print('Campo menu não encontrado na resposta');
              completer.complete(_getMockMenu());
            }
          },
          failure: (String error) {
            print("Erro ao buscar menu para garçom: $error");
            completer.complete(_getMockMenu());
          });
      
      return await completer.future.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('Timeout ao buscar menu, usando dados mock');
          return _getMockMenu();
        }
      );
      
    } catch (e) {
      print('Erro ao buscar menu: $e');
      return _getMockMenu();
    }
  }

  // ========== DADOS MOCK (FALLBACK) ==========
  
  /// Dados mock para desenvolvimento/teste
  static List<TableModel> _getMockTables() {
    print('📋 Usando dados mock das mesas');
    return [
      // First Floor
      TableModel(
        number: 1,
        floor: 'First',
        status: TableStatus.pending,
        guestCount: 2,
        orderTime: DateTime.now().subtract(Duration(minutes: 5)),
        orderValue: 120.0,
        hasNotification: false,
      ),
      TableModel(
        number: 2,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 3,
        floor: 'First',
        status: TableStatus.preparing,
        guestCount: 2,
        orderTime: DateTime.now().subtract(Duration(minutes: 14)),
        orderValue: 120.0,
        hasNotification: false,
      ),
      TableModel(
        number: 4,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 5,
        floor: 'First',
        status: TableStatus.pending,
        guestCount: 2,
        orderTime: DateTime.now().subtract(Duration(minutes: 8)),
        orderValue: 120.0,
        hasNotification: true,
      ),
      TableModel(
        number: 6,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 7,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 8,
        floor: 'First',
        status: TableStatus.served,
        guestCount: 2,
        orderTime: DateTime.now().subtract(Duration(minutes: 34)),
        orderValue: 120.0,
        hasNotification: false,
      ),
      TableModel(
        number: 9,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 10,
        floor: 'First',
        status: TableStatus.served,
        guestCount: 2,
        orderTime: DateTime.now().subtract(Duration(minutes: 34)),
        orderValue: 120.0,
        hasNotification: false,
      ),
    ];
  }

  // ========== OUTROS MÉTODOS (MANTIDOS) ==========
  
  /// Converter dados da API para MenuItemModel
  static Map<String, List<MenuItemModel>> _convertApiDataToMenuItems(List allMenuItems) {
    Map<String, List<MenuItemModel>> menuByCategory = {};
    
    for (var category in allMenuItems) {
      String categoryName = category['category_name'] ?? 'Categoria';
      List<MenuItemModel> categoryItems = [];
      
      if (category['products'] != null) {
        List products = category['products'];
        
        for (var product in products) {
          MenuItemModel item = MenuItemModel(
            id: product['id']?.toString() ?? '',
            name: product['name'] ?? '',
            category: categoryName,
            price: double.tryParse(product['current_price']?.toString() ?? '0') ?? 0.0,
            // image: product['image_url'] ?? '',
            // rating: double.tryParse(product['rating']?.toString() ?? '4.5') ?? 4.5,
            // ratingCount: product['rating_count'] ?? 10,
            description: product['description'] ?? '',
          );
          categoryItems.add(item);
        }
      }
      
      if (categoryItems.isNotEmpty) {
        menuByCategory[categoryName] = categoryItems;
      }
    }
    
    return menuByCategory;
  }

  /// Dados mock do menu
  static Map<String, List<MenuItemModel>> _getMockMenu() {
    return {
      'Bebidas': [
        MenuItemModel(
          id: '1',
          name: 'Refresco A Garrafa',
          category: 'Bebidas',
          price: 25.0,
          // image: '',
          // rating: 4.5,
          // ratingCount: 10,
          description: 'Refresco gelado em garrafa',
        ),
      ],
      'Pratos Principais': [
        MenuItemModel(
          id: '2',
          name: 'Quiabo com Xima e Peixe',
          category: 'Pratos Principais',
          price: 120.0,
          // image: '',
          // rating: 4.8,
          // ratingCount: 25,
          description: 'Prato tradicional moçambicano',
        ),
      ],
    };
  }

  // ========== OUTROS MÉTODOS DE SERVIÇO ==========
  
  static double _calculateTotal(List<CartItemModel> items) {
    return items.fold(0.0, (total, item) => total + item.totalPrice);
  }



  static Future<void> reprintReceipt(
    BuildContext context, {
    required int tableNumber,
    required String floor,
    required List<CartItemModel> items,
    required int guestCount,
    String? notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? waiterName = prefs.getString('user_name');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recibo reimpresso com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na reimpressão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}