import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import '../../models/menu_item_model.dart';
import '../../common/waiter_menu_service.dart';
// import '../../common/mobile_printer_service.dart';

class WaiterMenuView extends StatefulWidget {
  final int? preSelectedTable;
  final String? preSelectedFloor;

  const WaiterMenuView({
    super.key,
    this.preSelectedTable,
    this.preSelectedFloor,
  });

  @override
  State<WaiterMenuView> createState() => _WaiterMenuViewState();
}

class _WaiterMenuViewState extends State<WaiterMenuView> with TickerProviderStateMixin {
  Map<String, List<MenuItemModel>> menuByCategory = {};
  List<String> categories = [];
  List<CartItemModel> cart = [];
  bool isLoading = true;
  String selectedCategory = '';
  late TabController _tabController;
  
  // Para novo pedido
  int? selectedTable;
  String selectedFloor = 'First';
  int guestCount = 2;
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedTable = widget.preSelectedTable == 0 ? null : widget.preSelectedTable;
    selectedFloor = widget.preSelectedFloor ?? 'First';
    loadMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // Carregar menu da API usando o mesmo método que o cliente
  Future<void> loadMenu() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Usar o serviço atualizado que pega dados da mesma API do cliente
      final menu = await WaiterMenuService.getMenuByCategory();
      setState(() {
        menuByCategory = menu;
        categories = menu.keys.toList();
        if (categories.isNotEmpty) {
          selectedCategory = categories.first;
          _tabController = TabController(length: categories.length, vsync: this);
        }
        isLoading = false;
      });
      
