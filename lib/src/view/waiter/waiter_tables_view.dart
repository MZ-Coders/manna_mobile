import 'package:dribbble_challenge/src/common/waiter_service.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import '../../models/table_model.dart';

class WaiterTablesView extends StatefulWidget {
  const WaiterTablesView({super.key});

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
      final tables = await WaiterService.getTables();
      setState(() {
        allTables = tables;
        filterTablesByFloor();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar mesas: $e')),
      );
    }
  }

  void filterTablesByFloor() {
    setState(() {
      filteredTables = allTables
          .where((table) => table.floor == selectedFloor)
          .toList();
      
      // Ordenar por número da mesa
      filteredTables.sort((a, b) => a.number.compareTo(b.number));
    });
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
            Text(
              'Carregando mesas...',
              style: TextStyle(color: TColor.secondaryText),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildFloorSelector(),
        Expanded(
          child: _buildTablesGrid(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    // Contar mesas por status
    int totalTables = filteredTables.length;
    int occupiedTables = filteredTables
        .where((table) => table.status != TableStatus.empty)
        .length;

    return Container(
      padding: EdgeInsets.all(16),
      color: TColor.primary.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusCard(
            'Ocupadas',
            '$occupiedTables/$totalTables',
            Icons.people,
            TColor.primary,
          ),
          _buildStatusCard(
            'Pendentes',
            '${filteredTables.where((t) => t.status == TableStatus.pending).length}',
            Icons.access_time,
            Colors.orange,
          ),
          _buildStatusCard(
            'Servindo',
            '${filteredTables.where((t) => t.status == TableStatus.preparing).length}',
            Icons.restaurant,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: TColor.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildFloorSelector() {
    List<String> floors = ['First', 'Second', 'Third', 'Ground', 'Take Away'];
    
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: floors.map((floor) {
          bool isSelected = selectedFloor == floor;
          int floorTableCount = allTables
              .where((table) => table.floor == floor)
              .length;
          
          // Não mostrar andar se não tem mesas
          if (floorTableCount == 0) return SizedBox.shrink();
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFloor = floor;
                  filterTablesByFloor();
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? TColor.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? TColor.primary : TColor.placeholder,
                  ),
                ),
                child: Center(
                  child: Text(
                    floor,
                    style: TextStyle(
                      color: isSelected ? TColor.white : TColor.secondaryText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
              'Nenhuma mesa neste andar',
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
          crossAxisCount: 3, // 3 mesas por linha
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8, // Proporção do card
        ),
        itemCount: filteredTables.length,
        itemBuilder: (context, index) {
          return _buildTableCard(filteredTables[index]);
        },
      ),
    );
  }

  Widget _buildTableCard(TableModel table) {
    return GestureDetector(
      onTap: () => _onTableTap(table),
      child: Container(
        decoration: BoxDecoration(
          color: _getTableBackgroundColor(table.status),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: table.status == TableStatus.empty 
                ? TColor.placeholder.withOpacity(0.3)
                : _getTableBorderColor(table.status),
            width: table.status == TableStatus.empty ? 1 : 2,
          ),
          boxShadow: table.status != TableStatus.empty
              ? [
                  BoxShadow(
                    color: _getTableBorderColor(table.status).withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryText,
                  ),
                ),
              ),
            ),
            
            // Notificação urgente
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
                  ),
                ),
              ),
            
            // Conteúdo principal
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone e guests
                  if (table.status != TableStatus.empty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: TColor.primaryText,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${table.guestCount ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            color: TColor.primaryText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                  
                  // Status
                  Text(
                    _getStatusText(table.status),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: table.status == TableStatus.empty 
                          ? TColor.secondaryText
                          : TColor.primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Tempo e valor (se não estiver vazia)
                  if (table.status != TableStatus.empty) ...[
                    SizedBox(height: 8),
                    Text(
                      table.timeElapsed,
                      style: TextStyle(
                        fontSize: 12,
                        color: TColor.secondaryText,
                      ),
                    ),
                    Text(
                      table.formattedValue,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  Color _getTableBackgroundColor(TableStatus status) {
    switch (status) {
      case TableStatus.empty:
        return TColor.white;
      case TableStatus.pending:
        return Colors.orange.withOpacity(0.1);
      case TableStatus.preparing:
        return Colors.blue.withOpacity(0.1);
      case TableStatus.served:
        return Colors.green.withOpacity(0.1);
      case TableStatus.paid:
        return Colors.purple.withOpacity(0.1);
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

  void _onTableTap(TableModel table) {
    // TODO: Implementar ação ao tocar na mesa
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mesa ${table.number}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_getStatusText(table.status)}'),
            if (table.guestCount != null)
              Text('Clientes: ${table.guestCount}'),
            if (table.orderTime != null)
              Text('Tempo: ${table.timeElapsed}'),
            if (table.orderValue != null)
              Text('Valor: ${table.formattedValue}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
          if (table.status != TableStatus.empty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navegar para detalhes do pedido
              },
              child: Text('Ver Pedido'),
            ),
        ],
      ),
    );
  }
}