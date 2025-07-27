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
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(),
      tableNumber: json['table_number'] ?? 0,
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

  String get formattedValue => '\$${totalValue.toStringAsFixed(0)}';

  String get tableDisplay => floor == 'Take Away' ? 'TA' : tableNumber.toString();

  int get pendingItemsCount => items.where((item) => !item.isServed).length;

  bool get hasUrgentItems {
    final now = DateTime.now();
    final urgentTime = now.subtract(Duration(minutes: 15));
    return orderTime.isBefore(urgentTime) && status == OrderStatus.pending;
  }
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final bool isServed;
  final String? notes;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.isServed,
    this.notes,
  });

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

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

enum OrderStatus {
  pending,    // Pedido feito, aguardando preparo
  preparing,  // Cozinha preparando
  completed,  // Pronto para servir
  delivered,  // Entregue ao cliente
  cancelled   // Cancelado
}