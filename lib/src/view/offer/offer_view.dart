import 'package:dribbble_challenge/src/common_widget/menu_item_row.dart';
import 'package:dribbble_challenge/src/common_widget/round_button.dart';
import 'package:dribbble_challenge/src/view/menu/food_item_details_view.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';

import '../../common_widget/popular_resutaurant_row.dart';
import '../more/my_order_view.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  TextEditingController txtSearch = TextEditingController();

  List offerArr = [
    {
      "image": "assets/img/offer_1.png",
      "name": "Café de Noires",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_2.png",
      "name": "Isso",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_3.png",
      "name": "Cafe Beans",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_1.png",
      "name": "Café de Noires",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/offer_2.png",
      "name": "Isso",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
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
   
    {
      "image": "assets/img/chamussas.jpg",
      "name": "Chamuças, rissóis e spring rolls",
      "rate": "4.9",
      "rating": "124",
      "type": "Petiscos",
      "food_type": "Entradas/Starters",
      "description":
          "Variedade de salgados incluindo chamuças, rissóis e rolinhos primavera.",
      "price": 75.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name":
          "Lulas grelhadas com batata cozida e vegetais/grilled calamary whith boild potatos and vegetables",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Lula",
      "food_type": "Marisco/Seafood",
      "description":
          "Lulas frescas grelhadas, servidas com batatas cozidas e legumes da estação.",
      "price": 900.00,
    },
     {
      "image": "assets/img/beef_2.png",
      "name": "Bife de vaca/Beef steak",
      "rate": "4.9",
      "rating": "124",
      "type": "Cortes Premium",
      "food_type": "Carne/Beef",
      "description": "Bife de carne bovina grelhado no ponto desejado.",
      "price": 900.00,
    },
    {
      "image": "assets/img/beef_2.png",
      "name":
          "Bisteca com xima ou arroz ou batata frita/T-bone with xima or rice or chips",
      "rate": "4.9",
      "rating": "124",
      "type": "Cortes Premium",
      "food_type": "Carne/Beef",
      "description":
          "Bisteca tipo T-bone servida com acompanhamento à escolha: xima, arroz ou batata frita.",
      "price": 900.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name": "Camarão grelhado/grilled prawns",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Camarão",
      "food_type": "Marisco/Seafood",
      "description": "Camarões frescos grelhados com temperos especiais.",
      "price": 1000.00,
    },
    {
      "image": "assets/img/sopa_2.jpg",
      "name": "Sopa do dia/soup of the day",
      "rate": "4.9",
      "rating": "124",
      "type": "Sopas",
      "food_type": "Entradas/Starters",
      "description": "Sopa fresca preparada com ingredientes do dia.",
      "price": 300.00,
    },
    {
      "image": "assets/img/azeitonas.jpeg",
      "name": "Azeitonas/Olives",
      "rate": "4.9",
      "rating": "124",
      "type": "Petiscos",
      "food_type": "Entradas/Starters",
      "description": "Porção de azeitonas temperadas.",
      "price": 130.00,
    },
    {
      "image": "assets/img/petiscos.jpg",
      "name": "Moelas/gizzards",
      "rate": "4.9",
      "rating": "124",
      "type": "Petiscos",
      "food_type": "Entradas/Starters",
      "description": "Moelas de galinha refogadas com temperos especiais.",
      "price": 250.00,
    },
     {
      "image": "assets/img/sopa_2.jpg",
      "name": "Sopa de cabeça de peixe/fish head soup",
      "rate": "4.9",
      "rating": "124",
      "type": "Sopas",
      "food_type": "Entradas/Starters",
      "description":
          "Sopa tradicional preparada com cabeça de peixe, rica em sabor.",
      "price": 300.00,
    },
    {
      "image": "assets/img/muelas.png",
      "name": "Espeto de moelas/Gizzard skewer",
      "rate": "4.9",
      "rating": "124",
      "type": "Petiscos",
      "food_type": "Entradas/Starters",
      "description": "Espetinho de moelas grelhadas.",
      "price": 250.00,
    },
    {
      "image": "assets/img/salada_.jpg",
      "name": "Salada grega/Greek salad",
      "rate": "4.9",
      "rating": "124",
      "type": "Saladas",
      "food_type": "Entradas/Starters",
      "description":
          "Salada típica grega com pepino, tomate, cebola, azeitonas e queijo feta.",
      "price": 400.00,
    },
    {
      "image": "assets/img/salada_.jpg",
      "name": "Salada de atum/Tuna salad",
      "rate": "4.9",
      "rating": "124",
      "type": "Saladas",
      "food_type": "Entradas/Starters",
      "description":
          "Salada fresca com atum, alface, tomate e outros vegetais.",
      "price": 400.00,
    },
    {
      "image": "assets/img/salada_.jpg",
      "name": "Salada simples/Plain salad",
      "rate": "4.9",
      "rating": "124",
      "type": "Saladas",
      "food_type": "Entradas/Starters",
      "description":
          "Salada básica com folhas verdes, tomate e legumes frescos.",
      "price": 250.00,
    },
    {
      "image": "assets/img/salada_.jpg",
      "name": "Salada de camarão/Prawn salad",
      "rate": "4.9",
      "rating": "124",
      "type": "Saladas",
      "food_type": "Entradas/Starters",
      "description": "Salada fresca com camarões, alface e legumes da estação.",
      "price": 400.00,
    }
  ];

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
                      "Latest Offers",
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
              buildMenuItems(context, filteredMenuItems),
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
