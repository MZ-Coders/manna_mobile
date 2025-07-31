import 'package:dribbble_challenge/src/models/table_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item_model.dart';
import '../common/service_call.dart';
import 'dart:async';
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
                
                // Log detalhado dos dados
                for (int i = 0; i < allMenuItems.length; i++) {
                  var category = allMenuItems[i];
                  print('Categoria $i: ${category['category_name']} - ${(category['products'] as List?)?.length ?? 0} produtos');
                }
                
                final menuByCategory = _convertApiDataToMenuItems(allMenuItems);
                print('Menu convertido: ${menuByCategory.length} categorias');
                
                // Log das categorias convertidas  
                menuByCategory.forEach((categoryName, items) {
                  print('$categoryName: ${items.length} itens');
                });
                
                if (!completer.isCompleted) {
                  completer.complete(menuByCategory);
                }
              } else {
                print('Menu vazio ou inválido na API');
                if (!completer.isCompleted) {
                  completer.complete(_getMockMenu());
                }
              }
            } else {
              print('Resposta da API não contém menu válido');
              if (!completer.isCompleted) {
                completer.complete(_getMockMenu());
              }
            }
          },
          failure: (String error) {
            print("Erro ao buscar menu para garçom: $error");
            if (!completer.isCompleted) {
              completer.complete(_getMockMenu());
            }
          });
      
      // Timeout de 10 segundos
      return completer.future.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('Timeout ao buscar menu - usando dados mock');
          return _getMockMenu();
        },
      );
      
    } catch (e) {
      print('Erro ao buscar menu: $e');
      return _getMockMenu();
    }
  }

  // Converter dados da API para MenuItemModel - VERSÃO CORRIGIDA
  static Map<String, List<MenuItemModel>> _convertApiDataToMenuItems(List allMenuItems) {
    Map<String, List<MenuItemModel>> menuByCategory = {};
    
    print('=== CONVERTENDO DADOS DA API ===');
    
    for (int i = 0; i < allMenuItems.length; i++) {
      var category = allMenuItems[i];
      print('Processando categoria $i: ${category.toString()}');
      
      String categoryName = category['category_name']?.toString() ?? 'Categoria $i';
      List<MenuItemModel> categoryItems = [];
      
      if (category['products'] != null && category['products'] is List) {
        List products = category['products'] as List;
        print('Categoria "$categoryName" tem ${products.length} produtos');
        
        for (int j = 0; j < products.length; j++) {
          var product = products[j];
          print('Produto $j: ${product['name']} - Preço: ${product['current_price']}');
          
          try {
            MenuItemModel item = MenuItemModel(
              id: product['id']?.toString() ?? '$i-$j',
              name: product['name']?.toString() ?? 'Item sem nome',
              category: categoryName,
              price: _parsePrice(product['current_price']),
              regularPrice: _parsePrice(product['regular_price']),
              description: product['description']?.toString() ?? '',
              imageUrl: product['image_url']?.toString(),
              isOnPromotion: product['is_on_promotion'] == true,
              preparationTime: _estimatePreparationTime(categoryName),
              isPopular: _checkIfPopular(product),
            );
            
            categoryItems.add(item);
            print('Item adicionado: ${item.name} - ${item.formattedPrice}');
            
          } catch (e) {
            print('Erro ao converter produto $j da categoria "$categoryName": $e');
            // Continuar processamento mesmo com erro em um produto
          }
        }
      } else {
        print('Categoria "$categoryName" não tem produtos válidos');
      }
      
      if (categoryItems.isNotEmpty) {
        menuByCategory[categoryName] = categoryItems;
        print('Categoria "$categoryName" adicionada com ${categoryItems.length} itens');
      } else {
        print('Categoria "$categoryName" ignorada - sem itens válidos');
      }
    }
    
    print('=== CONVERSÃO CONCLUÍDA ===');
    print('Total de categorias: ${menuByCategory.length}');
    print('Categorias: ${menuByCategory.keys.toList()}');
    
    return menuByCategory;
  }

  // Função helper para converter preços de forma segura
  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    
    if (price is double) return price;
    if (price is int) return price.toDouble();
    
    if (price is String) {
      // Remover caracteres não numéricos exceto ponto e vírgula
      String cleanPrice = price.replaceAll(RegExp(r'[^\d.,]'), '');
      // Substituir vírgula por ponto para parsing
      cleanPrice = cleanPrice.replaceAll(',', '.');
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    
    return 0.0;
  }

  // Estimar tempo de preparo baseado na categoria
  static int _estimatePreparationTime(String category) {
    String categoryLower = category.toLowerCase();
    
    if (categoryLower.contains('bebida') || categoryLower.contains('drink')) {
      return 3;
    } else if (categoryLower.contains('entrada') || categoryLower.contains('lanche') || categoryLower.contains('snack')) {
      return 8;
    } else if (categoryLower.contains('sobremesa') || categoryLower.contains('dessert')) {
      return 6;
    } else if (categoryLower.contains('frango') || categoryLower.contains('chicken') || 
               categoryLower.contains('hambúrguer') || categoryLower.contains('burger')) {
      return 15;
    } else if (categoryLower.contains('salada') || categoryLower.contains('salad')) {
      return 5;
    } else {
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
        'table_id': tableNumber,
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

  // Resto do código permanece igual...
  static Future<List<TableModel>> getTables() async {
    try {
      // Por enquanto, vamos simular dados enquanto não temos API específica
      return _getMockTables();
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
      // ... resto dos dados mock
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