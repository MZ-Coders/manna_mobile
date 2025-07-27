import 'package:dribbble_challenge/src/common/order_service.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import '../../models/order_model.dart';

class WaiterOrdersView extends StatefulWidget {
  const WaiterOrdersView({super.key});

  @override
  State<WaiterOrdersView> createState() => _WaiterOrdersViewState();
}

class _WaiterOrdersViewState extends State<WaiterOrdersView> with TickerProviderStateMixin {
  List<OrderModel> allOrders = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final orders = await OrderService.getOrders();
      setState(() {
        allOrders = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erro ao carregar pedidos: $e');
    }
  }

  List<OrderModel> _getOrdersByStatus(OrderStatus status) {
    return allOrders.where((order) => order.status == status).toList()
      ..sort((a, b) => a.orderTime.compareTo(b.orderTime));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TColor.primary),
            SizedBox(height: 16),
            Text('Carregando pedidos...', style: TextStyle(color: TColor.secondaryText)),
          ],
        ),
      );
    }

    final pendingOrders = _getOrdersByStatus(OrderStatus.pending);
    final preparingOrders = _getOrdersByStatus(OrderStatus.preparing);
    final completedOrders = _getOrdersByStatus(OrderStatus.completed);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(pendingOrders.length, preparingOrders.length, completedOrders.length),
          _buildNewOrderButton(),
          _buildTabBar(pendingOrders.length, preparingOrders.length, completedOrders.length),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(pendingOrders, OrderStatus.pending),
                _buildOrdersList(preparingOrders, OrderStatus.preparing),
                _buildOrdersList(completedOrders, OrderStatus.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int pending, int preparing, int completed) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PEDIDOS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TColor.primaryText,
                ),
              ),
              IconButton(
                onPressed: loadOrders,
                icon: Icon(Icons.refresh, color: TColor.primary),
                tooltip: 'Atualizar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewOrderButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _showNewOrderDialog,
        icon: Icon(Icons.add, color: TColor.white),
        label: Text(
          'Fazer Novo Pedido',
          style: TextStyle(
            color: TColor.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColor.primary,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(int pending, int preparing, int completed) {
    return Container(
      color: TColor.white,
      child: TabBar(
        controller: _tabController,
        labelColor: TColor.primary,
        unselectedLabelColor: TColor.secondaryText,
        indicatorColor: TColor.primary,
        indicatorWeight: 3,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pendentes'),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '($pending)',
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Preparando'),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '($preparing)',
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Prontos'),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '($completed)',
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  Widget _buildOrdersList(List<OrderModel> orders, OrderStatus status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: TColor.placeholder,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum pedido ${_getStatusText(status).toLowerCase()}',
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar por andar
    Map<String, List<OrderModel>> ordersByFloor = {};
    for (var order in orders) {
      ordersByFloor.putIfAbsent(order.floor, () => []).add(order);
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: ordersByFloor.entries.map((entry) {
        return _buildFloorSection(entry.key, entry.value, status);
      }).toList(),
    );
  }

  Widget _buildFloorSection(String floor, List<OrderModel> orders, OrderStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header do andar
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            floor == 'Take Away' ? 'Balcão' : '${floor} Floor',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TColor.secondaryText,
            ),
          ),
        ),
        
        // Lista de pedidos
        ...orders.map((order) => _buildOrderCard(order, status)),
        
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order, OrderStatus status) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: order.hasUrgentItems ? Colors.red : _getStatusColor(status).withOpacity(0.3),
          width: order.hasUrgentItems ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showOrderDetailsDialog(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone da mesa
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  order.floor == 'Take Away' ? Icons.takeout_dining : Icons.table_restaurant,
                  color: _getStatusColor(status),
                  size: 20,
                ),
              ),
              
              SizedBox(width: 12),
              
              // Informações principais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mesa ${order.tableDisplay}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: TColor.primaryText,
                          ),
                        ),
                        if (order.hasUrgentItems)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'URGENTE',
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: TColor.secondaryText),
                        SizedBox(width: 4),
                        Text(
                          order.timeElapsed,
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.restaurant_menu, size: 14, color: TColor.secondaryText),
                        SizedBox(width: 4),
                        Text(
                          '${order.pendingItemsCount} itens',
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Seta
              Icon(
                Icons.arrow_forward_ios,
                color: TColor.placeholder,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsSheet(order),
    );
  }

  Widget _buildOrderDetailsSheet(OrderModel order) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TColor.placeholder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    order.floor == 'Take Away' ? Icons.takeout_dining : Icons.table_restaurant,
                    color: _getStatusColor(order.status),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesa ${order.tableDisplay}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                        ),
                      ),
                      Text(
                        '${order.floor} • ${order.guestCount} pessoas • ${order.timeElapsed}',
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de itens
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _buildOrderItemTile(order, item);
              },
            ),
          ),
          
          // Total e ações
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                    Text(
                      order.formattedValue,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateOrderStatus(order, _getNextStatus(order.status));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getStatusColor(order.status),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getNextActionText(order.status),
                          style: TextStyle(
                            color: TColor.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Adicionar itens ao pedido
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(Icons.add, color: TColor.primaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(OrderModel order, OrderItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isServed ? Colors.green[50] : TColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isServed ? Colors.green.withOpacity(0.3) : TColor.placeholder.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Quantidade
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.isServed ? Colors.green : TColor.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Nome do item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColor.primaryText,
                    decoration: item.isServed ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Text(
                    item.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: TColor.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          
          // Status/Ação
         if (item.isServed)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: TColor.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Servido',
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: () => _markItemAsServed(order, item),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Marcar Servido',
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Métodos auxiliares
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendente';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.completed:
        return 'Pronto';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  OrderStatus _getNextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.pending:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.completed;
      case OrderStatus.completed:
        return OrderStatus.delivered;
      default:
        return current;
    }
  }

  String _getNextActionText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Enviar para Cozinha';
      case OrderStatus.preparing:
        return 'Marcar como Pronto';
      case OrderStatus.completed:
        return 'Marcar como Entregue';
      case OrderStatus.delivered:
        return 'Finalizar';
      default:
        return 'Próximo';
    }
  }

  // Ações
  void _showNewOrderDialog() {
    // TODO: Navegar para seleção de mesa + menu
    _showSuccessSnackBar('Funcionalidade de novo pedido em desenvolvimento...');
  }

  Future<void> _updateOrderStatus(OrderModel order, OrderStatus newStatus) async {
    try {
      final success = await OrderService.updateOrderStatus(order.id, newStatus);
      
      if (success) {
        _showSuccessSnackBar(
          'Pedido #${order.id} atualizado para ${_getStatusText(newStatus)}'
        );
        loadOrders(); // Recarregar dados
      } else {
        _showErrorSnackBar('Erro ao atualizar pedido');
      }
    } catch (e) {
      _showErrorSnackBar('Erro: $e');
    }
  }

  Future<void> _markItemAsServed(OrderModel order, OrderItem item) async {
    try {
      final success = await OrderService.markItemAsServed(order.id, item.id);
      
      if (success) {
        _showSuccessSnackBar('${item.name} marcado como servido');
        loadOrders(); // Recarregar dados
      } else {
        _showErrorSnackBar('Erro ao marcar item como servido');
      }
    } catch (e) {
      _showErrorSnackBar('Erro: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}