// lib/src/models/order_model.dart

import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final int tableNumber;
  final String floor;
  final OrderStatus status;
  final DateTime orderTime;
  final List<OrderItem> items;
  final double totalValue;
  final int guestCount;
  final String? notes;
  final String? waiterId;
  
  // Novos campos da API
  final String? uuid;
  final String? tableName;
  final String? tableUuid;
  final String? paymentMethod;
  final String? customerName;
  final String? customerPhone;
  final int? itemsCount;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.tableNumber,
    required this.floor,
    required this.status,
    required this.orderTime,
    required this.items,
    required this.totalValue,
    required this.guestCount,
    this.notes,
    this.waiterId,
    // Novos campos opcionais
    this.uuid,
    this.tableName,
    this.tableUuid,
    this.paymentMethod,
    this.customerName,
    this.customerPhone,
    this.itemsCount,
    this.updatedAt,
  });
  
factory OrderModel.fromApiJson(Map<String, dynamic> json) {
  // Dados básicos do pedido
  String orderId = json['id']?.toString() ?? '0';
  String orderUuid = json['uuid'] ?? '';
  String apiStatus = (json['status'] ?? 'PENDING').toString().toUpperCase();
  double totalAmount = double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0;
  
  // Dados da mesa (pode ser null para Take Away)
  int tableNumber = 0;
  String tableName = '';
  String tableUuid = '';
  String floor = 'Take Away'; // Default para Take Away
  
  if (json['table'] != null && json['table'] is Map) {
    final tableData = json['table'] as Map<String, dynamic>;
    int tableId = tableData['id'] ?? 0;
    tableName = tableData['name'] ?? 'Mesa $tableId';
    tableUuid = tableData['uuid'] ?? '';
    
    // CORREÇÃO: Extrair número da mesa do nome ou mapear por nome conhecido
    tableNumber = _extractTableNumberFromName(tableName, tableId);
    
    // Determinar floor baseado no número da mesa
    floor = _determineFloorByNumber(tableNumber);
    
    print('🏷️ Mesa: ID=$tableId, Nome="$tableName", Número Extraído=$tableNumber, Floor=$floor');
  } else {
    // Take Away order
    tableNumber = 999;
    tableName = 'Take Away';
    floor = 'Take Away';
  }
  
  // Dados do usuário/garçom
  String? waiterName;
  if (json['user'] != null && json['user'] is Map) {
    final userData = json['user'] as Map<String, dynamic>;
    waiterName = userData['name'];
  }
  
  // Converter status da API
  OrderStatus status = _convertApiStatusToOrderStatus(apiStatus);
  
  // Dados de tempo
  DateTime orderTime = DateTime.now();
  DateTime? updatedTime;
  
  try {
    if (json['created_at'] != null) {
      orderTime = DateTime.parse(json['created_at']);
    }
    if (json['updated_at'] != null) {
      updatedTime = DateTime.parse(json['updated_at']);
    }
  } catch (e) {
    print('Erro ao parsear datas: $e');
  }
  
  // Converter itens do pedido
  List<OrderItem> orderItems = [];
  if (json['order_items'] != null && json['order_items'] is List) {
    List itemsJson = json['order_items'];
    orderItems = itemsJson.map((itemJson) {
      return OrderItem.fromApiJson(itemJson);
    }).toList();
  }
  
  // Calcular número de convidados (estimativa baseada na quantidade de itens)
  int guestCount = 1;
  if (orderItems.isNotEmpty) {
    int totalQuantity = orderItems.fold(0, (sum, item) => sum + item.quantity);
    guestCount = (totalQuantity / 2).ceil().clamp(1, 8); // Estimativa
  }
  
  print('📋 Pedido convertido: #$orderId - Mesa $tableNumber "$tableName" ($apiStatus -> $status) - MT $totalAmount');
  
  return OrderModel(
    id: orderId,
    uuid: orderUuid,
    tableNumber: tableNumber,
    tableName: tableName,
    tableUuid: tableUuid,
    floor: floor,
    status: status,
    orderTime: orderTime,
    updatedAt: updatedTime,
    items: orderItems,
    totalValue: totalAmount,
    guestCount: guestCount,
    waiterId: waiterName,
    paymentMethod: json['payment_method'],
    customerName: json['customer_name'],
    customerPhone: json['customer_phone'],
    itemsCount: json['items_count'],
  );
}

