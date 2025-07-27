import '../models/order_model.dart';

class OrderService {
  static Future<List<OrderModel>> getOrders() async {
    try {
      // Dados mock para desenvolvimento
      return _getMockOrders();
      
      // TODO: Implementar chamada real da API
    } catch (e) {
      print('Erro ao buscar pedidos: $e');
      return _getMockOrders();
    }
  }

  static List<OrderModel> _getMockOrders() {
    return [
      // First Floor - Pending
      OrderModel(
        id: '001',
        tableNumber: 20,
        floor: 'First',
        status: OrderStatus.pending,
        orderTime: DateTime.now().subtract(Duration(minutes: 15)),
        guestCount: 2,
        totalValue: 45.50,
        items: [
          OrderItem(id: '1', name: 'Large Pizza Veg', quantity: 1, price: 12.50, isServed: false),
          OrderItem(id: '2', name: 'Veg Burger', quantity: 2, price: 9.00, isServed: false),
        ],
      ),
      
      OrderModel(
        id: '002',
        tableNumber: 8,
        floor: 'First',
        status: OrderStatus.pending,
        orderTime: DateTime.now().subtract(Duration(minutes: 15)),
        guestCount: 2,
        totalValue: 32.00,
        items: [
          OrderItem(id: '3', name: 'Chicken Burger', quantity: 2, price: 15.00, isServed: false),
          OrderItem(id: '4', name: 'Coca Cola', quantity: 2, price: 2.50, isServed: false),
        ],
      ),

      // Ground Floor - Pending
      OrderModel(
        id: '003',
        tableNumber: 5,
        floor: 'Ground',
        status: OrderStatus.pending,
        orderTime: DateTime.now().subtract(Duration(minutes: 8)),
        guestCount: 4,
        totalValue: 85.00,
        items: [
          OrderItem(id: '5', name: 'Family Pizza', quantity: 1, price: 25.00, isServed: false),
          OrderItem(id: '6', name: 'Pasta Carbonara', quantity: 2, price: 18.00, isServed: false),
          OrderItem(id: '7', name: 'Caesar Salad', quantity: 1, price: 12.00, isServed: false),
        ],
      ),

      // Take Away - Pending
      OrderModel(
        id: '004',
        tableNumber: 999,
        floor: 'Take Away',
        status: OrderStatus.pending,
        orderTime: DateTime.now().subtract(Duration(minutes: 12)),
        guestCount: 1,
        totalValue: 18.50,
        items: [
          OrderItem(id: '8', name: 'Sandwich', quantity: 1, price: 8.50, isServed: false),
          OrderItem(id: '9', name: 'Coffee', quantity: 2, price: 5.00, isServed: false),
        ],
      ),

      // Preparing orders
      OrderModel(
        id: '005',
        tableNumber: 12,
        floor: 'First',
        status: OrderStatus.preparing,
        orderTime: DateTime.now().subtract(Duration(minutes: 25)),
        guestCount: 3,
        totalValue: 67.50,
        items: [
          OrderItem(id: '10', name: 'Steak', quantity: 1, price: 35.00, isServed: false),
          OrderItem(id: '11', name: 'French Fries', quantity: 2, price: 8.00, isServed: false),
          OrderItem(id: '12', name: 'Wine', quantity: 1, price: 15.00, isServed: false),
        ],
      ),

      OrderModel(
        id: '006',
        tableNumber: 3,
        floor: 'Ground',
        status: OrderStatus.preparing,
        orderTime: DateTime.now().subtract(Duration(minutes: 20)),
        guestCount: 2,
        totalValue: 28.00,
        items: [
          OrderItem(id: '13', name: 'Fish & Chips', quantity: 2, price: 14.00, isServed: false),
        ],
      ),

      // Completed orders
      OrderModel(
        id: '007',
        tableNumber: 7,
        floor: 'First',
        status: OrderStatus.completed,
        orderTime: DateTime.now().subtract(Duration(minutes: 35)),
        guestCount: 2,
        totalValue: 42.00,
        items: [
          OrderItem(id: '14', name: 'Risotto', quantity: 2, price: 21.00, isServed: false),
        ],
      ),
    ];
  }

  static Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      print('Atualizando pedido $orderId para status: $newStatus');
      return true;
    } catch (e) {
      print('Erro ao atualizar pedido: $e');
      return false;
    }
  }

  static Future<bool> markItemAsServed(String orderId, String itemId) async {
    try {
      print('Marcando item $itemId do pedido $orderId como servido');
      return true;
    } catch (e) {
      print('Erro ao marcar item como servido: $e');
      return false;
    }
  }
}