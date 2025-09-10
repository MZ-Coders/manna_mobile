import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './service_call.dart';

class OrderTrackingService {
  static const String _ordersKey = 'user_orders';
  
  // Salvar um novo pedido
  /// Salva (ou atualiza) um pedido localmente com todos os detalhes retornados pela API.
  /// - Se já existir (por id ou uuid), ele é substituído (mantendo saved_at original se existir).
  /// - Garante que o campo 'items' seja uma lista de mapas e preserva todos os atributos enviados.
  static Future<void> saveOrder(Map<String, dynamic> orderData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> orders = await getOrders();

      final dynamic rawId = orderData['id'];
      final String idStr = rawId?.toString() ?? '';
      final String uuidStr = (orderData['uuid'] ?? '').toString();

      int existingIndex = orders.indexWhere((o) =>
          (idStr.isNotEmpty && o['id']?.toString() == idStr) ||
          (uuidStr.isNotEmpty && (o['uuid']?.toString() == uuidStr)));

      // Normalizar items se vierem como 'items'
      if (orderData['items'] is List) {
        orderData['items'] = (orderData['items'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      // Adicionar timestamp se novo
      int now = DateTime.now().millisecondsSinceEpoch;
      if (existingIndex == -1) {
        orderData['saved_at'] = now;
        orders.add(orderData);
        print('Pedido salvo (novo) localmente: ID=${orderData['id']} UUID=${orderData['uuid']}');
      } else {
        // Preservar saved_at antigo
        final oldSavedAt = orders[existingIndex]['saved_at'];
        orderData['saved_at'] = oldSavedAt ?? now;
        orders[existingIndex] = orderData;
        print('Pedido atualizado localmente: ID=${orderData['id']} UUID=${orderData['uuid']}');
      }

      await prefs.setString(_ordersKey, jsonEncode(orders));
    } catch (e) {
      print('Erro ao salvar/atualizar pedido: $e');
    }
  }

  /// Recupera um pedido específico por ID numérico ou UUID.
  static Future<Map<String, dynamic>?> getOrderById(String idOrUuid) async {
    try {
      List<Map<String, dynamic>> orders = await getOrders();
      return orders.firstWhere(
        (o) => o['id']?.toString() == idOrUuid || o['uuid']?.toString() == idOrUuid,
        orElse: () => {},
      ).isEmpty ? null : orders.firstWhere(
        (o) => o['id']?.toString() == idOrUuid || o['uuid']?.toString() == idOrUuid,
      );
    } catch (e) {
      print('Erro ao recuperar pedido: $e');
      return null;
    }
  }
  
  // Obter todos os pedidos salvos
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? ordersJson = prefs.getString(_ordersKey);
      
      if (ordersJson == null || ordersJson.isEmpty) {
        return [];
      }
      
      List<dynamic> decodedList = jsonDecode(ordersJson);
      return decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Erro ao recuperar pedidos: $e');
      return [];
    }
  }
  
  // Obter pedidos de um restaurante específico
  static Future<List<Map<String, dynamic>>> getOrdersByRestaurant(String restaurantId) async {
    if (restaurantId.isEmpty) return [];
    
    try {
      List<Map<String, dynamic>> allOrders = await getOrders();
      
      return allOrders
        .where((order) => order['restaurant_id'] == restaurantId)
        .toList()
        ..sort((a, b) => (b['saved_at'] ?? 0).compareTo(a['saved_at'] ?? 0)); // Mais recentes primeiro
    } catch (e) {
      print('Erro ao filtrar pedidos por restaurante: $e');
      return [];
    }
  }
  
  // Verificar status de um pedido específico
  static Future<Map<String, dynamic>> checkOrderStatus(String orderId) async {
    try {
      // Usar um Completer para transformar o callback em Future
      final completer = Completer<Map<String, dynamic>>();
      
      ServiceCall.getOrderStatus(
        orderId,
        withSuccess: (Map<String, dynamic> data) {
          // Atualizar o pedido na lista local
          updateOrderStatus(orderId, data);
          
          // Resolver o completer com os dados
          completer.complete(data);
        },
        failure: (String error) {
          print('Erro ao verificar status do pedido: $error');
          completer.complete({});
        }
      );
      
      // Aguardar a conclusão da chamada assíncrona
      return await completer.future;
    } catch (e) {
      print('Erro ao verificar status: $e');
      return {};
    }
  }
  
  // Atualizar status de um pedido localmente
  static Future<void> updateOrderStatus(String orderId, Map<String, dynamic> statusData) async {
    try {
      List<Map<String, dynamic>> orders = await getOrders();
      
      int orderIndex = orders.indexWhere((order) => 
        order['id'].toString() == orderId || 
        order['uuid'].toString() == orderId);
      
      if (orderIndex != -1) {
        // Atualizar o pedido com as novas informações
        orders[orderIndex]['status'] = statusData['order']['status'];
        orders[orderIndex]['items'] = statusData['order']['items'];
        orders[orderIndex]['last_updated'] = DateTime.now().millisecondsSinceEpoch;
        
        // Salvar a lista atualizada
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_ordersKey, jsonEncode(orders));
        
        print('Status do pedido atualizado: $orderId - ${statusData['order']['status']}');
      }
    } catch (e) {
      print('Erro ao atualizar status do pedido: $e');
    }
  }
  
  // Verificar e atualizar todos os pedidos de um restaurante
  static Future<List<Map<String, dynamic>>> refreshOrdersForRestaurant(String restaurantId) async {
    try {
      List<Map<String, dynamic>> restaurantOrders = await getOrdersByRestaurant(restaurantId);
      
      // Atualizar apenas pedidos não finalizados (para economizar chamadas à API)
      List<String> activeStatusList = ['PENDING', 'PROCESSING', 'READY'];
      List<Map<String, dynamic>> updatedOrders = [];
      
      for (var order in restaurantOrders) {
        String orderId = order['uuid'] ?? order['id'].toString();
        String status = order['status'] ?? '';
        
        // Verificar apenas pedidos ativos (não concluídos/cancelados)
        if (activeStatusList.contains(status)) {
          Map<String, dynamic> updatedOrder = await checkOrderStatus(orderId);
          if (updatedOrder.isNotEmpty && updatedOrder.containsKey('order')) {
            updatedOrders.add(updatedOrder['order']);
          } else {
            updatedOrders.add(order);
          }
        } else {
          updatedOrders.add(order);
        }
      }
      
      return updatedOrders;
    } catch (e) {
      print('Erro ao atualizar pedidos: $e');
      return await getOrdersByRestaurant(restaurantId);
    }
  }
  
  // Limpar pedidos antigos (manter apenas os últimos 30 dias)
  static Future<void> cleanupOldOrders() async {
    try {
      List<Map<String, dynamic>> orders = await getOrders();
      
      // Manter apenas pedidos dos últimos 30 dias
      int thirtyDaysInMillis = 30 * 24 * 60 * 60 * 1000;
      int cutoffTime = DateTime.now().millisecondsSinceEpoch - thirtyDaysInMillis;
      
      List<Map<String, dynamic>> recentOrders = orders
        .where((order) => (order['saved_at'] ?? 0) > cutoffTime)
        .toList();
      
      if (orders.length != recentOrders.length) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_ordersKey, jsonEncode(recentOrders));
        print('Limpeza de pedidos antigos: removidos ${orders.length - recentOrders.length} pedidos');
      }
    } catch (e) {
      print('Erro ao limpar pedidos antigos: $e');
    }
  }
}