      // print("Menu do garçom carregado com ${categories.length} categorias");
      
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erro ao carregar menu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: TColor.primary),
              SizedBox(height: 16),
              Text(
                'Carregando menu...',
                style: TextStyle(color: TColor.secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: TColor.primary,
        foregroundColor: Colors.white,
        title: Text('Menu - ${selectedTable != null ? 'Mesa $selectedTable' : 'Selecionar Mesa'}'),
        actions: [
          if (cart.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  onPressed: _showCart,
                  icon: Icon(Icons.shopping_cart),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.length}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações da mesa
          if (selectedTable != null) _buildTableHeader(),
          
          // Tabs das categorias
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: TColor.primary,
              unselectedLabelColor: TColor.secondaryText,
              indicatorColor: TColor.primary,
              onTap: (index) {
                setState(() {
                  selectedCategory = categories[index];
                });
              },
              tabs: categories.map((category) => Tab(text: category)).toList(),
            ),
          ),
          
          // Lista de itens da categoria selecionada
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                final items = menuByCategory[category] ?? [];
                return _buildMenuItems(items);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: selectedTable == null
          ? FloatingActionButton(
              onPressed: _selectTable,
              backgroundColor: TColor.primary,
              child: Icon(Icons.table_restaurant, color: Colors.white),
            )
          : cart.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _showCart,
                  backgroundColor: TColor.primary,
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    'Ver Pedido (${cart.length})',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.table_restaurant, color: TColor.primary),
          SizedBox(width: 8),
          Text(
            'Mesa $selectedTable',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          Spacer(),
          Text(
            'Andar: $selectedFloor',
            style: TextStyle(color: TColor.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(List<MenuItemModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Nenhum item disponível nesta categoria',
              style: TextStyle(color: TColor.secondaryText),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMenuItem(item);
      },
    );
  }

  Widget _buildMenuItem(MenuItemModel item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagem do item
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.restaurant, color: Colors.grey),
                      ),
                    )
                  : Icon(Icons.restaurant, color: Colors.grey),
            ),
            SizedBox(width: 12),
            
            // Informações do item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: TColor.primaryText,
                          ),
                        ),
                      ),
                      if (item.isPopular)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.description?.isNotEmpty == true) ...[
                    SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8),
                  
                  // Preço e promoção
                  Row(
                    children: [
                      if (item.isOnPromotion && item.regularPrice != null) ...[
                        Text(
                          item.formattedRegularPrice,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.formattedDiscount,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      Text(
                        item.formattedPrice,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: item.isOnPromotion ? Colors.red : TColor.primary,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${item.preparationTime} min',
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botão adicionar
            Column(
              children: [
                if (_getItemQuantityInCart(item.id) > 0) ...[
      // Controles + e - quando item já está no carrinho
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: TColor.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _updateItemQuantity(item, -1),
              icon: Icon(Icons.remove, size: 18),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${_getItemQuantityInCart(item.id)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () => _updateItemQuantity(item, 1),
              icon: Icon(Icons.add, size: 18),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    ] else ...[
      // Botão + quando item não está no carrinho
      ElevatedButton(
        onPressed: () => _updateItemQuantity(item, 1),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColor.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(60, 36),
          shape: CircleBorder(),
        ),
        child: Icon(Icons.add, size: 20),
      ),
    ],
  ],
              
            ),
          ],
        ),
      ),
    );
  }

  void _updateItemQuantity(MenuItemModel item, int change) {
  if (selectedTable == null && change > 0) {
    _selectTable();
    return;
  }

  setState(() {
    final existingIndex = cart.indexWhere((cartItem) => cartItem.menuItem.id == item.id);
    
    if (existingIndex >= 0) {
      // Item já existe no carrinho
      cart[existingIndex].quantity += change;
      if (cart[existingIndex].quantity <= 0) {
        cart.removeAt(existingIndex);
      }
    } else if (change > 0) {
      // Adicionar novo item
      cart.add(CartItemModel(menuItem: item));
    }
  });

  // Feedback visual
  if (change > 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} adicionado ao pedido'),
        duration: Duration(seconds: 1),
        backgroundColor: TColor.primary,
      ),
    );
  }
}


  int _getItemQuantityInCart(String itemId) {
    try {
      return cart.firstWhere((cartItem) => cartItem.menuItem.id == itemId).quantity;
    } catch (e) {
      return 0;
    }
  }

  void _selectTable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selecionar Mesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número da Mesa',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                selectedTable = int.tryParse(value);
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedFloor,
              decoration: InputDecoration(
                labelText: 'Andar',
                border: OutlineInputBorder(),
              ),
              items: ['First', 'Second', 'Third'].map((floor) {
                return DropdownMenuItem(
                  value: floor,
                  child: Text(floor),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedFloor = value;
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de Pessoas',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                guestCount = int.tryParse(value) ?? 2;
              },
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
              if (selectedTable != null) {
                setState(() {});
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: TColor.primary),
            child: Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCart() {
    if (cart.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido - Mesa $selectedTable',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryText,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Divider(),
            
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final cartItem = cart[index];
                  return Card(
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: cartItem.menuItem.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cartItem.menuItem.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.restaurant, color: Colors.grey),
                                ),
                              )
                            : Icon(Icons.restaurant, color: Colors.grey),
                      ),
                      title: Text(cartItem.menuItem.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cartItem.menuItem.formattedPrice),
                          if (cartItem.notes?.isNotEmpty == true)
                            Text(
                              'Obs: ${cartItem.notes}',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
      onPressed: () {
        setModalState(() {  // USAR setModalState ao invés de setState
          cart[index].quantity--;
          if (cart[index].quantity <= 0) {
            cart.removeAt(index);
          }
        });
        setState(() {}); // Atualizar tela principal também
      },
      icon: Icon(Icons.remove_circle_outline),
    ),
    Text('${cartItem.quantity}'),
    IconButton(
      onPressed: () {
        setModalState(() {  // USAR setModalState ao invés de setState
          cart[index].quantity++;
        });
        setState(() {}); // Atualizar tela principal também
      },
      icon: Icon(Icons.add_circle_outline),
    ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            Divider(),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _calculateTotal(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColor.primary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Campo de observações
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Observações do pedido',
                border: OutlineInputBorder(),
                hintText: 'Ex: Sem cebola, bem passado...',
              ),
              maxLines: 2,
            ),
            
            SizedBox(height: 16),
            
            // Botão finalizar pedido com ícone de impressão
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitOrder,
                icon: Icon(Icons.print, color: Colors.white),
                label: Text(
                  'Finalizar Pedido e Imprimir',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            SizedBox(height: 8),
            
            // Botão adicional para apenas imprimir (sem enviar pedido)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    String? waiterName = prefs.getString('user_name');
                    
                    // await MobilePrinterService.printWithPrinterSelection(
                    //   context: context,
                    //   tableNumber: selectedTable!,
                    //   floor: selectedFloor,
                    //   items: cart,
                    //   guestCount: guestCount,
                    //   notes: notesController.text.isNotEmpty ? notesController.text : null,
                    //   waiterName: waiterName,
                    // );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro na impressão: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.preview, color: TColor.primary),
                label: Text(
                  'Apenas Imprimir Preview',
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: TColor.primary),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      )
    );
    
  }

  void _updateCartItemQuantity(int index, int change) {
    setState(() {
      cart[index].quantity += change;
      if (cart[index].quantity <= 0) {
        cart.removeAt(index);
      }
    });
  }

  String _calculateTotal() {
    double total = cart.fold(0.0, (sum, item) => sum + item.totalPrice);
    return 'MT ${total.toStringAsFixed(2)}';
  }

  Future<void> _submitOrder() async {
    if (cart.isEmpty || selectedTable == null) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Enviando pedido e imprimindo recibo...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      final success = await WaiterMenuService.submitOrder(
        tableNumber: selectedTable!,
        floor: selectedFloor,
        items: cart,
        guestCount: guestCount,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        context: context, // Passar contexto para impressão
      );

      Navigator.pop(context); // Fechar loading

      if (success) {
        // Limpar carrinho
        setState(() {
          cart.clear();
          notesController.clear();
        });

        Navigator.pop(context); // Fechar modal do carrinho

        // Adicionar botão para reimprimir se necessário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido finalizado com sucesso!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Reimprimir',
              textColor: Colors.white,
              onPressed: () async {
                // Função para reimprimir o recibo
                await WaiterMenuService.reprintReceipt(
                  context: context,
                  tableNumber: selectedTable!,
                  floor: selectedFloor,
                  items: cart,
                  guestCount: guestCount,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );
              },
            ),
          ),
        );
      } else {
        throw Exception('Falha no envio do pedido');
      }
    } catch (e) {
      Navigator.pop(context); // Fechar loading
      _showErrorSnackBar('Erro ao enviar pedido: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}