import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/table_model.dart';
import '../common/service_call.dart';

class WaiterService {
  static const String baseUrl = 'https://manna.software/api';

  // Buscar todas as mesas do restaurante
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