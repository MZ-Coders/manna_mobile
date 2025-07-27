import 'dart:typed_data';

import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common/cart_service.dart';
import 'package:dribbble_challenge/src/common_widget/round_button.dart';
import 'package:dribbble_challenge/src/view/home/home_view.dart';
import 'package:dribbble_challenge/src/view/main_tabview/main_tabview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// import './../../pdf/web.dart' if (dart.library.html) './../../pdf/mobile.dart' as platform;
// import 'web.dart' if (dart.library.io) 'mobile.dart' as platform;
// import './../../pdf/web.dart';
import './../../pdf/mobile.dart' if (dart.library.html) './../../pdf/web.dart' as platform;
import 'checkout_view.dart';

import 'package:dribbble_challenge/src/common/service_call.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  // List itemArr = [
  //   {"name": "Beef Burger", "qty": "2", "price": 16.0},
  //   {"name": "Classic Burger", "qty": "1", "price": 14.0},
  //   {"name": "Cheese Chicken Burger", "qty": "1", "price": 17.0},
  //   {"name": "Chicken Legs Basket", "qty": "1", "price": 15.0},
  //   {"name": "French Fires Large", "qty": "1", "price": 6.0}
  // ];

  List itemArr = CartService.getCartItems();
  String restaurantName = '';
  String restaurantLogo = '';
  String restaurantAddress = '';
  String restaurantCity = '';
  bool isLoading = true;

  String restaurantId = '';
  String tableId = '';

  // Controladores para o formulário do cliente
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
void initState() {
  super.initState();
  loadRestaurantData();
}

@override
void dispose() {
  _customerNameController.dispose();
  _customerPhoneController.dispose();
  _notesController.dispose();
  super.dispose();
}

Future<void> loadRestaurantData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    restaurantName = prefs.getString('restaurant_name') ?? 'Manna Restaurant';
    restaurantLogo = prefs.getString('restaurant_logo') ?? '';
    restaurantAddress = prefs.getString('restaurant_address') ?? '';
    restaurantCity = prefs.getString('restaurant_city') ?? '';
    isLoading = false;
    restaurantId = prefs.getString('restaurant_id') ?? '';
    tableId = prefs.getString('table_id') ?? '';
  });
  
  print("Dados do restaurante carregados: $restaurantName");
}

String _buildAddressText() {
  List<String> addressParts = [];
  
  if (restaurantAddress.isNotEmpty) {
    addressParts.add(restaurantAddress);
  }
  
  if (restaurantCity.isNotEmpty) {
    addressParts.add(restaurantCity);
  }
  
  if (addressParts.isEmpty) {
    return " ... "; // Fallback
  }
  
  return addressParts.join(", ");
}

void _updateCart() {
  setState(() {
    itemArr = CartService.getCartItems();
  });
}

void _removeItem(int index) {
  setState(() {
    CartService.removeFromCart(index);
    itemArr = CartService.getCartItems();
  });
}

void _updateQuantity(int index, int newQty) {
  if (newQty <= 0) {
    _removeItem(index);
  } else {
    setState(() {
      CartService.updateQuantity(index, newQty);
      itemArr = CartService.getCartItems();
    });
  }
}

Widget _buildEmptyCartView() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone do carrinho vazio
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: TColor.primary,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Título
         Text(
            AppLocalizations.of(context).emptyCart,
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Descrição
          Text(
            AppLocalizations.of(context).findOffers,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.secondaryText,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Botão para voltar ao menu
          SizedBox(
            width: 200,
            child: RoundButton(
              title: AppLocalizations.of(context).continueMenu,
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
        'home',
        (route) => false,
      );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Informações do restaurante mesmo com carrinho vazio
          if (restaurantName.isNotEmpty) ...[
            Divider(
              color: TColor.secondaryText.withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (restaurantLogo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      restaurantLogo,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: TColor.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (restaurantAddress.isNotEmpty || restaurantCity.isNotEmpty)
                      Text(
                        _buildAddressText(),
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildSummaryRow(String label, String value, bool isTotal) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: TColor.primaryText,
          fontSize: isTotal ? 16 : 14,
          fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: isTotal ? TColor.primary : TColor.primaryText,
          fontSize: isTotal ? 20 : 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

void _showCheckoutDialog() {
  bool hasTable = tableId.isNotEmpty;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.shopping_cart_checkout, color: TColor.primary),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context).confirmOrderTitle),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).orderQuestion),
              const SizedBox(height: 16),
              
              // Se não tiver mesa, mostrar campos do cliente
              if (!hasTable) ...[
                TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Cliente *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customerPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone do Cliente *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Telefone é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              
              // Campo de notas (sempre visível)
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).totalAmount,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${(CartService.getTotal() + 0).toStringAsFixed(2)} MZN",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (!hasTable && !_formKey.currentState!.validate()) {
                return;
              }
              
              Navigator.of(context).pop();
              _processPurchase();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context).confirmAndGenerateReceipt),
          ),
        ],
      );
    },
  );
}

