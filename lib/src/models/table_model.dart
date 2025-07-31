// lib/src/models/table_model.dart

class TableModel {
  final int number;
  final String floor;
  final TableStatus status;
  final int? guestCount;
  final DateTime? orderTime;
  final double? orderValue;
  final String? waiterId;
  final bool hasNotification;
  
  // Novos campos da API
  final int? id;              // ID da mesa na API
  final String? uuid;         // UUID da mesa
  final String? name;         // Nome da mesa (ex: "Mesa 1")
  final int? capacity;        // Capacidade da mesa
  final String? qrCodeUrl;    // URL do QR Code
  final int? restaurantId;    // ID do restaurante
  final DateTime? createdAt;  // Data de criação
  final DateTime? updatedAt;  // Data de atualização

  TableModel({
    required this.number,
    required this.floor,
    required this.status,
    this.guestCount,
    this.orderTime,
    this.orderValue,
    this.waiterId,
    this.hasNotification = false,
    // Novos campos opcionais
    this.id,
    this.uuid,
    this.name,
    this.capacity,
    this.qrCodeUrl,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
  });

  // Converter de JSON da API - baseado em MesasResponse.json
  factory TableModel.fromApiJson(Map<String, dynamic> json) {
    // Extrair dados básicos da mesa
    int tableId = json['id'] ?? 0;
    String tableName = json['name'] ?? 'Mesa ${tableId}';
    int tableCapacity = json['capacity'] ?? 4;
    String apiStatus = (json['status'] ?? 'FREE').toString().toUpperCase();
    
    // Converter status da API para TableStatus
    TableStatus status = _convertApiStatusToTableStatus(apiStatus);
    
    // Extrair número da mesa do nome (ex: "Mesa 5" -> 5)
    int tableNumber = tableId;
    try {
      RegExp regExp = RegExp(r'\d+');
      String? numberStr = regExp.firstMatch(tableName)?.group(0);
      if (numberStr != null) {
        tableNumber = int.parse(numberStr);
      }
    } catch (e) {
      tableNumber = tableId; // Fallback para ID
    }
    
    // Por enquanto, usar 'First' como floor padrão
    // TODO: Implementar lógica de floors se necessário
    String floor = 'First';
    
    return TableModel(
      number: tableNumber,
      floor: floor,
      status: status,
      capacity: tableCapacity,
      // Campos da API
      id: tableId,
      uuid: json['uuid'],
      name: tableName,
      qrCodeUrl: json['qr_code_url'],
      restaurantId: json['restaurant_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      // Dados que virão de outras APIs ou serão calculados
      guestCount: status == TableStatus.empty ? 0 : null,
      orderTime: null, // Será preenchido quando buscarmos os pedidos
      orderValue: 0.0,
      hasNotification: false,
    );
  }

  // Converter de JSON para compatibilidade com código antigo
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

  /// Converter status da API para TableStatus enum
  static TableStatus _convertApiStatusToTableStatus(String apiStatus) {
    switch (apiStatus.toUpperCase()) {
      case 'FREE':
        return TableStatus.empty;
      case 'OCCUPIED':
        return TableStatus.pending; // Mesa ocupada mas sem pedido específico
      case 'RESERVED':
        return TableStatus.preparing; // Mesa reservada, assumindo preparação
      default:
        return TableStatus.empty;
    }
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
    if (orderValue == null || orderValue == 0) return '--';
    return 'MT ${orderValue!.toStringAsFixed(0)}'; // Usar meticais
  }

  // Nome de exibição da mesa
  String get displayName {
    return name ?? 'Mesa $number';
  }

  // Capacidade de exibição
  String get displayCapacity {
    return capacity != null ? '$capacity pessoas' : '--';
  }

  // Para converter para JSON (se necessário)
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'floor': floor,
      'status': status.toString().split('.').last,
      'guest_count': guestCount,
      'order_time': orderTime?.toIso8601String(),
      'order_value': orderValue,
      'waiter_id': waiterId,
      'has_notification': hasNotification,
      // Campos da API
      'id': id,
      'uuid': uuid,
      'name': name,
      'capacity': capacity,
      'qr_code_url': qrCodeUrl,
      'restaurant_id': restaurantId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Criar cópia com campos atualizados
  TableModel copyWith({
    int? number,
    String? floor,
    TableStatus? status,
    int? guestCount,
    DateTime? orderTime,
    double? orderValue,
    String? waiterId,
    bool? hasNotification,
    int? id ,
    String? uuid,
    String? name,
    int? capacity,
    String? qrCodeUrl,
    int? restaurantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableModel(
      number: number ?? this.number,
      floor: floor ?? this.floor,
      status: status ?? this.status,
      guestCount: guestCount ?? this.guestCount,
      orderTime: orderTime ?? this.orderTime,
      orderValue: orderValue ?? this.orderValue,
      waiterId: waiterId ?? this.waiterId,
      hasNotification: hasNotification ?? this.hasNotification,
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum TableStatus {
  empty,      // Vazia/Livre
  pending,    // Pedido feito, aguardando preparo / Ocupada
  preparing,  // Cozinha preparando / Reservada
  served,     // Servido, aguardando pagamento
  paid        // Pago, pode ser liberada
}