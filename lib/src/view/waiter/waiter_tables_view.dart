import 'package:dribbble_challenge/src/common/order_service.dart';
import 'package:dribbble_challenge/src/common/waiter_service.dart';
import 'package:dribbble_challenge/src/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import '../../models/table_model.dart';

class WaiterTablesView extends StatefulWidget {
  final Function(int tableNumber, String floor)? onTableAction;
  const WaiterTablesView({super.key, this.onTableAction});

  @override
  State<WaiterTablesView> createState() => _WaiterTablesViewState();
}

class _WaiterTablesViewState extends State<WaiterTablesView> {
  List<TableModel> allTables = [];
  List<TableModel> filteredTables = [];
  String selectedFloor = 'First';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTables();
  }

  Future<void> loadTables() async {
    setState(() {
      isLoading = true;
    });

    try {
      final tables = await WaiterMenuService.getTables();
      setState(() {
        allTables = tables;
        filterTablesByFloor();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erro ao carregar mesas: $e');
    }
  }

  void filterTablesByFloor() {
    setState(() {
      filteredTables = allTables
          .where((table) => table.floor == selectedFloor)
          .toList();
      
      filteredTables.sort((a, b) => a.number.compareTo(b.number));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildTopHeader(),
          // _buildFloorSelector(),
          Expanded(
            child: isLoading ? _buildLoadingState() : _buildTablesGrid(),
          ),
        ],
      ),
      // floatingActionButton: _buildFloatingActionButton(),
    );
  }

  

  Widget _buildTopHeader() {
    int totalTables = filteredTables.length;
    int occupiedTables = filteredTables
        .where((table) => table.status != TableStatus.empty)
        .length;
    int pendingTables = filteredTables
        .where((table) => table.status == TableStatus.pending)
        .length;
    int preparingTables = filteredTables
        .where((table) => table.status == TableStatus.preparing)
        .length;

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
          child: Column(
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MESAS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  IconButton(
                    onPressed: loadTables,
                    icon: Icon(Icons.refresh, color: TColor.primary),
                    tooltip: 'Atualizar',
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Cards de estatísticas
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Ocupadas',
                      '$occupiedTables/$totalTables',
                      Icons.people,
                      TColor.primary,
                      Colors.blue[50]!,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Pendentes',
                      pendingTables.toString(),
                      Icons.access_time,
                      Colors.orange,
                      Colors.orange[50]!,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Preparando',
                      preparingTables.toString(),
                      Icons.restaurant,
                      Colors.blue,
                      Colors.blue[50]!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorSelector() {
    List<String> floors = ['First', 'Second', 'Third', 'Ground', 'Take Away'];
    
    return Container(
      height: 60,
      color: TColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'Andar:',
              style: TextStyle(
                fontSize: 12,
                color: TColor.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: floors.map((floor) {
                bool isSelected = selectedFloor == floor;
                int floorTableCount = allTables
                    .where((table) => table.floor == floor)
                    .length;
                
                if (floorTableCount == 0) return SizedBox.shrink();
                
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFloor = floor;
                        filterTablesByFloor();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? TColor.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? TColor.primary : TColor.placeholder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            floor,
                            style: TextStyle(
                              color: isSelected ? TColor.white : TColor.secondaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? TColor.white.withOpacity(0.2) : TColor.placeholder.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              floorTableCount.toString(),
                              style: TextStyle(
                                color: isSelected ? TColor.white : TColor.secondaryText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
       
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TColor.primary),
          SizedBox(height: 16),
          Text(
            'Carregando mesas...',
            style: TextStyle(color: TColor.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesGrid() {
    if (filteredTables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant,
              size: 64,
              color: TColor.placeholder,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma mesa no andar $selectedFloor',
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: filteredTables.length,
        itemBuilder: (context, index) {
          return _buildEnhancedTableCard(filteredTables[index]);
        },
      ),
    );
  }

  Widget _buildEnhancedTableCard(TableModel table) {
    return GestureDetector(
      onTap: () => _showTableActionDialog(table),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _getTableBackgroundColor(table.status),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: table.status == TableStatus.empty 
                ? TColor.placeholder.withOpacity(0.3)
                : _getTableBorderColor(table.status),
            width: table.status == TableStatus.empty ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: table.status != TableStatus.empty
                  ? _getTableBorderColor(table.status).withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: table.status != TableStatus.empty ? 8 : 4,
              spreadRadius: table.status != TableStatus.empty ? 1 : 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Número da mesa
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  table.floor == 'Take Away' ? 'TA' : table.number.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryText,
                  ),
                ),
              ),
            ),
            
            // Notificação urgente com animação
            if (table.hasNotification)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            
            // Conteúdo principal
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (table.status != TableStatus.empty) ...[
                    // Ícone de pessoas + contagem
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TColor.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: TColor.primaryText,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${table.guestCount ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: TColor.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                  
                  // Status com cor de fundo
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTableBorderColor(table.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(table.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTableBorderColor(table.status),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Tempo e valor
                  if (table.status != TableStatus.empty) ...[
                    SizedBox(height: 6),
                    Text(
                      table.timeElapsed,
                      style: TextStyle(
                        fontSize: 11,
                        color: TColor.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      table.formattedValue,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showNewOrderDialog,
      backgroundColor: TColor.primary,
      icon: Icon(Icons.add, color: TColor.white),
      label: Text(
        'Novo Pedido',
        style: TextStyle(color: TColor.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Ações e Dialogs
  void _showTableActionDialog(TableModel table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTableActionSheet(table),
    );
  }

  Widget _buildTableActionSheet(TableModel table) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TColor.placeholder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              
              // Header da mesa
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTableBorderColor(table.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.table_restaurant,
                      color: _getTableBorderColor(table.status),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mesa ${table.floor == "Take Away" ? "Take Away" : table.number}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColor.primaryText,
                          ),
                        ),
                        Text(
                          '${table.floor} • ${_getStatusText(table.status)}',
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (table.hasNotification)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'URGENTE',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              if (table.status != TableStatus.empty) ...[
                SizedBox(height: 20),
                
                // Informações da mesa
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        'Clientes',
                        '${table.guestCount ?? 0}',
                        Icons.people,
                      ),
                      _buildInfoItem(
                        'Tempo',
                        table.timeElapsed,
                        Icons.access_time,
                      ),
                      _buildInfoItem(
                        'Valor',
                        table.formattedValue,
                        Icons.attach_money,
                      ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 20),
              
              // Ações
              if (table.status == TableStatus.empty)
                _buildActionButton(
                 'Ocupar Mesa',  // Novo texto
                  Icons.restaurant_menu,    // Novo ícone
                  TColor.primary,
                  () => _occupyTable(table),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Ver Pedido',
                        Icons.receipt_long,
                        Colors.blue,
                        () => _viewOrder(table),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        _getNextActionText(table.status),
                        _getNextActionIcon(table.status),
                        _getNextActionColor(table.status),
                        () => _nextAction(table),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildActionButton(
    'Adicionar Itens',
    Icons.add_shopping_cart,
    Colors.green,
    () {
      Navigator.pop(context);
      if (widget.onTableAction != null) {
        widget.onTableAction!(table.number, table.floor);
      }
    },
  ),
                SizedBox(height: 12),
                _buildActionButton(
                  'Liberar Mesa',
                  Icons.clear,
                  Colors.red,
                  () => _clearTable(table),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: TColor.primary, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColor.primaryText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: TColor.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: TColor.white, size: 18),
      label: Text(
        text,
        style: TextStyle(color: TColor.white, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Implementação das ações
 void _occupyTable(TableModel table) {
  Navigator.pop(context);
  _showGuestCountDialog(table);
}

void _showGuestCountDialog(TableModel table) {
  int guestCount = 1;
  
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Ocupar Mesa ${table.number}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quantos clientes?'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: guestCount > 1 ? () {
                    setDialogState(() => guestCount--);
                  } : null,
                  icon: Icon(Icons.remove),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: TColor.placeholder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    guestCount.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: guestCount < 10 ? () {
                    setDialogState(() => guestCount++);
                  } : null,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          // NOVO: Botão apenas para ocupar a mesa
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateTableStatus(table, TableStatus.pending, guestCount: guestCount);
              // Mostrar mensagem de sucesso
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mesa ${table.number} ocupada com ${guestCount} cliente(s)'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Ocupar Mesa', style: TextStyle(color: Colors.white)),
          ),
          // Botão para ocupar E ir para o menu
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateTableStatus(table, TableStatus.pending, guestCount: guestCount);
              
              // Navegar automaticamente para o menu
              if (widget.onTableAction != null) {
                widget.onTableAction!(table.number, table.floor);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
            ),
            child: Text('Ocupar e Fazer Pedido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

void _viewOrder(TableModel table) {
  Navigator.pop(context);
  _showTableOrdersModal(table);
}

void _showTableOrdersModal(TableModel table) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _buildTableOrdersSheet(table),
  );
}

Widget _buildTableOrdersSheet(TableModel table) {
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
          width: 40,
          height: 4,
          margin: EdgeInsets.only(top: 12),
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
                  color: _getTableBorderColor(table.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: _getTableBorderColor(table.status),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedidos - Mesa ${table.floor == "Take Away" ? "Take Away" : table.number}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                    Text(
                      '${table.floor} • ${_getStatusText(table.status)}',
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: TColor.secondaryText),
              ),
            ],
          ),
        ),
        
        // Lista de pedidos usando o novo método
        Expanded(
          child: FutureBuilder<List<OrderModel>>(
            future: OrderService.getOrdersByTable(table.id ?? 0), // Usar o novo método
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: TColor.primary),
                      SizedBox(height: 16),
                      Text(
                        'Carregando pedidos da mesa ${table.number}...',
                        style: TextStyle(color: TColor.secondaryText),
                      ),
                    ],
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Erro ao carregar pedidos',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: TextStyle(color: TColor.secondaryText, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Forçar rebuild para tentar novamente
                        },
                        child: Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }
              
              final tableOrders = snapshot.data ?? [];
              
              print('✅ Pedidos carregados para Mesa ${table.number}: ${tableOrders.length}');
              
              if (tableOrders.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: TColor.placeholder,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum pedido encontrado',
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Esta mesa ainda não fez nenhum pedido',
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          if (widget.onTableAction != null) {
                            widget.onTableAction!(table.number, table.floor);
                          }
                        },
                        icon: Icon(Icons.add_shopping_cart, color: TColor.white),
                        label: Text(
                          'Fazer Primeiro Pedido',
                          style: TextStyle(color: TColor.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primary,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: tableOrders.length,
                itemBuilder: (context, index) {
                  final order = tableOrders[index];
                  return _buildOrderCard(order, index == 0);
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildOrderCard(OrderModel order, bool isLatest) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: TColor.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isLatest ? TColor.primary : TColor.placeholder.withOpacity(0.3),
        width: isLatest ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do pedido
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getOrderStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getOrderStatusText(order.status),
                  style: TextStyle(
                    color: _getOrderStatusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              if (isLatest)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ATUAL',
                    style: TextStyle(
                      color: TColor.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Informações do pedido
          Row(
            children: [
              Expanded(
                child: _buildOrderInfo(
                  'Pedido',
                  '#${order.id}',
                  Icons.confirmation_number,
                ),
              ),
              Expanded(
                child: _buildOrderInfo(
                  'Horário',
                  order.formattedTime,
                  Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildOrderInfo(
                  'Total',
                  order.formattedTotal,
                  Icons.attach_money,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Lista de itens
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant_menu, size: 16, color: TColor.primary),
                    SizedBox(width: 6),
                    Text(
                      'Itens do Pedido (${order.items.length})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColor.primaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ...order.items.map((item) => _buildOrderItem(item, order)).toList(),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Ações do pedido
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (order.status == OrderStatus.pending)
                ElevatedButton.icon(
                  onPressed: () => _acceptOrder(order),
                  icon: Icon(Icons.restaurant, size: 16, color: TColor.white),
                  label: Text('Aceitar', style: TextStyle(color: TColor.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size(0, 32),
                  ),
                ),
              if (order.status == OrderStatus.preparing)
                ElevatedButton.icon(
                  onPressed: () => _setOrderReady(order),
                  icon: Icon(Icons.check_circle, size: 16, color: TColor.white),
                  label: Text('Pronto', style: TextStyle(color: TColor.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size(0, 32),
                  ),
                ),
              if (order.status == OrderStatus.completed)
                ElevatedButton.icon(
                  onPressed: () => _setOrderDelivered(order),
                  icon: Icon(Icons.room_service, size: 16, color: TColor.white),
                  label: Text('Entregue', style: TextStyle(color: TColor.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size(0, 32),
                  ),
                ),
              // if (order.status == OrderStatus.delivered)
              //   ElevatedButton.icon(
              //     onPressed: () => _setOrderCompleted(order),
              //     icon: Icon(Icons.check, size: 16, color: TColor.white),
              //     label: Text('Finalizar', style: TextStyle(color: TColor.white, fontSize: 12)),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.purple,
              //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //       minimumSize: Size(0, 32),
              //     ),
              //   ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildOrderInfo(String label, String value, IconData icon) {
  return Column(
    children: [
      Icon(icon, color: TColor.primary, size: 16),
      SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: TColor.primaryText,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: TColor.secondaryText,
        ),
      ),
    ],
  );
}

Widget _buildOrderItem(OrderItem item, OrderModel order) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        // Status do item
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getItemStatusColor(item.status ?? 'PENDING'),
            shape: BoxShape.circle,
          ),
          child: _getItemStatusIcon(item.status ?? 'PENDING'),
        ),
        SizedBox(width: 8),
        
        // Nome do item
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.quantity}x ${item.name}',
                style: TextStyle(
                  fontSize: 13,
                  color: TColor.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (item.notes?.isNotEmpty == true)
                Text(
                  'Obs: ${item.notes}',
                  style: TextStyle(
                    fontSize: 11,
                    color: TColor.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        
        // Preço
        Text(
          'MT ${(item.price * item.quantity).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: TColor.primary,
          ),
        ),
        
        SizedBox(width: 8),
        
        // Status badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getItemStatusColor(item.status ?? 'PENDING').withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getItemStatusText(item.status ?? 'PENDING'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getItemStatusColor(item.status ?? 'PENDING'),
            ),
          ),
        ),
      ],
    ),
  );
}

// Métodos auxiliares para ações dos pedidos
void _acceptOrder(OrderModel order) async {
  try {
    final success = await OrderService.acceptOrder(order.id);
    if (success) {
      _showSuccessSnackBar('Pedido #${order.id} aceito com sucesso');
      
      // Fechar modal
      Navigator.pop(context);
      
      // Recarregar dados e reabrir modal
      await loadTables();
      print('====ALL Tables');
      print(allTables.toString());
      print(allTables.toList());
      print(allTables);
      Future.delayed(Duration(milliseconds: 300), () {
        print('==== T Number');
        print(order.tableNumber);
        print("===ORDER====");
        print(order);
        print(order.toString());
        print(order.toJson());
        // Procurar em todas as mesas (não apenas nas filtradas)
        final tableIndex = allTables.indexWhere((t) => 
          t.number == order.tableNumber);
          
        if (tableIndex != -1) {
          final table = allTables[tableIndex];
          print("My Table ");
          print(table);
          print("SHOW TABLES");
          // Se mesa estiver em outro andar, mudar para esse andar
          // if (table.floor != selectedFloor) {
          //   setState(() {
          //     selectedFloor = table.floor;
          //     filterTablesByFloor();
          //   });
          // }
          
          _showTableOrdersModal(table);
          print("TENTANDO ABRIR TABLE");
        } else {
          _showErrorSnackBar('Mesa não encontrada após atualização');
        }
      });
    } else {
      _showErrorSnackBar('Erro ao aceitar pedido');
    }
  } catch (e) {
    _showErrorSnackBar('Erro: $e');
  }
}


void _setOrderReady(OrderModel order) async {
  try {
    final success = await OrderService.setOrderReady(order.id);
    if (success) {
      _showSuccessSnackBar('Pedido #${order.id} marcado como pronto');
      Navigator.pop(context);
       // Recarregar dados e reabrir modal
      await loadTables();

      Future.delayed(Duration(milliseconds: 300), () {
        final tableIndex = allTables.indexWhere((t) => 
          t.number == order.tableNumber );
          
        if (tableIndex != -1) {
          final table = allTables[tableIndex];
          
          // Se mesa estiver em outro andar, mudar para esse andar
          if (table.floor != selectedFloor) {
            setState(() {
              selectedFloor = table.floor;
              filterTablesByFloor();
            });
          }

        _showTableOrdersModal(table);
        }
      });
    } else {
      _showErrorSnackBar('Erro ao marcar pedido como pronto');
    }
  } catch (e) {
    _showErrorSnackBar('Erro: $e');
  }
}

void _setOrderDelivered(OrderModel order) async {
  try {
    final success = await OrderService.setOrderDelivered(order.id);
    if (success) {
      _showSuccessSnackBar('Pedido #${order.id} marcado como entregue');
      Navigator.pop(context);

        // Recarregar dados e reabrir modal
      await loadTables();

      Future.delayed(Duration(milliseconds: 300), () {
          final tableIndex = allTables.indexWhere((t) => 
          t.number == order.tableNumber );
          
        if (tableIndex != -1) {
          final table = allTables[tableIndex];
          
          // Se mesa estiver em outro andar, mudar para esse andar
          if (table.floor != selectedFloor) {
            setState(() {
              selectedFloor = table.floor;
              filterTablesByFloor();
            });
          }
          
          _showTableOrdersModal(table);
        } else {
          _showErrorSnackBar('Mesa não encontrada após atualização');
        }

      });
    } else {
      _showErrorSnackBar('Erro ao marcar pedido como entregue');
    }
  } catch (e) {
    _showErrorSnackBar('Erro: $e');
  }
}

void _setOrderCompleted(OrderModel order) async {
  try {
    final success = await OrderService.setOrderCompleted(order.id);
    if (success) {
      _showSuccessSnackBar('Pedido #${order.id} finalizado com sucesso');
      Navigator.pop(context);
      // Recarregar a lista de mesas também
      loadTables();

      Future.delayed(Duration(milliseconds: 300), () {
          final tableIndex = allTables.indexWhere((t) => 
          t.number == order.tableNumber );
          
        if (tableIndex != -1) {
          final table = allTables[tableIndex];
          
          // Se mesa estiver em outro andar, mudar para esse andar
          if (table.floor != selectedFloor) {
            setState(() {
              selectedFloor = table.floor;
              filterTablesByFloor();
            });
          }
          
          _showTableOrdersModal(table);
        } else {
          _showErrorSnackBar('Mesa não encontrada após atualização');
        }});
    } else {
      _showErrorSnackBar('Erro ao finalizar pedido');
    }
  } catch (e) {
    _showErrorSnackBar('Erro: $e');
  }
}

// Helpers para status dos itens
Color _getItemStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return Colors.orange;
    case 'PREPARING':
      return Colors.blue;
    case 'READY':
      return Colors.green;
    case 'DELIVERED':
      return Colors.grey;
    default:
      return Colors.orange;
  }
}

Widget _getItemStatusIcon(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return Icon(Icons.schedule, size: 12, color: Colors.white);
    case 'PREPARING':
      return Icon(Icons.restaurant, size: 12, color: Colors.white);
    case 'READY':
      return Icon(Icons.check_circle, size: 12, color: Colors.white);
    case 'DELIVERED':
      return Icon(Icons.check, size: 12, color: Colors.white);
    default:
      return Icon(Icons.schedule, size: 12, color: Colors.white);
  }
}

String _getItemStatusText(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return 'Pendente';
    case 'PREPARING':
      return 'Preparando';
    case 'READY':
      return 'Pronto';
    case 'DELIVERED':
      return 'Entregue';
    default:
      return 'Pendente';
  }
}

// Funções auxiliares para pedidos
Color _getOrderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Colors.orange;
    case OrderStatus.preparing:
      return Colors.blue;
    case OrderStatus.completed:
      return Colors.green;
    default:
      return TColor.primary;
  }
}

String _getOrderStatusText(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'PENDENTE';
    case OrderStatus.preparing:
      return 'PREPARANDO';
    case OrderStatus.completed:
      return 'CONCLUÍDO';
    default:
      return '';
  }
}

IconData _getNextOrderActionIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Icons.restaurant;
    case OrderStatus.preparing:
      return Icons.check_circle;
    default:
      return Icons.arrow_forward;
  }
}

String _getNextOrderActionText(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Preparar';
    case OrderStatus.preparing:
      return 'Concluir';
    default:
      return 'Próximo';
  }
}

void _updateOrderStatus(OrderModel order) async {
  OrderStatus nextStatus;
  switch (order.status) {
    case OrderStatus.pending:
      nextStatus = OrderStatus.preparing;
      break;
    case OrderStatus.preparing:
      nextStatus = OrderStatus.completed;
      break;
    default:
      return;
  }
  
  try {
    final success = await OrderService.updateOrderStatus(order.id, nextStatus);
    if (success) {
      _showSuccessSnackBar('Pedido ${order.id} atualizado para ${_getOrderStatusText(nextStatus)}');
      // Recarregar a modal
      Navigator.pop(context);
      Future.delayed(Duration(milliseconds: 300), () {
        // Buscar a mesa atualizada e reabrir modal
        final tableIndex = filteredTables.indexWhere((t) => 
          t.number == order.tableNumber );
        if (tableIndex != -1) {
          _showTableOrdersModal(filteredTables[tableIndex]);
        }
      });
    } else {
      _showErrorSnackBar('Erro ao atualizar pedido');
    }
  } catch (e) {
    _showErrorSnackBar('Erro: $e');
  }
}

void _toggleItemServed(OrderItem item) async {
  try {
    final success = await OrderService.markItemAsServed("", item.id);
    if (success) {
      _showSuccessSnackBar('Item ${item.name} marcado como ${item.isServed ? "não servido" : "servido"}');
      // Recarregar dados
      setState(() {});
    } else {
      _showErrorSnackBar('Erro ao atualizar item');
    }
  } catch (e) {
    _showErrorSnackBar('Erro: $e');
  }
}

  
  void _nextAction(TableModel table) {
    Navigator.pop(context);
    TableStatus nextStatus;
    
    switch (table.status) {
      case TableStatus.pending:
        nextStatus = TableStatus.preparing;
        break;
      case TableStatus.preparing:
        nextStatus = TableStatus.served;
        break;
      case TableStatus.served:
        nextStatus = TableStatus.paid;
        break;
      case TableStatus.paid:
        nextStatus = TableStatus.empty;
        break;
      default:
        return;
    }
    
    _updateTableStatus(table, nextStatus);
  }

void _clearTable(TableModel table) {
  Navigator.pop(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Liberar Mesa'),
      content: Text('Tem certeza que deseja liberar a mesa ${table.number}?\n\nTodos os pedidos pendentes serão desalocados da mesa.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            
            final success = await WaiterMenuService.closeTable(table.number);
            
            if (success) {
              _showSuccessSnackBar('Mesa ${table.number} liberada com sucesso');
              loadTables(); // Recarregar dados
            } else {
              _showErrorSnackBar('Erro ao liberar mesa');
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Liberar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

  void _showNewOrderDialog() {
  if (widget.onTableAction != null) {
    widget.onTableAction!(0, 'First'); // Mesa 0 = seleção manual
  }
}

  Future<void> _updateTableStatus(TableModel table, TableStatus newStatus, {int? guestCount}) async {
    try {
      final success = await WaiterMenuService.updateTableStatus(table.number, newStatus);
      
      if (success) {
        // Atualizar localmente
        setState(() {
          final index = allTables.indexWhere((t) => t.number == table.number && t.floor == table.floor);
          if (index != -1) {
            // Aqui você criaria uma nova instância com os dados atualizados
            // Por simplicidade, vamos apenas recarregar os dados
          }
        });
        
        _showSuccessSnackBar('Mesa ${table.number} atualizada para ${_getStatusText(newStatus)}');
        loadTables(); // Recarregar dados
      } else {
        _showErrorSnackBar('Erro ao atualizar mesa');
      }
    } catch (e) {
      _showErrorSnackBar('Erro: $e');
    }
  }

  String _getNextActionText(TableStatus status) {
    switch (status) {
      case TableStatus.pending:
        return 'Preparar';
      case TableStatus.preparing:
        return 'Servir';
      case TableStatus.served:
        return 'Pagar';
      case TableStatus.paid:
        return 'Finalizar';
      default:
        return 'Próximo';
    }
  }

  IconData _getNextActionIcon(TableStatus status) {
    switch (status) {
      case TableStatus.pending:
        return Icons.restaurant;
      case TableStatus.preparing:
        return Icons.room_service;
      case TableStatus.served:
        return Icons.payment;
      case TableStatus.paid:
        return Icons.check;
      default:
        return Icons.arrow_forward;
    }
  }

  Color _getNextActionColor(TableStatus status) {
    switch (status) {
      case TableStatus.pending:
        return Colors.blue;
      case TableStatus.preparing:
        return Colors.green;
      case TableStatus.served:
        return Colors.orange;
      case TableStatus.paid:
        return Colors.purple;
      default:
        return TColor.primary;
    }
  }

  // Helpers visuais
  Color _getTableBackgroundColor(TableStatus status) {
    switch (status) {
      case TableStatus.empty:
        return TColor.white;
      case TableStatus.pending:
        return Colors.orange.withOpacity(0.08);
      case TableStatus.preparing:
        return Colors.blue.withOpacity(0.08);
      case TableStatus.served:
        return Colors.green.withOpacity(0.08);
      case TableStatus.paid:
        return Colors.purple.withOpacity(0.08);
    }
  }

  Color _getTableBorderColor(TableStatus status) {
    switch (status) {
      case TableStatus.empty:
        return TColor.placeholder;
      case TableStatus.pending:
        return Colors.orange;
      case TableStatus.preparing:
        return Colors.blue;
      case TableStatus.served:
        return Colors.green;
      case TableStatus.paid:
        return Colors.purple;
    }
  }

  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.empty:
        return 'Vazia';
      case TableStatus.pending:
        return 'Aguardando';
      case TableStatus.preparing:
        return 'Preparando';
      case TableStatus.served:
        return 'Servido';
      case TableStatus.paid:
        return 'Pago';
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