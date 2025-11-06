import 'package:dribbble_challenge/src/common/cart_service.dart';
import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class MenuItemRow extends StatefulWidget {
  final Map mObj;
  final VoidCallback onTap;
  const MenuItemRow({super.key, required this.mObj, required this.onTap});

  @override
  State<MenuItemRow> createState() => _MenuItemRowState();
}

class _MenuItemRowState extends State<MenuItemRow> {
  
  @override
  void initState() {
    super.initState();
    // Escutar mudanças no carrinho
    CartService.cartUpdateNotifier.addListener(_onCartUpdated);
  }
  
  @override
  void dispose() {
    // Remover listener quando o widget for destruído
    CartService.cartUpdateNotifier.removeListener(_onCartUpdated);
    super.dispose();
  }
  
  void _onCartUpdated() {
    // Atualizar a UI quando o carrinho mudar
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem com bordas arredondadas (não circular)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.mObj["image"] != null && widget.mObj["image"].toString().isNotEmpty
                    ? Image.network(
                        widget.mObj["image"].toString(),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/dish.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/dish.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 14),
              
              // Informação do item
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Nome do prato
                    Text(
                      widget.mObj["name"]?.toString() ?? "",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Descrição
                    if (widget.mObj["description"] != null && widget.mObj["description"].toString().isNotEmpty)
                      Text(
                        widget.mObj["description"].toString(),
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    
                    // Preço
                    Text(
                      "${widget.mObj["price"]?.toString() ?? "0.00"} MZN",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Botões de quantidade (+ e -)
              Builder(
                builder: (context) {
                  // Verificar se o item existe no carrinho
                  var cartItems = CartService.getCartItems();
                  var existingItem = cartItems.firstWhere(
                    (item) => item["name"] == widget.mObj["name"],
                    orElse: () => {},
                  );
                  
                  int currentQty = 0;
                  if (existingItem.isNotEmpty) {
                    currentQty = int.parse(existingItem["qty"].toString());
                  }
                  
                  // Se quantidade é zero, mostrar apenas botão +
                  if (currentQty == 0) {
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: TColor.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          CartService.addToCart(
                            widget.mObj["name"]?.toString() ?? "",
                            1,
                            double.tryParse(widget.mObj["price"]?.toString() ?? "0") ?? 0.0,
                            widget.mObj["id"] as int?,
                          );
                          
                          setState(() {}); // Atualizar UI
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.mObj["name"]} adicionado ao carrinho'),
                              duration: const Duration(milliseconds: 800),
                              backgroundColor: TColor.primary,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    );
                  }
                  
                  // Se quantidade >= 1, mostrar + em cima, quantidade no meio, - em baixo
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão adicionar (+) em cima
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: TColor.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            CartService.addToCart(
                              widget.mObj["name"]?.toString() ?? "",
                              currentQty + 1,
                              double.tryParse(widget.mObj["price"]?.toString() ?? "0") ?? 0.0,
                              widget.mObj["id"] as int?,
                            );
                            
                            setState(() {}); // Atualizar UI
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Quantidade aumentada'),
                                duration: const Duration(milliseconds: 800),
                                backgroundColor: TColor.primary,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      
                      // Quantidade no meio
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          currentQty.toString(),
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      
                      // Botão diminuir (-) em baixo
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: TColor.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (currentQty > 1) {
                              CartService.addToCart(
                                widget.mObj["name"]?.toString() ?? "",
                                currentQty - 1,
                                double.tryParse(widget.mObj["price"]?.toString() ?? "0") ?? 0.0,
                                widget.mObj["id"] as int?,
                              );
                              
                              setState(() {}); // Atualizar UI
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Quantidade diminuída'),
                                  duration: const Duration(milliseconds: 800),
                                  backgroundColor: Colors.grey.shade700,
                                ),
                              );
                            } else {
                              CartService.removeItemByName(widget.mObj["name"]?.toString() ?? "");
                              
                              setState(() {}); // Atualizar UI
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.mObj["name"]} removido do carrinho'),
                                  duration: const Duration(milliseconds: 800),
                                  backgroundColor: Colors.grey.shade700,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
