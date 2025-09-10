import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/common/order_tracking_service.dart';
import 'package:dribbble_challenge/src/common_widget/round_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderTrackingView extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  
  const OrderTrackingView({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];
  
  @override
  void initState() {
    super.initState();
    loadOrders();
  }
  
  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Carregar pedidos para o restaurante atual
      orders = await OrderTrackingService.refreshOrdersForRestaurant(widget.restaurantId);
      
      print('Carregados ${orders.length} pedidos do restaurante ${widget.restaurantName}');
    } catch (e) {
      print('Erro ao carregar pedidos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }
  
  // Mapear status para cores e textos em português
  Map<String, Color> statusColors = {
    'PENDING': Colors.orange,
    'PROCESSING': Colors.blue,
    'READY': Colors.green,
    'DELIVERED': Colors.purple,
    'CANCELLED': Colors.red,
  };
  
  Map<String, String> statusText = {
    'PENDING': 'Pendente',
    'PROCESSING': 'Em preparo',
    'READY': 'Pronto para entrega',
    'DELIVERED': 'Entregue',
    'CANCELLED': 'Cancelado',
  };
  
  String getStatusText(String status) {
    return statusText[status] ?? status;
  }
  
  Color getStatusColor(String status) {
    return statusColors[status] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: TColor.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Acompanhar Pedidos",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.restaurantName,
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botão de atualizar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: loadOrders,
                      icon: Icon(
                        Icons.refresh,
                        color: TColor.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Conteúdo
            Expanded(
              child: isLoading 
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) 
                : orders.isEmpty 
                  ? _buildEmptyOrdersView()
                  : _buildOrdersList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyOrdersView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: TColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60,
                color: TColor.primary,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Título
            Text(
              "Nenhum pedido encontrado",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Descrição
            Text(
              "Você ainda não fez pedidos neste restaurante ou todos os seus pedidos já foram concluídos.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botão para voltar
            SizedBox(
              width: 200,
              child: RoundButton(
                title: "Fazer um pedido",
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final status = order['status'] ?? 'PENDING';
          
          return _buildOrderCard(order, index);
        },
      ),
    );
  }
  
  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final status = order['status'] ?? 'PENDING';
    final items = order['items'] ?? [];
    final createdAt = order['created_at'] ?? '';
    final totalAmount = order['total_amount'] ?? '0';
    final orderNumber = order['id'] ?? '';
    final uuid = order['uuid'] ?? '';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt,
                  color: getStatusColor(status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Pedido #${orderNumber}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getStatusText(status),
                    style: TextStyle(
                      color: getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Informações do pedido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data e hora
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: TColor.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatDateTime(createdAt),
                      style: TextStyle(
                        color: TColor.secondaryText,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Itens do pedido
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Itens do Pedido:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      items is List ? items.length : 0,
                      (i) {
                        final item = items[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                "${item['quantity']}x",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['product_name'] ?? "Item #${i + 1}",
                                ),
                              ),
                              Text(
                                "${double.parse(item['price'] ?? '0').toStringAsFixed(2)} MZN",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Linha divisória
                const Divider(),
                
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Total:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${double.parse(totalAmount.toString()).toStringAsFixed(2)} MZN",
                      style: TextStyle(
                        color: TColor.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                
                // Botão para verificar status atual
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Mostrar carregamento
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Verificando status atual..."),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      
                      // Verificar status atual
                      try {
                        Map<String, dynamic> updatedStatus = await OrderTrackingService.checkOrderStatus(uuid.isNotEmpty ? uuid : orderNumber.toString());
                        
                        if (updatedStatus.isNotEmpty && updatedStatus['order'] != null) {
                          // Atualizar lista
                          setState(() {
                            orders[index]['status'] = updatedStatus['order']['status'];
                            orders[index]['items'] = updatedStatus['order']['items'];
                          });
                          
                          // Mostrar status atualizado
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Status atualizado: ${getStatusText(updatedStatus['order']['status'] ?? 'PENDING')}",
                              ),
                              backgroundColor: getStatusColor(updatedStatus['order']['status'] ?? 'PENDING'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Não foi possível verificar o status atual"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Erro ao verificar status: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.refresh),
                    label: Text("Verificar Status"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