// NOVO MÉTODO: Extrair número da mesa do nome
static int _extractTableNumberFromName(String tableName, int fallbackId) {
  // Tentar extrair número do nome
  RegExp numberRegex = RegExp(r'(\d+)');
  Match? match = numberRegex.firstMatch(tableName);
  
  if (match != null) {
    int extractedNumber = int.parse(match.group(1)!);
    print('🔢 Número extraído do nome "$tableName": $extractedNumber');
    return extractedNumber;
  }
  
  // Mapeamento para nomes conhecidos sem números explícitos
  Map<String, int> nameMapping = {
    'Mesa da Entrada': 1,
    'Mesa Principal': 2,
    'Mesa do Canto': 3,
    'Mesa da Janela': 4,
    'Mesa Central': 5,
    'Mesa VIP': 6,
    'Mesa Família': 7,
    'Mesa Privada': 8,
    'Mesa Reservada': 9,
    'Mesa Especial': 10,
  };
  
  // Tentar mapear por nome
  for (String knownName in nameMapping.keys) {
    if (tableName.toLowerCase().contains(knownName.toLowerCase())) {
      int mappedNumber = nameMapping[knownName]!;
      print('🗺️ Mesa mapeada "$tableName" -> Mesa $mappedNumber');
      return mappedNumber;
    }
  }
  
  // Se não conseguir extrair, usar uma lógica baseada no ID da API
  // Para evitar números muito altos, usar módulo
  int calculatedNumber = (fallbackId % 50) + 1; // Vai dar números de 1 a 50
  print('⚙️ Número calculado para "$tableName" (ID $fallbackId): $calculatedNumber');
  
  return calculatedNumber;
}

// MÉTODO CORRIGIDO: Determinar floor baseado no número da mesa
static String _determineFloorByNumber(int tableNumber) {
  if (tableNumber >= 999) return 'Take Away';
  if (tableNumber >= 11 && tableNumber <= 20) return 'Second';
  if (tableNumber >= 21) return 'Third';
  return 'First'; // Mesas 1-10 no primeiro andar
}
  // Converter de JSON da API - baseado em OrdeResponse.json
  // Método original para compatibilidade
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(),
      tableNumber: json['table_id'] ?? 0,
      floor: json['floor'] ?? 'Ground',
      status: _parseOrderStatus(json['status']),
      orderTime: DateTime.parse(json['order_time']),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalValue: (json['total_value'] ?? 0).toDouble(),
      guestCount: json['guest_count'] ?? 1,
      notes: json['notes'],
      waiterId: json['waiter_id'],
    );
  }

  /// Converter status da API para OrderStatus enum
  static OrderStatus _convertApiStatusToOrderStatus(String apiStatus) {
    switch (apiStatus.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
        return OrderStatus.completed;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'COMPLETED':
        return OrderStatus.delivered; // Consideramos completed como delivered
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Determinar floor baseado no número da mesa
  static String _determineFloor(int tableNumber) {
    if (tableNumber >= 999) return 'Take Away';
    if (tableNumber >= 20) return 'Second';
    return 'First';
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'preparing':
        return OrderStatus.preparing;
      case 'completed':
      case 'ready':
        return OrderStatus.completed;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get timeElapsed {
    final now = DateTime.now();
    final difference = now.difference(orderTime);
    
    if (difference.inHours > 0) {
      return '${difference.inHours.toString().padLeft(2, '0')}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}';
    } else {
      return '00:${difference.inMinutes.toString().padLeft(2, '0')}';
    }
  }

  String get formattedValue => 'MT ${totalValue.toStringAsFixed(0)}'; // Usar meticais

  String get tableDisplay {
    if (floor == 'Take Away') return 'TA';
    return tableName?.isNotEmpty == true ? tableName! : tableNumber.toString();
  }

  int get pendingItemsCount => items.where((item) => !item.isServed).length;

  bool get hasUrgentItems {
    final now = DateTime.now();
    final urgentTime = now.subtract(Duration(minutes: 15));
    return orderTime.isBefore(urgentTime) && status == OrderStatus.pending;
  }

  // Nome de exibição do cliente
  String get displayCustomer {
    if (customerName?.isNotEmpty == true) {
      return customerName!;
    }
    if (customerPhone?.isNotEmpty == true) {
      return customerPhone!;
    }
    return 'Cliente';
  }

  // Método de pagamento formatado
  String get displayPaymentMethod {
    switch (paymentMethod?.toUpperCase()) {
      case 'CASH':
        return 'Dinheiro';
      case 'MPESA':
        return 'M-Pesa';
      case 'CARD':
        return 'Cartão';
      default:
        return paymentMethod ?? '--';
    }
  }

  // Para converter para JSON (se necessário)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'table_id': tableNumber,
      'table_name': tableName,
      'floor': floor,
      'status': status.toString().split('.').last,
      'order_time': orderTime.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'total_value': totalValue,
      'guest_count': guestCount,
      'notes': notes,
      'waiter_id': waiterId,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items_count': itemsCount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}


extension OrderModelExtensions on OrderModel {
  
  /// Formatação do tempo do pedido
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(orderTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${orderTime.day}/${orderTime.month} ${orderTime.hour}:${orderTime.minute.toString().padLeft(2, '0')}';
    }
  }
  
  /// Formatação do total
  String get formattedTotal {
    return 'MT ${totalValue.toStringAsFixed(2)}';
  }
  
  /// Tempo decorrido desde o pedido
  String get timeElapsed {
    final now = DateTime.now();
    final difference = now.difference(orderTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '${hours}h ${minutes}min';
    }
  }
  
  /// Status do pedido em português
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendente';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.completed:
        return 'Concluído';
      default:
        return 'Desconhecido';
    }
  }
  
  /// Cor do status
  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  /// Verifica se todos os itens foram servidos
  bool get allItemsServed {
    return items.every((item) => item.isServed);
  }
  
  /// Quantidade de itens servidos
  int get servedItemsCount {
    return items.where((item) => item.isServed).length;
  }
  
  /// Progresso de servir itens (0.0 a 1.0)
  double get servingProgress {
    if (items.isEmpty) return 0.0;
    return servedItemsCount / items.length;
  }
}


