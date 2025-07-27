class TableModel {
  final int number;
  final String floor;
  final TableStatus status;
  final int? guestCount;
  final DateTime? orderTime;
  final double? orderValue;
  final String? waiterId;
  final bool hasNotification;

  TableModel({
    required this.number,
    required this.floor,
    required this.status,
    this.guestCount,
    this.orderTime,
    this.orderValue,
    this.waiterId,
    this.hasNotification = false,
  });

  // Converter de JSON da API
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      number: json['number'] ?? 0,
      floor: json['floor'] ?? 'Ground',
      status: _parseStatus(json['status']),
      guestCount: json['guest_count'],
      orderTime: json['order_time'] != null 
          ? DateTime.parse(json['order_time']) 
          : null,
      orderValue: json['order_value']?.toDouble(),
      waiterId: json['waiter_id'],
      hasNotification: json['has_notification'] ?? false,
    );
  }

  static TableStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'occupied':
      case 'pending':
        return TableStatus.pending;
      case 'preparing':
        return TableStatus.preparing;
      case 'served':
        return TableStatus.served;
      case 'paid':
        return TableStatus.paid;
      case 'empty':
      default:
        return TableStatus.empty;
    }
  }

  // Calcular tempo decorrido desde o pedido
  String get timeElapsed {
    if (orderTime == null) return '--';
    
    final now = DateTime.now();
    final difference = now.difference(orderTime!);
    
    if (difference.inHours > 0) {
      return '${difference.inHours.toString().padLeft(2, '0')}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}';
    } else {
      return '00:${difference.inMinutes.toString().padLeft(2, '0')}';
    }
  }

  // Valor formatado
  String get formattedValue {
    if (orderValue == null) return '--';
    return '\$${orderValue!.toStringAsFixed(0)}';
  }
}

enum TableStatus {
  empty,
  pending,    // Pedido feito, aguardando preparo
  preparing,  // Cozinha preparando
  served,     // Servido, aguardando pagamento
  paid        // Pago, pode ser liberada
}