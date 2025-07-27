import '../models/menu_item_model.dart';

class WaiterMenuService {
  static Future<Map<String, List<MenuItemModel>>> getMenuByCategory() async {
    try {
      // Dados mock para desenvolvimento
      return _getMockMenu();
      
      // TODO: Implementar chamada real da API
    } catch (e) {
      print('Erro ao buscar menu: $e');
      return _getMockMenu();
    }
  }

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

  static Future<bool> submitOrder({
    required int tableNumber,
    required String floor,
    required List<CartItemModel> items,
    required int guestCount,
    String? notes,
  }) async {
    try {
      // TODO: Implementar envio real do pedido
      print('Enviando pedido para mesa $tableNumber:');
      for (var item in items) {
        print('- ${item.quantity}x ${item.menuItem.name}');
        if (item.notes?.isNotEmpty == true) {
          print('  Obs: ${item.notes}');
        }
      }
      print('Total: ${_calculateTotal(items)}');
      
      await Future.delayed(Duration(seconds: 1)); // Simular delay da API
      return true;
    } catch (e) {
      print('Erro ao enviar pedido: $e');
      return false;
    }
  }

  static double _calculateTotal(List<CartItemModel> items) {
    return items.fold(0.0, (total, item) => total + item.totalPrice);
  }
}