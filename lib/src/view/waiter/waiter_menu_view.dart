import 'package:dribbble_challenge/src/common/waiter_menu_service.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import '../../models/menu_item_model.dart';

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

  Future<void> loadMenu() async {
    setState(() {
      isLoading = true;
    });

    try {
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TColor.primary),
            SizedBox(height: 16),
            Text('Carregando menu...', style: TextStyle(color: TColor.secondaryText)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          if (selectedTable == null) _buildTableSelector(),
          _buildCategoryTabs(),
          Expanded(child: _buildMenuContent()),
        ],
      ),
      bottomNavigationBar: _buildCartSummary(),
    );
  }

  Widget _buildHeader() {
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARDÁPIO',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                    if (selectedTable != null)
                      Text(
                        'Mesa ${selectedTable} - $selectedFloor',
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              if (cart.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TColor.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart, color: TColor.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${cart.length}',
                        style: TextStyle(
                          color: TColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableSelector() {
    if (widget.preSelectedTable != null && widget.preSelectedTable! > 0) {
      return Container(
        padding: EdgeInsets.all(16),
        color: TColor.primary.withOpacity(0.1),
        child: Row(
          children: [
            Icon(Icons.info, color: TColor.primary),
            SizedBox(width: 8),
            Text(
              'Pedido para Mesa ${widget.preSelectedTable} - ${widget.preSelectedFloor}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: TColor.primary,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(16),
      color: TColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecionar Mesa:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // Seletor de andar
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: selectedFloor,
                  decoration: InputDecoration(
                    labelText: 'Andar',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['First', 'Second', 'Third', 'Ground', 'Take Away']
                      .map((floor) => DropdownMenuItem(
                            value: floor,
                            child: Text(floor),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFloor = value!;
                      selectedTable = null; // Reset mesa ao mudar andar
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              
              // Seletor de mesa
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: selectedFloor == 'Take Away' ? 'Balcão' : 'Mesa',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    selectedTable = int.tryParse(value);
                  },
                ),
              ),
              SizedBox(width: 12),
              
              // Número de pessoas
              Expanded(
                child: Column(
                  children: [
                    Text('Pessoas', style: TextStyle(fontSize: 12, color: TColor.secondaryText)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: guestCount > 1 ? () => setState(() => guestCount--) : null,
                          icon: Icon(Icons.remove_circle_outline, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        Text(
                          '$guestCount',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: guestCount < 10 ? () => setState(() => guestCount++) : null,
                          icon: Icon(Icons.add_circle_outline, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    if (categories.isEmpty) return SizedBox.shrink();
    
    return Container(
      color: TColor.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: TColor.primary,
        unselectedLabelColor: TColor.secondaryText,
        indicatorColor: TColor.primary,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        tabs: categories.map((category) {
          final itemCount = menuByCategory[category]?.length ?? 0;
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category),
                SizedBox(width: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: TColor.placeholder.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$itemCount',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onTap: (index) {
          setState(() {
            selectedCategory = categories[index];
          });
        },
      ),
    );
  }

  Widget _buildMenuContent() {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Nenhum item no menu',
          style: TextStyle(color: TColor.secondaryText),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: categories.map((category) {
        final items = menuByCategory[category] ?? [];
        return _buildMenuItemsList(items);
      }).toList(),
    );
  }

  Widget _buildMenuItemsList(List<MenuItemModel> items) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMenuItemCard(items[index]);
      },
    );
  }

  Widget _buildMenuItemCard(MenuItemModel item) {
    final cartItem = cart.firstWhere(
      (cartItem) => cartItem.menuItem.id == item.id,
      orElse: () => CartItemModel(menuItem: item, quantity: 0),
    );
    final isInCart = cartItem.quantity > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInCart ? TColor.primary.withOpacity(0.3) : TColor.placeholder.withOpacity(0.2),
          width: isInCart ? 2 : 1,
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
        child: Row(
          children: [
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
                            fontWeight: FontWeight.w600,
                            color: TColor.primaryText,
                          ),
                        ),
                      ),
                      if (item.isPopular)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Popular',
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  if (item.description != null) ...[
                    SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Text(
                        item.formattedPrice,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColor.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: TColor.secondaryText),
                      SizedBox(width: 4),
                      Text(
                        '${item.preparationTime}min',
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
            
            SizedBox(width: 16),
            
            // Controles de quantidade
            if (!isInCart)
              ElevatedButton(
                onPressed: () => _addToCart(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                  minimumSize: Size(0, 0),
                ),
                child: Icon(Icons.add, color: TColor.white, size: 20),
              )
            else
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _removeFromCart(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(8),
                      minimumSize: Size(0, 0),
                    ),
                    child: Icon(Icons.remove, color: TColor.primaryText, size: 16),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${cartItem.quantity}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColor.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _addToCart(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(8),
                      minimumSize: Size(0, 0),
                    ),
                    child: Icon(Icons.add, color: TColor.white, size: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    if (cart.isEmpty) return SizedBox.shrink();

    final total = cart.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.length} ${cart.length == 1 ? 'item' : 'itens'}',
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _canSubmitOrder() ? _showOrderConfirmation : null,
              icon: Icon(Icons.receipt_long, color: TColor.white),
              label: Text(
                'Enviar Pedido',
                style: TextStyle(
                  color: TColor.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSubmitOrder() ? TColor.primary : Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de ação
  void _addToCart(MenuItemModel item) {
    setState(() {
      final existingIndex = cart.indexWhere((cartItem) => cartItem.menuItem.id == item.id);
      
      if (existingIndex >= 0) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(CartItemModel(menuItem: item, quantity: 1));
      }
    });
  }

  void _removeFromCart(MenuItemModel item) {
    setState(() {
      final existingIndex = cart.indexWhere((cartItem) => cartItem.menuItem.id == item.id);
      
      if (existingIndex >= 0) {
        if (cart[existingIndex].quantity > 1) {
          cart[existingIndex].quantity--;
        } else {
          cart.removeAt(existingIndex);
        }
      }
    });
  }

  bool _canSubmitOrder() {
    return cart.isNotEmpty && 
           selectedTable != null && 
           selectedTable! > 0;
  }

  void _showOrderConfirmation() {
    final total = cart.fold(0.0, (sum, item) => sum + item.totalPrice);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                  Icon(Icons.receipt_long, color: TColor.primary, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirmar Pedido',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: TColor.primaryText,
                          ),
                        ),
                        Text(
                          'Mesa ${selectedTable} - $selectedFloor - $guestCount pessoas',
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de itens
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: TColor.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.menuItem.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TColor.primaryText,
                            ),
                          ),
                        ),
                        Text(
                          item.formattedTotal,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: TColor.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Observações
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Ex: sem cebola, ponto da carne...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 2,
              ),
            ),
            
            // Total e botão
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
                        '\${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColor.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _submitOrder,
                          icon: Icon(Icons.send, color: TColor.white),
                          label: Text(
                            'Enviar Pedido',
                            style: TextStyle(
                              color: TColor.white,
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    Navigator.pop(context); // Fechar dialog de confirmação
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: TColor.primary),
            SizedBox(width: 16),
            Text('Enviando pedido...'),
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
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      );

      Navigator.pop(context); // Fechar loading

      if (success) {
        _showSuccessSnackBar('Pedido enviado com sucesso para Mesa $selectedTable!');
        
        // Limpar carrinho e formulário
        setState(() {
          cart.clear();
          selectedTable = widget.preSelectedTable;
          notesController.clear();
        });

        // Se veio de uma mesa específica, voltar para a tela anterior
        if (widget.preSelectedTable != null) {
          Navigator.pop(context);
        }
      } else {
        _showErrorSnackBar('Erro ao enviar pedido. Tente novamente.');
      }
    } catch (e) {
      Navigator.pop(context); // Fechar loading
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
