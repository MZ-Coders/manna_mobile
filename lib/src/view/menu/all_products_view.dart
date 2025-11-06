import 'package:dribbble_challenge/src/common_widget/menu_item_row.dart';
import 'package:dribbble_challenge/src/view/menu/food_item_details_view.dart';
import 'package:flutter/material.dart';

class AllProductsView extends StatefulWidget {
  final List allMenuItems;
  
  const AllProductsView({
    super.key,
    required this.allMenuItems,
  });

  @override
  State<AllProductsView> createState() => _AllProductsViewState();
}

class _AllProductsViewState extends State<AllProductsView> {
  String? selectedFilter; // Para filtro de alergia

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Menu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Filtro opcional (similar à imagem)
          if (selectedFilter != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  selectedFilter!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Colors.grey[800],
                deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    selectedFilter = null;
                  });
                },
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            color: Colors.grey[900],
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Vegetarian',
                child: Text('Vegetarian', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'Gluten Free',
                child: Text('Gluten Free', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'Dairy Free',
                child: Text('Dairy Free', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: widget.allMenuItems.length,
        itemBuilder: (context, categoryIndex) {
          var category = widget.allMenuItems[categoryIndex];
          var products = category['products'] as List? ?? [];
          
          // Pular categorias sem produtos
          if (products.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da categoria
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  category['category_name'] ?? 'Category',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Lista de produtos da categoria
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: products.length,
                itemBuilder: (context, productIndex) {
                  var product = products[productIndex];
                  
                  Map<String, dynamic> mObj = {
                    "id": product['id'],
                    "image": product['image_url'] ?? "assets/img/dess_1.png",
                    "name": product['name'],
                    "rate": "4.9",
                    "rating": "124",
                    "type": category['category_name'],
                    "food_type": category['category_name'],
                    "description": product['description'] ?? '',
                    "price": double.tryParse(product['current_price'].toString()) ?? 0.0,
                    "regular_price": double.tryParse(product['regular_price'].toString()) ?? 0.0,
                    "is_on_promotion": product['is_on_promotion'] ?? false,
                  };

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Theme(
                      data: ThemeData.dark().copyWith(
                        textTheme: ThemeData.dark().textTheme.apply(
                          bodyColor: Colors.white,
                          displayColor: Colors.white,
                        ),
                      ),
                      child: MenuItemRow(
                        mObj: mObj,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodItemDetailsView(
                                foodDetails: mObj,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