class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final bool isServed;
  final String? notes;
  
  // Novos campos da API
  final String? uuid;
  final int? productId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.isServed,
    this.notes,
    // Novos campos opcionais
    this.uuid,
    this.productId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Converter de JSON da API - baseado em order_items do OrdeResponse.json
  factory OrderItem.fromApiJson(Map<String, dynamic> json) {
    String itemId = json['id']?.toString() ?? '0';
    String itemUuid = json['uuid'] ?? '';
    String productName = json['product_name'] ?? 'Item';
    int quantity = json['quantity'] ?? 1;
    double priceSnapshot = double.tryParse(json['price_snapshot']?.toString() ?? '0') ?? 0.0;
    String? notes = json['notes'];
    String apiStatus = (json['status'] ?? 'PENDING').toString().toUpperCase();
    int? productId = json['product_id'];
    
    // Converter status para isServed
    bool isServed = _convertApiStatusToIsServed(apiStatus);
    
    // Datas
    DateTime? createdAt;
    DateTime? updatedAt;
    
    try {
      if (json['created_at'] != null) {
        createdAt = DateTime.parse(json['created_at']);
      }
      if (json['updated_at'] != null) {
        updatedAt = DateTime.parse(json['updated_at']);
      }
    } catch (e) {
      print('Erro ao parsear datas do item: $e');
    }
    
    return OrderItem(
      id: itemId,
      uuid: itemUuid,
      name: productName,
      quantity: quantity,
      price: priceSnapshot,
      isServed: isServed,
      notes: notes,
      productId: productId,
      status: apiStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Método original para compatibilidade
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      isServed: json['is_served'] ?? false,
      notes: json['notes'],
    );
  }

  /// Converter status da API para isServed
  static bool _convertApiStatusToIsServed(String apiStatus) {
    switch (apiStatus.toUpperCase()) {
      case 'DELIVERED':
        return true;
      case 'READY':
        return true;
      case 'PENDING':
      case 'PREPARING':
      default:
        return false;
    }
  }

  String get formattedPrice => 'MT ${price.toStringAsFixed(0)}'; // Usar meticais

  String get totalFormattedPrice => 'MT ${(price * quantity).toStringAsFixed(0)}';

  // Status de exibição
  String get displayStatus {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return 'Pendente';
      case 'PREPARING':
        return 'Preparando';
      case 'READY':
        return 'Pronto';
      case 'DELIVERED':
        return 'Entregue';
      default:
        return status ?? 'Pendente';
    }
  }

  // Para converter para JSON (se necessário)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'quantity': quantity,
      'price': price,
      'is_served': isServed,
      'notes': notes,
      'product_id': productId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

enum OrderStatus {
  pending,    // Pedido feito, aguardando preparo
  preparing,  // Cozinha preparando
  completed,  // Pronto para servir
  delivered,  // Entregue ao cliente
  cancelled   // Cancelado
}

