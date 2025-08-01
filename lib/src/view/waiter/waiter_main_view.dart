import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/view/waiter/waiter_menu_view.dart';
import 'package:dribbble_challenge/src/view/waiter/waiter_orders_view.dart';
import 'package:dribbble_challenge/src/view/waiter/waiter_tables_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaiterMainView extends StatefulWidget {
  const WaiterMainView({super.key});

  @override
  State<WaiterMainView> createState() => _WaiterMainViewState();
}

class _WaiterMainViewState extends State<WaiterMainView> {
  int selectedTab = 0;
  String waiterName = '';
  String restaurantName = '';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    loadWaiterInfo();
  }

  Future<void> loadWaiterInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      waiterName = prefs.getString('user_name') ?? '';
      restaurantName = prefs.getString('restaurant_name') ?? '';
      userRole = prefs.getString('user_role') ?? '';
    });
    _configureTabs();
  }

  void _configureTabs() {
  if (userRole.toUpperCase() == 'KITCHEN') {
    // Kitchen: apenas pedidos
    setState(() {
      selectedTab = 0; // Reset para primeira tab disponível
    });
  }
  // WAITER mantém as 3 tabs como está
}

 void navigateToMenuForTable(int tableNumber, String floor) {
  setState(() {
    selectedTab = 1; // Apenas muda para tab do menu
  });

  _setSelectedTableInPreferences(tableNumber, floor);
  
  // Se quiser abrir como nova tela (opcional):
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => WaiterMenuView(
  //       preSelectedTable: tableNumber,
  //       preSelectedFloor: floor,
  //     ),
  //   ),
  // );
}

Future<void> _setSelectedTableInPreferences(int tableNumber, String floor) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('selected_table', tableNumber);
  await prefs.setString('selected_floor', floor);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Garçom: $waiterName',
              style: TextStyle(
                color: TColor.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (restaurantName.isNotEmpty)
              Text(
                restaurantName,
                style: TextStyle(
                  color: TColor.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Menu de configurações
            },
            icon: Icon(Icons.more_vert, color: TColor.white),
          ),
        ],
      ),
      body: _buildTabContent(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

 Widget _buildTabContent() {
  if (userRole.toUpperCase() == 'KITCHEN') {
    return WaiterOrdersView(onNewOrder: navigateToMenuForTable);
  }

  switch (selectedTab) {
    case 0:
      return WaiterTablesView(onTableAction: navigateToMenuForTable);
    case 1:
      return WaiterMenuView();
    default:
      return WaiterTablesView(onTableAction: navigateToMenuForTable);
  }

  // switch (selectedTab) {
  //   case 0:
  //     return WaiterTablesView(onTableAction: navigateToMenuForTable);
  //   case 1:
  //     return WaiterOrdersView(onNewOrder: navigateToMenuForTable);
  //   case 2:
  //     return WaiterMenuView();;
  //   default:
  //     return WaiterTablesView(onTableAction: navigateToMenuForTable);
  //   }
  }

  Widget _buildBottomNavigation() {
    if (userRole.toUpperCase() == 'KITCHEN') {
      // Kitchen: sem bottom navigation, apenas pedidos
      return SizedBox.shrink();
    }

    return BottomNavigationBar(
      currentIndex: selectedTab,
      onTap: (index) {
        setState(() {
          selectedTab = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: TColor.primary,
      unselectedItemColor: TColor.secondaryText,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.table_restaurant),
          label: 'Mesas',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.receipt_long),
        //   label: 'Pedidos',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
      ],
    );
  }

  // Placeholders para as views - vamos implementar uma por vez
Widget _buildTablesView() {
  return WaiterTablesView();
}

Widget _buildOrdersView() {
  return WaiterOrdersView();
}

Widget _buildMenuView() {
  return WaiterMenuView();
}

}