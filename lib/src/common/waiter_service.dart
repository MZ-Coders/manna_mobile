import 'package:dribbble_challenge/src/models/table_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item_model.dart';
import '../common/service_call.dart';
// import 'mobile_printer_service.dart';

class WaiterMenuService {
  // Buscar menu usando a mesma API que o cliente usa
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

      // Usar a mesma função que home_view.dart e offer_view.dart usam
      Map<String, List<MenuItemModel>> menuByCategory = {};
      
      await Future(() {
        ServiceCall.getMenuItems(restaurantUUID,
            withSuccess: (Map<String, dynamic> data) {
              if (data.containsKey('menu') && data['menu'] != null) {
                if (data['menu'] is List && (data['menu'] as List).isNotEmpty) {
                  List allMenuItems = data['menu'];
                  menuByCategory = _convertApiDataToMenuItems(allMenuItems);
                  print("Menu do garçom carregado com ${allMenuItems.length} categorias");
                }
              }
            },
            failure: (String error) {
              print("Erro ao buscar menu para garçom: $error");
              menuByCategory = _getMockMenu(); // Fallback
            });
      });
      
      // Se não conseguiu dados da API, usar mock
      if (menuByCategory.isEmpty) {
        return _getMockMenu();
      }
      
      print('Menu carregado com sucesso: ${menuByCategory.length} categorias');
      print('Itens no menu: ${menuByCategory.values.expand((x) => x).length}');

      
      return menuByCategory;
      
    } catch (e) {
      print('Erro ao buscar menu: $e');
      return _getMockMenu();
    }
  }

  // Converter dados da API para MenuItemModel
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
            regularPrice: double.tryParse(product['regular_price']?.toString() ?? '0') ?? 0.0,
            description: product['description'] ?? '',
            imageUrl: product['image_url'],
            isOnPromotion: product['is_on_promotion'] ?? false,
            preparationTime: _estimatePreparationTime(categoryName), // Estimar tempo baseado na categoria
            isPopular: _checkIfPopular(product), // Verificar se é popular
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

  // Estimar tempo de preparo baseado na categoria
  static int _estimatePreparationTime(String category) {
    switch (category.toLowerCase()) {
      case 'bebidas':
      case 'drinks':
        return 3;
      case 'entradas':
      case 'starters':
      case 'appetizers':
        return 8;
      case 'sobremesas':
      case 'desserts':
        return 6;
      case 'pratos principais':
      case 'main course':
      case 'principais':
        return 15;
      case 'saladas':
      case 'salads':
        return 5;
      default:
        return 10;
    }
  }

  // Verificar se o item é popular (baseado em promoção ou outros critérios)
  static bool _checkIfPopular(Map<String, dynamic> product) {
    // Por enquanto, considerar itens em promoção como populares
    // Você pode adicionar outros critérios aqui
    return product['is_on_promotion'] == true;
  }

  // Buscar menu com callback (para compatibilidade com widgets existentes)
  static Future<void> getMenuWithCallback({
    required Function(Map<String, List<MenuItemModel>>) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      Map<String, List<MenuItemModel>> menu = await getMenuByCategory();
      onSuccess(menu);
    } catch (e) {
      onError(e.toString());
    }
  }

  // Buscar apenas itens de uma categoria específica
  static Future<List<MenuItemModel>> getItemsByCategory(String categoryName) async {
    try {
      Map<String, List<MenuItemModel>> allMenu = await getMenuByCategory();
      return allMenu[categoryName] ?? [];
    } catch (e) {
      print('Erro ao buscar itens da categoria $categoryName: $e');
      return [];
    }
  }

  // Buscar itens populares de todas as categorias
  static Future<List<MenuItemModel>> getPopularItems() async {
    try {
      Map<String, List<MenuItemModel>> allMenu = await getMenuByCategory();
      List<MenuItemModel> popularItems = [];
      
      allMenu.forEach((category, items) {
        popularItems.addAll(items.where((item) => item.isPopular));
      });
      
      return popularItems;
    } catch (e) {
      print('Erro ao buscar itens populares: $e');
      return [];
    }
  }

  // Buscar itens em promoção
  static Future<List<MenuItemModel>> getPromotionItems() async {
    try {
      Map<String, List<MenuItemModel>> allMenu = await getMenuByCategory();
      List<MenuItemModel> promotionItems = [];
      
      allMenu.forEach((category, items) {
        promotionItems.addAll(items.where((item) => item.isOnPromotion));
      });
      
      return promotionItems;
    } catch (e) {
      print('Erro ao buscar itens em promoção: $e');
      return [];
    }
  }

  // Dados mock para fallback/desenvolvimento
  static Map<String, List<MenuItemModel>> _getMockMenu() {
    return {
      'Entradas': [
        MenuItemModel(
          id: '1',
          name: 'Bruschetta',
          category: 'Entradas',
          price: 8.50,
          description: 'Pão italiano com tomate, manjericão e queijo',
          preparationTime: 5,
          isPopular: true,
        ),
        MenuItemModel(
          id: '2',
          name: 'Salada Caesar',
          category: 'Entradas',
          price: 12.00,
          description: 'Alface, croutons, parmesão e molho caesar',
          preparationTime: 8,
        ),
        MenuItemModel(
          id: '3',
          name: 'Sopa do Dia',
          category: 'Entradas',
          price: 6.50,
          preparationTime: 3,
        ),
      ],
      'Pratos Principais': [
        MenuItemModel(
          id: '11',
          name: 'Pizza Margherita',
          category: 'Pratos Principais',
          price: 18.50,
          description: 'Molho de tomate, mussarela, manjericão',
          preparationTime: 15,
          isPopular: true,
        ),
        MenuItemModel(
          id: '12',
          name: 'Hambúrguer Artesanal',
          category: 'Pratos Principais',
          price: 15.90,
          description: 'Carne 150g, queijo, salada, batata',
          preparationTime: 12,
          isPopular: true,
        ),
        MenuItemModel(
          id: '13',
          name: 'Salmão Grelhado',
          category: 'Pratos Principais',
          price: 28.00,
          description: 'Salmão com legumes e arroz',
          preparationTime: 18,
        ),
        MenuItemModel(
          id: '14',
          name: 'Risotto de Cogumelos',
          category: 'Pratos Principais',
          price: 22.50,
          preparationTime: 20,
        ),
        MenuItemModel(
          id: '15',
          name: 'Frango à Parmegiana',
          category: 'Pratos Principais',
          price: 19.90,
          preparationTime: 16,
        ),
      ],
      'Bebidas': [
        MenuItemModel(
          id: '21',
          name: 'Coca-Cola',
          category: 'Bebidas',
          price: 4.50,
          preparationTime: 1,
        ),
        MenuItemModel(
          id: '22',
          name: 'Suco Natural',
          category: 'Bebidas',
          price: 6.00,
          preparationTime: 3,
        ),
        MenuItemModel(
          id: '23',
          name: 'Água Mineral',
          category: 'Bebidas',
          price: 3.00,
          preparationTime: 1,
        ),
        MenuItemModel(
          id: '24',
          name: 'Café Expresso',
          category: 'Bebidas',
          price: 3.50,
          preparationTime: 2,
        ),
        MenuItemModel(
          id: '25',
          name: 'Vinho Tinto',
          category: 'Bebidas',
          price: 35.00,
          preparationTime: 2,
        ),
      ],
      'Sobremesas': [
        MenuItemModel(
          id: '31',
          name: 'Tiramisu',
          category: 'Sobremesas',
          price: 9.50,
          preparationTime: 3,
          isPopular: true,
        ),
        MenuItemModel(
          id: '32',
          name: 'Pudim de Leite',
          category: 'Sobremesas',
          price: 7.00,
          preparationTime: 3,
        ),
        MenuItemModel(
          id: '33',
          name: 'Sorvete (3 bolas)',
          category: 'Sobremesas',
          price: 8.50,
          preparationTime: 2,
        ),
      ],
    };
  }

  // Função para enviar pedido com impressão automática do recibo
  static Future<bool> submitOrder({
    required int tableNumber,
    required String floor,
    required List<CartItemModel> items,
    required int guestCount,
    String? notes,
    BuildContext? context,
  }) async {
    try {
      // 1. Primeiro enviar o pedido para a API
      print('Enviando pedido para mesa $tableNumber...');
      
      // TODO: Implementar envio real do pedido para a API
      // Exemplo de estrutura do pedido:
      Map<String, dynamic> orderData = {
        'table_number': tableNumber,
        'floor': floor,
        'guest_count': guestCount,
        'notes': notes,
        'items': items.map((item) => {
          'menu_item_id': item.menuItem.id,
          'quantity': item.quantity,
          'price': item.menuItem.price,
          'notes': item.notes,
        }).toList(),
        'total': _calculateTotal(items),
        'order_type': 'waiter', // Indicar que é pedido do garçom
        'created_at': DateTime.now().toIso8601String(),
      };

      // Simular envio para API (substituir por chamada real)
      await Future.delayed(Duration(seconds: 1));
      
      print('Pedido enviado com sucesso!');
      for (var item in items) {
        print('- ${item.quantity}x ${item.menuItem.name} (MT ${item.totalPrice.toStringAsFixed(2)})');
        if (item.notes?.isNotEmpty == true) {
          print('  Obs: ${item.notes}');
        }
      }
      print('Total: MT ${_calculateTotal(items).toStringAsFixed(2)}');
      
      // 2. Se o pedido foi enviado com sucesso, imprimir o recibo
      if (context != null) {
        try {
          print('Iniciando impressão do recibo...');
          
          // Obter nome do garçom das preferências
          final prefs = await SharedPreferences.getInstance();
          String? waiterName = prefs.getString('user_name');
          
          // Imprimir recibo usando o serviço de impressão móvel
          // await MobilePrinterService.printWaiterOrderReceipt(
          //   tableNumber: tableNumber,
          //   floor: floor,
          //   items: items,
          //   guestCount: guestCount,
          //   notes: notes,
          //   waiterName: waiterName,
          // );
          
          print('Recibo impresso com sucesso!');
          
          // Mostrar confirmação de sucesso
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Pedido enviado e recibo impresso com sucesso!'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
          
        } catch (printError) {
          print('Erro na impressão: $printError');
          
          // Mesmo com erro na impressão, o pedido foi enviado com sucesso
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pedido enviado com sucesso, mas houve erro na impressão.'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Tentar Imprimir',
                  textColor: Colors.white,
                  onPressed: () async {
                    // Tentar imprimir novamente
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      String? waiterName = prefs.getString('user_name');
                      
                        // await MobilePrinterService.printWithPrinterSelection(
                        //   context: context,
                        //   tableNumber: tableNumber,
                        //   floor: floor,
                        //   items: items,
                        //   guestCount: guestCount,
                        //   notes: notes,
                        //   waiterName: waiterName,
                        // );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro na impressão: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          }
        }
      }
      
      return true;
      
    } catch (e) {
      print('Erro ao enviar pedido: $e');
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      return false;
    }
  }

  // Função para reimprimir um recibo (útil se a primeira impressão falhar)
  static Future<void> reprintReceipt({
    required BuildContext context,
    required int tableNumber,
    required String floor,
    required List<CartItemModel> items,
    required int guestCount,
    String? notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? waiterName = prefs.getString('user_name');
      
      // await MobilePrinterService.printWithPrinterSelection(
      //   context: context,
      //   tableNumber: tableNumber,
      //   floor: floor,
      //   items: items,
      //   guestCount: guestCount,
      //   notes: notes,
      //   waiterName: waiterName,
      // );
      
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

  static double _calculateTotal(List<CartItemModel> items) {
    return items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  static Future<List<TableModel>> getTables() async {
    try {
      // Por enquanto, vamos simular dados enquanto não temos API específica
      return _getMockTables();
      
      // TODO: Implementar chamada real da API quando disponível
      // final response = await http.get(
      //   Uri.parse('$baseUrl/waiter/tables'),
      //   headers: {
      //     'Authorization': 'Bearer ${ServiceCall.userPayload['token']}',
      //     'Content-Type': 'application/json',
      //   },
      // );
      // 
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return (data['tables'] as List)
      //       .map((table) => TableModel.fromJson(table))
      //       .toList();
      // } else {
      //   throw Exception('Erro ao buscar mesas');
      // }
    } catch (e) {
      print('Erro ao buscar mesas: $e');
      return _getMockTables();
    }
  }

  // Dados mock para desenvolvimento/teste
  static List<TableModel> _getMockTables() {
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
        hasNotification: true, // Tem notificação urgente
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
      TableModel(
        number: 11,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 12,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 13,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 14,
        floor: 'First',
        status: TableStatus.empty,
      ),
      TableModel(
        number: 15,
        floor: 'First',
        status: TableStatus.paid,
        guestCount: 2,
        orderTime: DateTime.now().subtract(Duration(minutes: 34)),
        orderValue: 120.0,
        hasNotification: false,
      ),

      // Ground Floor
      TableModel(
        number: 20,
        floor: 'Ground',
        status: TableStatus.pending,
        guestCount: 2,
        orderTime: DateTime.now().subtract(Duration(minutes: 15)),
        orderValue: 120.0,
        hasNotification: false,
      ),
      TableModel(
        number: 21,
        floor: 'Ground',
        status: TableStatus.empty,
      ),

      // Take Away
      TableModel(
        number: 999, // Número especial para Take Away
        floor: 'Take Away',
        status: TableStatus.pending,
        guestCount: 1,
        orderTime: DateTime.now().subtract(Duration(minutes: 15)),
        orderValue: 120.0,
        hasNotification: false,
      ),
    ];
  }

  // Atualizar status da mesa
  static Future<bool> updateTableStatus(int tableNumber, TableStatus newStatus) async {
    try {
      // TODO: Implementar chamada real da API
      print('Atualizando mesa $tableNumber para status: $newStatus');
      return true;
    } catch (e) {
      print('Erro ao atualizar status da mesa: $e');
      return false;
    }
  }

}