void _processPurchase() async {
  EasyLoading.show(status: 'Processando pedido...');
  
  try {
    print("=== DEBUG CART ITEMS ===");
    for (int i = 0; i < itemArr.length; i++) {
      print("Item $i: ${itemArr[i]}");
    }
    print("========================");
    // Preparar itens do carrinho
    List<Map<String, dynamic>> items = [];
    for (var item in itemArr) {
      items.add({
        "product_id": item['id'] ?? item['product_id'], // Ajuste conforme sua estrutura
        "quantity": int.parse(item['qty'].toString())
      });
    }
    
    // Preparar dados da compra
    Map<String, dynamic> purchaseData = {
      "restaurant_id": int.parse(restaurantId),
      "items": items,
    };
    
    // Adicionar dados específicos baseado na presença da mesa
    if (tableId.isNotEmpty) {
      // Com mesa
      purchaseData["table_number"] = int.parse(tableId);
      if (_notesController.text.trim().isNotEmpty) {
        purchaseData["notes"] = _notesController.text.trim();
      }
    } else {
      // Sem mesa
      purchaseData["customer_name"] = _customerNameController.text.trim();
      purchaseData["customer_phone"] = _customerPhoneController.text.trim();
      purchaseData["table_number"] = null;
      if (_notesController.text.trim().isNotEmpty) {
        purchaseData["notes"] = _notesController.text.trim();
      }
    }
    
    // Chamar API
    ServiceCall.purchase(
      purchaseData,
      withSuccess: (response) {
        EasyLoading.dismiss();
        _onPurchaseSuccess(response);
      },
      failure: (error) {
        EasyLoading.dismiss();
        _onPurchaseError(error);
      }
    );
    
  } catch (e) {
    EasyLoading.dismiss();
    _onPurchaseError('Erro ao processar dados: $e');
  }
}

void _onPurchaseSuccess(Map<String, dynamic> response) {
  // Limpar formulário
  _customerNameController.clear();
  _customerPhoneController.clear();
  _notesController.clear();
  
  // Gerar PDF e navegar
  _createPDFv2().then((_) {
    CartService.clearCart();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeView(),
      ),
    );
    
    // Mostrar mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido registrado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  });
}

