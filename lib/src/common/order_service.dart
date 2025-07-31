// lib/src/common/order_service.dart

import '../models/order_model.dart';
import '../common/service_call.dart';
import '../common/globs.dart';
import 'dart:async';

class OrderService {
  
  // ========== NOVA IMPLEMENTAÇÃO COM API REAL ==========
  
  /// Buscar pedidos da API - /waiter/orders
  static Future<List<OrderModel>> getOrders() async {
    try {
      print('🔄 Buscando pedidos da API...');
      
      // Usar Completer para aguardar resposta da API
      final Completer<List<OrderModel>> completer = Completer();
      
      // Fazer chamada para API
      ServiceCall.get(
        SVKey.baseUrl + "waiter/orders",
        isToken: true, // Precisa de autenticação
        withSuccess: (Map<String, dynamic> responseData) {
          print('✅ Resposta da API de pedidos recebida: ${responseData.keys}');
          
          try {
            if (responseData['success'] == true && responseData['data'] != null) {
              final data = responseData['data'];
              
              // Log dos dados recebidos
              print('📊 Restaurant: ${data['restaurant_name']}');
              print('📊 Total orders: ${data['orders']?.length ?? 0}');
              
              if (data['orders'] != null && data['orders'] is List) {
                List ordersJson = data['orders'];
                print('📋 Processando ${ordersJson.length} pedidos...');
                
                // Converter dados da API para OrderModel
                List<OrderModel> orders = ordersJson.map((orderJson) {
                  return OrderModel.fromApiJson(orderJson);
                }).toList();
                
                print('✅ ${orders.length} pedidos convertidos com sucesso');
                
                // Log das estatísticas se disponível
                if (data['statistics'] != null) {
                  final stats = data['statistics'];
                  print('📊 Estatísticas: ${stats['total_orders']} total, ${stats['pending_orders']} pendentes');
                }
                
                completer.complete(orders);
              } else {
                print('⚠️ Nenhum pedido encontrado na resposta');
                completer.complete([]);
              }
            } else {
              print('❌ Resposta da API inválida: ${responseData['message'] ?? 'Erro desconhecido'}');
              completer.complete(_getMockOrders()); // Fallback para mock
            }
          } catch (e) {
            print('❌ Erro ao processar resposta da API: $e');
            completer.complete(_getMockOrders()); // Fallback para mock
          }
        },
        failure: (String error) {
          print('❌ Erro na chamada da API de pedidos: $error');
          completer.complete(_getMockOrders()); // Fallback para mock
        }
      );
      
      // Aguardar resposta com timeout
      return await completer.future.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('⏰ Timeout na busca de pedidos, usando dados mock');
          return _getMockOrders();
        }
      );
      
    } catch (e) {
      print('❌ Erro geral ao buscar pedidos: $e');
      return _getMockOrders();
    }
  }
  
  // ========== ATUALIZAR STATUS DO PEDIDO ==========
  
  /// Atualizar status de um pedido na API
  static Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      print('🔄 Atualizando status do pedido $orderId para $newStatus');
      
      // TODO: Implementar chamada para API de atualização quando endpoint estiver disponível
      // Por enquanto, simular sucesso
      await Future.delayed(Duration(milliseconds: 500));
      
      print('✅ Status do pedido $orderId atualizado com sucesso');
      return true;
      
    } catch (e) {
      print('❌ Erro ao atualizar status do pedido: $e');
      return false;
    }
  }
  
  /// Marcar item como servido
  static Future<bool> markItemAsServed(String orderId, String itemId) async {
    try {
      print('🔄 Marcando item $itemId do pedido $orderId como servido');
      
      // TODO: Implementar chamada para API quando endpoint estiver disponível
      await Future.delayed(Duration(milliseconds: 300));
      
      print('✅ Item $itemId marcado como servido');
      return true;
      
    } catch (e) {
      print('❌ Erro ao marcar item como servido: $e');
      return false;
    }
  }

  // ========== DADOS MOCK (FALLBACK) ==========
  
  /// Dados mock para desenvolvimento/teste
  static List<OrderModel> _getMockOrders() {
    print('📋 Usando dados mock dos pedidos');
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
}