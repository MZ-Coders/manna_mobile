import 'package:dribbble_challenge/src/common/waiter_service.dart';
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
      floatingActionButton: _buildFloatingActionButton(),
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
                 'Ocupar e Fazer Pedido',  // Novo texto
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
            ElevatedButton(
  onPressed: () {
    Navigator.pop(context);
    _updateTableStatus(table, TableStatus.pending, guestCount: guestCount);
    
    // Navegar automaticamente para o menu
    if (widget.onTableAction != null) {
      widget.onTableAction!(table.number, table.floor);
    }
  },
  child: Text('Ocupar e Fazer Pedido'),
),
          ],
        ),
      ),
    );
  }

  void _viewOrder(TableModel table) {
    Navigator.pop(context);
    // TODO: Navegar para tela de detalhes do pedido
    _showSuccessSnackBar('Abrindo pedido da mesa ${table.number}...');
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
        content: Text('Tem certeza que deseja liberar a mesa ${table.number}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateTableStatus(table, TableStatus.empty);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Liberar'),
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