void _onPurchaseError(String error) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Erro'),
      content: Text('Falha ao registrar pedido: $error'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: isLoading 
    ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TColor.primary),
            const SizedBox(height: 20),
            Text(
             AppLocalizations.of(context).loading,
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
    : itemArr.isEmpty 
        ? _buildEmptyCartView()
        : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
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
              AppLocalizations.of(context).myOrder,
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
            Text(
             "${itemArr.length} ${AppLocalizations.of(context).itemsInCart}",
              style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      // Badge com total de itens
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: TColor.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "${CartService.getTotalItems()}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
),
              Container(
  margin: const EdgeInsets.all(15),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    children: [
      ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: restaurantLogo.isNotEmpty 
              ? Image.network(
                  restaurantLogo,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/img/manna_icon.png",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(
                  "assets/img/manna_icon.png",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )),
      const SizedBox(
        width: 12,
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurantName.isNotEmpty ? restaurantName : "Manna Restaurant",
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            // MANTER TODO O RESTO DO COLUMN ORIGINAL AQUI
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/img/rate.png",
                  width: 10,
                  height: 10,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 4),
                Text(
                  "4.9",
                  style: TextStyle(
                      color: TColor.primary, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  "(124 Ratings)",
                  style: TextStyle(
                      color: TColor.secondaryText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  restaurantName.isNotEmpty ? restaurantName : "Manna Restaurant",
                  style: TextStyle(
                      color: TColor.secondaryText, fontSize: 12),
                ),
                Text(
                  " . ",
                  style: TextStyle(
                      color: TColor.primary, fontSize: 12),
                ),
                Text(
                  "",
                  style: TextStyle(
                      color: TColor.secondaryText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/img/location-pin.png",
                  width: 13,
                  height: 13,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _buildAddressText(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 12),
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
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                child: 
                Container(
  margin: const EdgeInsets.symmetric(horizontal: 15),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header da lista
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: TColor.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context).orderItems,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${itemArr.length} ${AppLocalizations.of(context).itemsInCart}",
                style: TextStyle(
                  color: TColor.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Divider
      Divider(
        height: 1,
        color: TColor.secondaryText.withOpacity(0.1),
        indent: 20,
        endIndent: 20,
      ),
      
      // Lista de itens
      ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: itemArr.length,
        separatorBuilder: ((context, index) => Divider(
              indent: 25,
              endIndent: 25,
              color: TColor.secondaryText.withOpacity(0.1),
              height: 1,
            )),
        itemBuilder: ((context, index) {
          var cObj = itemArr[index] as Map? ?? {};
          double itemPrice = double.parse(cObj["price"].toString());
          int quantity = int.parse(cObj["qty"].toString());
          double totalItemPrice = itemPrice * quantity;
          
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
  children: [
    // Primeira linha: Nome e preço
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cObj["name"].toString(),
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "${itemPrice.toStringAsFixed(2)} MZN cada",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => _removeItem(index),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.close,
              color: Colors.red,
              size: 16,
            ),
          ),
        ),
      ],
    ),
    
    const SizedBox(height: 12),
    
    // Segunda linha: Controles de quantidade e total
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Controles de quantidade
        Row(
          children: [
            InkWell(
              onTap: () => _updateQuantity(index, quantity - 1),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: TColor.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                quantity.toString(),
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            InkWell(
              onTap: () => _updateQuantity(index, quantity + 1),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: TColor.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        
        // Total do item
        Text(
          "${totalItemPrice.toStringAsFixed(2)} MZN",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ],
    ),
  ],
),
          );
        }),
      ),
    ],
  ),
),
              ),
              
              Container(
  margin: const EdgeInsets.all(15),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header da seção
      Row(
        children: [
          Icon(
            Icons.receipt_outlined,
            color: TColor.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context).orderSummary,
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 20),
      
      // Subtotal
      _buildSummaryRow(AppLocalizations.of(context).subtotal, "${CartService.getTotal().toStringAsFixed(2)} MZN", false),
      
      const SizedBox(height: 12),
      
      // Delivery cost
      _buildSummaryRow(AppLocalizations.of(context).deliveryCost, "0 MZN", false),
      
      const SizedBox(height: 16),
      
      // Divider
      Container(
        height: 1,
        color: TColor.secondaryText.withOpacity(0.2),
      ),
      
      const SizedBox(height: 16),
      
      // Total
      _buildSummaryRow(AppLocalizations.of(context).total, "${(CartService.getTotal() + 0).toStringAsFixed(2)} MZN", true),
      
      const SizedBox(height: 30),
      
      // Botões de ação
      Row(
        children: [
          // Botão Continue Shopping
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: TColor.primary),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
        'home',
        (route) => false,
      );
                },
                child: Text(
                  AppLocalizations.of(context).continueShopping,
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Botão Checkout
          Expanded(
            flex: 2,
            child: Container(
              height: 50,
              child: RoundButton(
                title: AppLocalizations.of(context).checkout,
                onPressed: () {
                  if (!itemArr.isEmpty) {
                    _showCheckoutDialog();
                  }
                },
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
      ),
    );
  }

Future<void> _createPDFv2() async {
  final PdfDocument document = PdfDocument();
  final page = document.pages.add();
  
  // Cores modernas
  final PdfColor primaryColor = PdfColor(255, 107, 53); // Laranja moderno
  final PdfColor accentColor = PdfColor(45, 55, 72); // Azul escuro
  final PdfColor lightGray = PdfColor(247, 250, 252);
  final PdfColor darkGray = PdfColor(113, 128, 150);
  
  double currentY = 0;
  double pageWidth = page.getClientSize().width;
  
  // Header colorido de fundo
  page.graphics.drawRectangle(
    brush: PdfSolidBrush(primaryColor),
    bounds: Rect.fromLTWH(0, 0, pageWidth, 100),
  );
  
  // Logo com fundo branco arredondado
 page.graphics.drawEllipse(
  Rect.fromLTWH(20, 15, 70, 70),
  brush: PdfSolidBrush(PdfColor(255, 255, 255)),
);
  
  // Logo do restaurante
  String logoSource = restaurantLogo.isNotEmpty 
      ? restaurantLogo 
      : 'assets/img/manna_icon.png';
  
  try {
  final PdfBitmap logo = PdfBitmap(await _readImageData(logoSource));
  page.graphics.drawImage(logo, Rect.fromLTWH(25, 20, 60, 60));
} catch (e) {
  print("Erro ao carregar logo: $e");
  // Desenhar círculo como placeholder
  page.graphics.drawEllipse(
    Rect.fromLTWH(25, 20, 60, 60),
    brush: PdfSolidBrush(PdfColor(200, 200, 200)),
  );
}
  
  // Informações do restaurante no header
  page.graphics.drawString(
    restaurantName.isNotEmpty ? restaurantName : 'Manna Restaurant',
    PdfStandardFont(PdfFontFamily.helvetica, 22, style: PdfFontStyle.bold),
    brush: PdfSolidBrush(PdfColor(255, 255, 255)),
    bounds: Rect.fromLTWH(110, 20, 400, 30),
  );
  
  page.graphics.drawString(
    _buildAddressText(),
    PdfStandardFont(PdfFontFamily.helvetica, 12),
    brush: PdfSolidBrush(PdfColor(255, 255, 255)),
    bounds: Rect.fromLTWH(110, 45, 400, 20),
  );
  
  // Número do pedido e data
  String orderNumber = "PD${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
  page.graphics.drawString(
    'Pedido #$orderNumber',
    PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
    brush: PdfSolidBrush(PdfColor(255, 255, 255)),
    bounds: Rect.fromLTWH(110, 65, 200, 15),
  );
  
  page.graphics.drawString(
    DateTime.now().toLocal().toString().split('.')[0],
    PdfStandardFont(PdfFontFamily.helvetica, 10),
    brush: PdfSolidBrush(PdfColor(255, 255, 255)),
    bounds: Rect.fromLTWH(110, 80, 200, 15),
  );
  
  currentY = 120;
  
  // Título da seção de itens
  page.graphics.drawString(
  'ITENS DO PEDIDO',
  PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
  brush: PdfSolidBrush(accentColor),
  bounds: Rect.fromLTWH(0, currentY, 300, 20),
);
  
  currentY += 35;
  
  // Tabela moderna de itens
  List<Map<String, dynamic>> items = CartService.getCartItems();
  
  if (items.isEmpty) {
    page.graphics.drawString(
      'Nenhum item no carrinho!',
      PdfStandardFont(PdfFontFamily.helvetica, 14),
     brush: PdfSolidBrush(PdfColor(255, 0, 0)), 
      bounds: Rect.fromLTWH(20, currentY, 500, 25),
    );
    
    List<int> bytes = await document.save();
    document.dispose();
    platform.saveAndLaunchFile(bytes, 'recibo_vazio.pdf');
    return;
  }
  
  // Header da tabela com fundo colorido
  page.graphics.drawRectangle(
    brush: PdfSolidBrush(lightGray),
    bounds: Rect.fromLTWH(0, currentY, pageWidth, 25),
  );
  
  page.graphics.drawString(
    'PRODUTO',
    PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
    brush: PdfSolidBrush(accentColor),
    bounds: Rect.fromLTWH(10, currentY + 8, 200, 15),
  );
  
  page.graphics.drawString(
    'QTD',
    PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
    brush: PdfSolidBrush(accentColor),
    bounds: Rect.fromLTWH(300, currentY + 8, 50, 15),
  );
  
  page.graphics.drawString(
    'PREÇO UNIT.',
    PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
    brush: PdfSolidBrush(accentColor),
    bounds: Rect.fromLTWH(370, currentY + 8, 80, 15),
  );
  
  page.graphics.drawString(
    'TOTAL',
    PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
    brush: PdfSolidBrush(accentColor),
    bounds: Rect.fromLTWH(460, currentY + 8, 80, 15),
  );
  
  currentY += 25;
  
  // Itens da tabela com linhas alternadas
  for (int i = 0; i < items.length; i++) {
    var item = items[i];
    double itemPrice = double.parse(item['price'].toString());
    int quantity = int.parse(item['qty'].toString());
    double totalItemPrice = itemPrice * quantity;
    
    // Cor de fundo alternada
    if (i % 2 == 0) {
      page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(250, 250, 250)),
       bounds: Rect.fromLTWH(0, currentY, pageWidth, 25),
      );
    }
    
    page.graphics.drawString(
      item['name'],
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      bounds: Rect.fromLTWH(10, currentY + 8, 250, 15),
    );
    
    page.graphics.drawString(
      quantity.toString(),
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      bounds: Rect.fromLTWH(300, currentY + 8, 50, 15),
    );
    
    page.graphics.drawString(
      '${itemPrice.toStringAsFixed(2)} MZN',
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      bounds: Rect.fromLTWH(370, currentY + 8, 80, 15),
    );
    
    page.graphics.drawString(
      '${totalItemPrice.toStringAsFixed(2)} MZN',
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(460, currentY + 8, 80, 15),
    );
    
    currentY += 25;
  }
  
  currentY += 20;
  
  // Seção de totais com design moderno
  double boxStartY = currentY;
  page.graphics.drawRectangle(
    brush: PdfSolidBrush(lightGray),
    bounds: Rect.fromLTWH(300, boxStartY, 250, 80),
  );
  
  // Borda colorida
  page.graphics.drawRectangle(
    pen: PdfPen(primaryColor, width: 2),
    bounds: Rect.fromLTWH(300, boxStartY, 250, 80),
  );
  
  double subTotal = CartService.getTotal();
  double delivery = 0;
  double total = subTotal + delivery;
  // double boxStartY = currentY;
  double boxWidth = 220; // DEFINIR boxWidth primeiro
  double boxStartX = pageWidth - boxWidth; // Agora pode usar boxWidth
  
 // Subtotal
page.graphics.drawString(
  'Subtotal:',
  PdfStandardFont(PdfFontFamily.helvetica, 12),
  bounds: Rect.fromLTWH(boxStartX + 20, boxStartY + 15, 100, 15),
);

page.graphics.drawString(
  '${subTotal.toStringAsFixed(2)} MZN',
  PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
  bounds: Rect.fromLTWH(boxStartX + 120, boxStartY + 15, 80, 15),
);

// Delivery
page.graphics.drawString(
  'Entrega:',
  PdfStandardFont(PdfFontFamily.helvetica, 12),
  bounds: Rect.fromLTWH(boxStartX + 20, boxStartY + 35, 100, 15),
);

page.graphics.drawString(
  '${delivery.toStringAsFixed(2)} MZN',
  PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
  bounds: Rect.fromLTWH(boxStartX + 120, boxStartY + 35, 80, 15),
);

// Linha separadora
page.graphics.drawLine(
  PdfPen(darkGray),
  Offset(boxStartX + 20, boxStartY + 50),
  Offset(boxStartX + boxWidth - 20, boxStartY + 50),
);

// Total
page.graphics.drawString(
  'TOTAL:',
  PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
  brush: PdfSolidBrush(accentColor),
  bounds: Rect.fromLTWH(boxStartX + 20, boxStartY + 55, 100, 20),
);

page.graphics.drawString(
  '${total.toStringAsFixed(2)} MZN',
  PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
  brush: PdfSolidBrush(primaryColor),
  bounds: Rect.fromLTWH(boxStartX + 80, boxStartY + 55, boxWidth - 100, 20),
);

currentY = boxStartY + 100;

// Footer moderno
page.graphics.drawLine(
  PdfPen(lightGray, width: 2),
  Offset(0, currentY), // CORRIGIDO: era 20, agora é 0
  Offset(pageWidth, currentY),
);
  
  currentY += 20;
  
  page.graphics.drawString(
    '🍕 Obrigado pelo seu pedido!',
    PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
    brush: PdfSolidBrush(primaryColor),
    bounds: Rect.fromLTWH(0, currentY, 300, 20),
  );
  
  currentY += 25;
  
  page.graphics.drawString(
    'Seu pedido será preparado com muito carinho.',
    PdfStandardFont(PdfFontFamily.helvetica, 11),
    brush: PdfSolidBrush(darkGray),
    bounds: Rect.fromLTWH(0, currentY, 300, 15),
  );
  
  // Gerar e salvar
  List<int> bytes = await document.save();
  document.dispose();
  
  String fileName = 'recibo_${restaurantName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  platform.saveAndLaunchFile(bytes, fileName);
}
Future<Uint8List> _readImageData(String source) async {
  if (source.startsWith('http')) {
    // Carregar imagem da URL
    try {
      final response = await http.get(Uri.parse(source));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        // Se falhar, usar imagem padrão
        final data = await rootBundle.load('assets/img/manna_icon.png');
        return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      }
    } catch (e) {
      print("Erro ao carregar logo: $e");
      // Se falhar, usar imagem padrão
      final data = await rootBundle.load('assets/img/manna_icon.png');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
  } else {
    // Carregar imagem dos assets
    final data = await rootBundle.load(source);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
}



