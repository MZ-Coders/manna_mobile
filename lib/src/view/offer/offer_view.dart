import 'package:dribbble_challenge/src/common_widget/menu_item_row.dart';
import 'package:dribbble_challenge/src/common_widget/round_button.dart';
import 'package:dribbble_challenge/src/view/menu/food_item_details_view.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';

import '../../common_widget/popular_resutaurant_row.dart';
import '../more/my_order_view.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  TextEditingController txtSearch = TextEditingController();

  String restaurantName = '';
  List allMenuItems = [];
  List promotionItems = []; // Itens em promoção
  bool isLoading = true;

  List offerArr = [
    {
      "image": "assets/img/offer_3.png",
      "name": "Cafe Beans",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
  ];

// Lista de itens para categoria Entradas/Starters (ID: 1)
  List filteredMenuItems = [
  ];

  @override
void initState() {
  super.initState();
  loadRestaurantData();
  getDataFromApi();
}

Future<void> loadRestaurantData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    restaurantName = prefs.getString('restaurant_name') ?? '';
  });
}

Future<void> getDataFromApi() async {
  final prefs = await SharedPreferences.getInstance();
  String? restaurantUUID = prefs.getString('restaurant_id');
  
  try {
    ServiceCall.getMenuItems(restaurantUUID ?? '',
        withSuccess: (Map<String, dynamic> data) {
          if (data.containsKey('menu') && data['menu'] != null) {
            if (data['menu'] is List && (data['menu'] as List).isNotEmpty) {
              setState(() {
                allMenuItems = data['menu'];
                filterPromotionItems();
                isLoading = false;
              });
              
              print("Menu carregado com ${allMenuItems.length} categorias");
              print("Itens em promoção encontrados: ${promotionItems.length}");
            }
          }
        },
        failure: (String error) {
          print("Erro ao buscar dados: $error");
          setState(() {
            isLoading = false;
          });
        });
  } catch (e) {
    print("Error fetching data: $e");
    setState(() {
      isLoading = false;
    });
  }
}

void filterPromotionItems() {
  List promoItems = [];
  
  // Percorrer todas as categorias e produtos
  for (var category in allMenuItems) {
    if (category['products'] != null) {
      List products = category['products'];
      
      for (var product in products) {
        // Verificar se o produto está em promoção
        if (product['is_on_promotion'] == true) {
          promoItems.add({
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
            "is_on_promotion": true,
          });
        }
      }
    }
  }
  
  promotionItems = promoItems;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Offers - $restaurantName",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyOrderView()));
                      },
                      icon: Image.asset(
                        "assets/img/shopping_cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Find discounts, Offers special\nmeals and more!",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 140,
                  height: 30,
                  child: RoundButton(title: "check Offers", fontSize: 12 , onPressed: () {}),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // ListView.builder(
              //   physics: const NeverScrollableScrollPhysics(),
              //   shrinkWrap: true,
              //   padding: EdgeInsets.zero,
              //   itemCount: offerArr.length,
              //   itemBuilder: ((context, index) {
              //     var pObj = offerArr[index] as Map? ?? {};
              //     return PopularRestaurantRow(
              //       pObj: pObj,
              //       onTap: () {},
              //     );
              //   }),
              // ),
              isLoading 
  ? const Center(
      child: Padding(
        padding: EdgeInsets.all(50.0),
        child: CircularProgressIndicator(),
      ),
    )
  : promotionItems.isEmpty
      ? Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 60,
                  color: TColor.secondaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  "No promotions available",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Check back later for special offers!",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        )
      : buildMenuItems(context, promotionItems),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItems(BuildContext context, List filteredMenuItems) {
  // Detectar se a tela é larga (web/tablet) ou estreita (mobile)
  bool isMediumScreen = MediaQuery.of(context).size.width > 600 &&
                      MediaQuery.of(context).size.width < 1000;

bool isWideScreen = MediaQuery.of(context).size.width >= 1000;

bool isDesktopScreen = MediaQuery.of(context).size.width >= 1200;
  
  if (isWideScreen || isMediumScreen) {
    // Layout de grade para telas largas
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWideScreen ? 3 : 2, // 3 itens por linha
        childAspectRatio: isDesktopScreen ? 2.5 : isWideScreen ? 1.5 : 2 , // Proporção largura/altura dos itens
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredMenuItems.length,
      itemBuilder: ((context, index) {
        var mObj = filteredMenuItems[index] as Map? ?? {};
        return MenuItemRow(
          mObj: mObj,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodItemDetailsView(
                  foodDetails: mObj.cast<String, dynamic>()
                )
              ),
            );
          },
        );
      }),
    );
  } else {
    // Layout de lista para mobile (seu código original)
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: filteredMenuItems.length,
      itemBuilder: ((context, index) {
        var mObj = filteredMenuItems[index] as Map? ?? {};
        return MenuItemRow(
          mObj: mObj,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodItemDetailsView(
                  foodDetails: mObj.cast<String, dynamic>()
                )
              ),
            );
          },
        );
      }),
    );
  }
}
  
}
