import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/common_widget/menu_item_row.dart';
import 'package:dribbble_challenge/src/common_widget/round_textfield.dart';
import 'package:dribbble_challenge/src/view/menu/food_item_details_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/most_popular_cell.dart';
import '../../common_widget/popular_resutaurant_row.dart';
import '../../common_widget/recent_item_row.dart';
import '../../common_widget/view_all_title_row.dart';
import '../more/my_order_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

Future<String?> getTableId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('table_id');
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();
  String? tableId;

  @override
  void initState() {
    super.initState();
    loadTableId();
    // Iniciar com itens da categoria Entradas/Starters
    updateMenuItems();
  }

  Future<void> loadTableId() async {
    final id = await getTableId();
    setState(() {
      tableId = id;
    });
    print('Table ID: $tableId'); // Aqui o valor real será exibido
  }

  List catArr = [
    {
      "id": 1,
      "image": "assets/img/manna_entradas.png",
      "name": "Entradas/Starters"
    },
    {
      "id": 11,
      "image": "assets/img/manna_marisco.png",
      "name": "Marisco/Seafood"
    },
    {
      "id": 12,
      "image": "assets/img/manna_pequeno_almoco.png",
      "name": "Breakfast"
    },
    {"id": 13, "image": "assets/img/manna_aves.png", "name": "Aves/Birds"},
    {"id": 14, "image": "assets/img/manna_carne.png", "name": "Carne/Beef"},
    {
      "id": 15,
      "image": "assets/img/manna_verdura.png",
      "name": "Verdura/Greenery"
    },
    {"id": 16, "image": "assets/img/manna_doses.png", "name": "Doses"},
    {
      "id": 17,
      "image": "assets/img/manna_desserts.png",
      "name": "Sobremesas/Desserts"
    },
    {
      "id": 18,
      "image": "assets/img/manna_drink.png",
      "name": "Bebidas/Beverages"
    },
  ];

  // Categoria selecionada (padrão: Entradas/Starters - ID: 1)
  int selectedCategoryId = 1;

  // Lista de itens filtrados pela categoria
  List filteredMenuItems = [];

  List popArr = [
    {
      "image": "assets/img/res_1.png",
      "name": "Minute by tuk tuk",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/res_2.png",
      "name": "Café de Noir",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/res_3.png",
      "name": "Bakes by Tella",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
  ];

  List mostPopArr = [
    {
      "image": "assets/img/sopa_2.jpg",
      "name": "Sopa do dia/soup of the day",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food",
      "description": "Sopa fresca preparada com ingredientes do dia.",
      "price": 300.00,
    },
    {
      "image": "assets/img/chamussas.jpg",
      "name": "Variedade de salgados",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food",
      "description":
          "Variedade de salgados incluindo chamuças, rissóis e rolinhos primavera.",
      "price": 75.00,
    },
  ];

  List recentArr = [
    {
      "image": "assets/img/item_1.png",
      "name": "Mulberry Pizza by Josh",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/item_2.png",
      "name": "Barita",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/item_3.png",
      "name": "Pizza Rush Hour",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
  ];

  List menuItemsArr = [
    {
      "image": "assets/img/dess_1.png",
      "name": "French Apple Pie",
      "rate": "4.9",
      "rating": "124",
      "type": "Minute by tuk tuk",
      "food_type": "Desserts",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/dess_2.png",
      "name": "Dark Chocolate Cake",
      "rate": "4.9",
      "rating": "124",
      "type": "Cakes by Tella",
      "food_type": "Desserts",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/dess_3.png",
      "name": "Street Shake",
      "rate": "4.9",
      "rating": "124",
      "type": "Café Racer",
      "food_type": "Desserts",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/dess_4.png",
      "name": "Fudgy Chewy Brownies",
      "rate": "4.9",
      "rating": "124",
      "type": "Minute by tuk tuk",
      "food_type": "Desserts",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/dess_1.png",
      "name": "French Apple Pie",
      "rate": "4.9",
      "rating": "124",
      "type": "Minute by tuk tuk",
      "food_type": "Desserts",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/dess_2.png",
      "name": "Dark Chocolate Cake",
      "rate": "4.9",
      "rating": "124",
      "type": "Cakes by Tella",
      "food_type": "Desserts",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/dess_3.png",
      "name": "Street Shake",
      "rate": "4.9",
      "rating": "124",
      "type": "Café Racer",
      "food_type": "Desserts",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
    {
      "image": "assets/img/dess_4.png",
      "name": "Fudgy Chewy Brownies",
      "rate": "4.9",
      "rating": "124",
      "type": "Minute by tuk tuk",
      "food_type": "Desserts",
      "description":
          "Delicious apple pie with a flaky crust and sweet filling.",
      "price": 5.99,
    },
  ];

  List bebidasItems = [
    {
      "image": "assets/img/wine.png",
      "name": "Café expresso/Express coffee",
      "rate": "4.9",
      "rating": "124",
      "type": "Café & Drinks",
      "food_type": "Bebidas/Beverages",
      "description": "Café expresso tradicional, forte e aromático.",
      "price": 100.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Café com leite/Coffee with milk",
      "rate": "4.9",
      "rating": "124",
      "type": "Café & Drinks",
      "food_type": "Bebidas/Beverages",
      "description": "Café expresso com leite cremoso.",
      "price": 150.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Copo de leite/Cup of milk",
      "rate": "4.9",
      "rating": "124",
      "type": "Café & Drinks",
      "food_type": "Bebidas/Beverages",
      "description": "Copo de leite puro e fresco.",
      "price": 120.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Chocolate quente/Hot chocolate",
      "rate": "4.9",
      "rating": "124",
      "type": "Café & Drinks",
      "food_type": "Bebidas/Beverages",
      "description": "Chocolate quente cremoso e reconfortante.",
      "price": 150.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Chá simples/Tea",
      "rate": "4.9",
      "rating": "124",
      "type": "Café & Drinks",
      "food_type": "Bebidas/Beverages",
      "description": "Variedade de chás selecionados.",
      "price": 70.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Agua das pedras/Sparkling water",
      "rate": "4.9",
      "rating": "124",
      "type": "Bebidas Frescas",
      "food_type": "Bebidas/Beverages",
      "description": "Água com gás natural das pedras.",
      "price": 100.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Agua 500ml/Spring water 500ml",
      "rate": "4.9",
      "rating": "124",
      "type": "Bebidas Frescas",
      "food_type": "Bebidas/Beverages",
      "description": "Água mineral natural 500ml.",
      "price": 60.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Agua 1.5l/Spring water 1.5l",
      "rate": "4.9",
      "rating": "124",
      "type": "Bebidas Frescas",
      "food_type": "Bebidas/Beverages",
      "description": "Água mineral natural 1,5 litros.",
      "price": 120.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Refresco em lata",
      "rate": "4.9",
      "rating": "124",
      "type": "Refrigerantes",
      "food_type": "Bebidas/Beverages",
      "description": "Refrigerante em lata, diversas opções.",
      "price": 70.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Refresco em garrafa",
      "rate": "4.9",
      "rating": "124",
      "type": "Refrigerantes",
      "food_type": "Bebidas/Beverages",
      "description": "Refrigerante em garrafa, diversas opções.",
      "price": 40.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Sumo 1l/Juice 1l",
      "rate": "4.9",
      "rating": "124",
      "type": "Sucos Naturais",
      "food_type": "Bebidas/Beverages",
      "description": "Suco natural de frutas, garrafa de 1 litro.",
      "price": 185.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Red bull",
      "rate": "4.9",
      "rating": "124",
      "type": "Energéticos",
      "food_type": "Bebidas/Beverages",
      "description": "Bebida energética Red Bull.",
      "price": 150.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Sumo minut maid",
      "rate": "4.9",
      "rating": "124",
      "type": "Sucos Naturais",
      "food_type": "Bebidas/Beverages",
      "description": "Suco da marca Minute Maid, diversas opções de sabores.",
      "price": 90.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "Cocktail de frutas/Fruit cocktail",
      "rate": "4.9",
      "rating": "124",
      "type": "Sucos Especiais",
      "food_type": "Bebidas/Beverages",
      "description": "Cocktail de frutas frescas mistas.",
      "price": 250.00,
    },
    {
      "image": "assets/img/wine.png",
      "name": "ENTRADA DE BEBIDAS PAGA-SE ROLHA",
      "rate": "4.9",
      "rating": "124",
      "type": "Taxas",
      "food_type": "Bebidas/Beverages",
      "description": "Taxa para entrada de bebidas externas.",
      "price": 250.00,
    }
  ];

  // Lista de itens para categoria Verdura/Greenery (ID: 15)
  List verduraItems = [
    {
      "image": "assets/img/verdura.png",
      "name": "Couve com arroz ou xima/Cabbage with rice or xima",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos Vegetarianos",
      "food_type": "Verdura/Greenery",
      "description": "Couve refogada servida com arroz ou xima à escolha.",
      "price": 380.00,
    },
    {
      "image": "assets/img/verdura.png",
      "name": "Matapa com arroz ou xima/matapa with rice or xima",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos Vegetarianos",
      "food_type": "Verdura/Greenery",
      "description": "Matapa tradicional servida com arroz ou xima à escolha.",
      "price": 380.00,
    }
  ];

// Lista de itens para categoria Doses (ID: 16)
  List dosesItems = [
    {
      "image": "assets/img/doses.png",
      "name": "Dose de cove/Cabbage",
      "rate": "4.9",
      "rating": "124",
      "type": "Acompanhamentos",
      "food_type": "Doses",
      "description": "Porção de couve refogada.",
      "price": 100.00,
    },
    {
      "image": "assets/img/doses.png",
      "name": "Dose de repolho/Cabbage",
      "rate": "4.9",
      "rating": "124",
      "type": "Acompanhamentos",
      "food_type": "Doses",
      "description": "Porção de repolho refogado.",
      "price": 100.00,
    },
    {
      "image": "assets/img/doses.png",
      "name": "Dose de batata/Portion of chips",
      "rate": "4.9",
      "rating": "124",
      "type": "Acompanhamentos",
      "food_type": "Doses",
      "description": "Porção de batatas fritas crocantes.",
      "price": 150.00,
    },
    {
      "image": "assets/img/doses.png",
      "name": "Dose de xima/Portion of xima",
      "rate": "4.9",
      "rating": "124",
      "type": "Acompanhamentos",
      "food_type": "Doses",
      "description": "Porção de xima tradicional.",
      "price": 100.00,
    },
    {
      "image": "assets/img/doses.png",
      "name": "Dose de arroz/Portion of rice",
      "rate": "4.9",
      "rating": "124",
      "type": "Acompanhamentos",
      "food_type": "Doses",
      "description": "Porção de arroz branco soltinho.",
      "price": 150.00,
    }
  ];

// Lista de itens para categoria Sobremesas/Desserts (ID: 17)
  List sobremesasItems = [
    {
      "image": "assets/img/desserts.png",
      "name": "Pudim/Pudding",
      "rate": "4.9",
      "rating": "124",
      "type": "Doces & Sobremesas",
      "food_type": "Sobremesas/Desserts",
      "description": "Pudim caseiro com calda de caramelo.",
      "price": 200.00,
    },
    {
      "image": "assets/img/desserts.png",
      "name": "Salada de frutas/Fruit salad",
      "rate": "4.9",
      "rating": "124",
      "type": "Doces & Sobremesas",
      "food_type": "Sobremesas/Desserts",
      "description": "Salada de frutas frescas da estação.",
      "price": 200.00,
    },
    {
      "image": "assets/img/desserts.png",
      "name": "Sorvete/Ice cream",
      "rate": "4.9",
      "rating": "124",
      "type": "Doces & Sobremesas",
      "food_type": "Sobremesas/Desserts",
      "description": "Sorvete cremoso em diversos sabores.",
      "price": 200.00,
    }
  ];

// Lista de itens para categoria Aves/Birds (ID: 13)
  List avesItems = [
    {
      "image": "assets/img/aves_1.png",
      "name": "Frango grelhado com batatas fritas/Grilled chicken with chips",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Frango",
      "food_type": "Aves/Birds",
      "description":
          "Frango inteiro grelhado servido com batatas fritas crocantes.",
      "price": 950.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name":
          "½ frango grelhado com batatas fritas/½ grilled chicken with chips",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Frango",
      "food_type": "Aves/Birds",
      "description":
          "Meio frango grelhado servido com batatas fritas crocantes.",
      "price": 500.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name":
          "Galinha cafreal grelhado com batatas fritas/Grilled cafreal chicken with Chips",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Frango",
      "food_type": "Aves/Birds",
      "description":
          "Galinha cafreal inteira grelhada servida com batatas fritas.",
      "price": 1100.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name":
          "½ Galinha cafreal grelhado com batatas fritas/½ Grilled cafreal chicken with Chips",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Frango",
      "food_type": "Aves/Birds",
      "description":
          "Meia galinha cafreal grelhada servida com batatas fritas.",
      "price": 600.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name": "Frango grealhado a zambeziana",
      "rate": "4.9",
      "rating": "124",
      "type": "Especialidades Regionais",
      "food_type": "Aves/Birds",
      "description":
          "Frango grelhado no estilo zambeziano, temperado com especiarias locais.",
      "price": 1200.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name": "Galinha cafreal a zambeziana",
      "rate": "4.9",
      "rating": "124",
      "type": "Especialidades Regionais",
      "food_type": "Aves/Birds",
      "description":
          "Galinha cafreal preparada no estilo zambeziano com temperos tradicionais.",
      "price": 1200.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name": "Tocossado de galinha cafreal/cafreal chicken stew",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Frango",
      "food_type": "Aves/Birds",
      "description": "Ensopado de galinha cafreal com legumes e especiarias.",
      "price": 500.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name": "Caril de galinha cafreal/Cafreal chicken curry",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Frango",
      "food_type": "Aves/Birds",
      "description": "Caril de galinha cafreal com especiarias aromáticas.",
      "price": 500.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name":
          "Frango à Rio Sol c/batata,arroz e salada/Chicken by Garden with potatoes, rice and salad",
      "rate": "4.9",
      "rating": "124",
      "type": "Especialidades da Casa",
      "food_type": "Aves/Birds",
      "description":
          "Frango especial do restaurante servido com batatas, arroz e salada fresca.",
      "price": 1000.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name":
          "Cafreal à Rio Sol c/batata,arroz e salada/Chicken by Garden with potatoes, rice and salad",
      "rate": "4.9",
      "rating": "124",
      "type": "Especialidades da Casa",
      "food_type": "Aves/Birds",
      "description":
          "Frango cafreal especial do restaurante servido com batatas, arroz e salada fresca.",
      "price": 1150.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name": "Asinhas de frango/chicken wings",
      "rate": "4.9",
      "rating": "124",
      "type": "Entradas & Petiscos",
      "food_type": "Aves/Birds",
      "description": "Asinhas de frango temperadas e grelhadas.",
      "price": 350.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name": "Codorniz c/Batatas",
      "rate": "4.9",
      "rating": "124",
      "type": "Especialidades da Casa",
      "food_type": "Aves/Birds",
      "description": "Codorniz grelhada servida com batatas.",
      "price": 500.00,
    },
    {
      "image": "assets/img/aves_1.png",
      "name": "Combo de frango e camarão",
      "rate": "4.9",
      "rating": "124",
      "type": "Combinados Especiais",
      "food_type": "Aves/Birds",
      "description": "Combinação de frango grelhado e camarões.",
      "price": 1750.00,
    }
  ];

  // Lista de itens para categoria Carne/Beef (ID: 14)
  List carnesItems = [
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
      "image": "assets/img/beef_2.png",
      "name": "Espetada de carne de vaca/Beef skewered",
      "rate": "4.9",
      "rating": "124",
      "type": "Grelhados",
      "food_type": "Carne/Beef",
      "description": "Cubos de carne bovina temperados e grelhados no espeto.",
      "price": 750.00,
    },
    {
      "image": "assets/img/beef_2.png",
      "name":
          "Caril de carne de vaca c/ xima ou arroz/beef curry with rice or xima",
      "rate": "4.9",
      "rating": "124",
      "type": "Ensopados",
      "food_type": "Carne/Beef",
      "description":
          "Caril de carne bovina aromático servido com xima ou arroz à escolha.",
      "price": 500.00,
    },
    {
      "image": "assets/img/beef_2.png",
      "name":
          "Vorse com molho de tomate e xima/Vorse with tomate sauce na xima",
      "rate": "4.9",
      "rating": "124",
      "type": "Ensopados",
      "food_type": "Carne/Beef",
      "description":
          "Vorse (linguiça defumada) cozido em molho de tomate servido com xima.",
      "price": 500.00,
    },
    {
      "image": "assets/img/beef_2.png",
      "name": "Feijoada",
      "rate": "4.9",
      "rating": "124",
      "type": "Especialidades Tradicionais",
      "food_type": "Carne/Beef",
      "description": "Feijoada tradicional com carnes variadas e feijão preto.",
      "price": 500.00,
    },
    {
      "image": "assets/img/beef_2.png",
      "name": "Prego no pao/steak roll",
      "rate": "4.9",
      "rating": "124",
      "type": "Sanduíches",
      "food_type": "Carne/Beef",
      "description": "Bife de carne bovina servido em pão.",
      "price": 200.00,
    },
    {
      "image": "assets/img/beef_2.png",
      "name": "Prego no prato/steak on plate",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos Rápidos",
      "food_type": "Carne/Beef",
      "description":
          "Bife de carne bovina servido no prato com acompanhamentos.",
      "price": 350.00,
    },
    {
      "image": "assets/img/beef_2.png",
      "name": "Hambúrguer completo/complete hamburger",
      "rate": "4.9",
      "rating": "124",
      "type": "Sanduíches",
      "food_type": "Carne/Beef",
      "description": "Hambúrguer completo com todos os acompanhamentos.",
      "price": 300.00,
    },
    {
      "image": "assets/img/beef_2.png",
      "name": "Travessa de carnes",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos para Compartilhar",
      "food_type": "Carne/Beef",
      "description":
          "Travessa com variedade de carnes grelhadas para compartilhar.",
      "price": 2000.00,
    }
  ];

  // Lista de itens para categoria Pequeno-Almoço/Breakfast (ID: 12)
  List pequenoAlmocoItems = [
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Omelete simples/Plain omelett",
      "rate": "4.9",
      "rating": "124",
      "type": "Omeletes",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description": "Omelete simples preparada com ovos frescos.",
      "price": 200.00,
    },
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Omelete de queijo/Cheese omelett",
      "rate": "4.9",
      "rating": "124",
      "type": "Omeletes",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description": "Omelete recheada com queijo derretido.",
      "price": 250.00,
    },
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Omelete de camarão/Prawn omelett",
      "rate": "4.9",
      "rating": "124",
      "type": "Omeletes",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description": "Omelete especial recheada com camarões.",
      "price": 300.00,
    },
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Omelete mista",
      "rate": "4.9",
      "rating": "124",
      "type": "Omeletes",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description":
          "Omelete com recheio variado de queijo, presunto e vegetais.",
      "price": 350.00,
    },
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Tosta de queijo/Toasted cheese",
      "rate": "4.9",
      "rating": "124",
      "type": "Tostas",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description": "Pão tostado com queijo derretido.",
      "price": 150.00,
    },
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Tosta de atum e maionese/Toasted tuna and mayo",
      "rate": "4.9",
      "rating": "124",
      "type": "Tostas",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description": "Pão tostado com atum e maionese.",
      "price": 200.00,
    },
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Sandes de ovo",
      "rate": "4.9",
      "rating": "124",
      "type": "Sanduíches",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description": "Sanduíche de ovo fresco.",
      "price": 150.00,
    },
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Sandes de queijo",
      "rate": "4.9",
      "rating": "124",
      "type": "Sanduíches",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description": "Sanduíche de queijo fatiado.",
      "price": 150.00,
    },
    {
      "image": "assets/img/pequeno_1.png",
      "name": "Pão de alho/garlic bread",
      "rate": "4.9",
      "rating": "124",
      "type": "Acompanhamentos",
      "food_type": "Pequeno-Almoço/Breakfast",
      "description": "Pão fresco assado com manteiga de alho e ervas.",
      "price": 200.00,
    }
  ];

  // Lista de itens para categoria Marisco/Seafood (ID: 11)
  List mariscoItems = [
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
      "image": "assets/img/fish_02.png",
      "name": "Camarão frito/fried prawns",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Camarão",
      "food_type": "Marisco/Seafood",
      "description":
          "Camarões empanados e fritos até ficarem dourados e crocantes.",
      "price": 900.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name": "Travessa de camarão/platter of prawns",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos para Compartilhar",
      "food_type": "Marisco/Seafood",
      "description":
          "Generosa travessa de camarões preparados de diferentes maneiras.",
      "price": 2050.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name":
          "Posta de peixe grelhado(Serra, garoupa, vermelhão, pedra)/slice of grilled (Serra fish, redfish, grouper fish, and stone fish)",
      "rate": "4.9",
      "rating": "124",
      "type": "Peixes Grelhados",
      "food_type": "Marisco/Seafood",
      "description":
          "Posta de peixe fresco grelhado, com opções de serra, garoupa, vermelhão ou peixe pedra.",
      "price": 900.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name": "Peixe do dia tocossado/fish stew of the day",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Peixe",
      "food_type": "Marisco/Seafood",
      "description": "Ensopado de peixe do dia com legumes e especiarias.",
      "price": 900.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name": "Peixe do dia grelhado/grilled fish of the day",
      "rate": "4.9",
      "rating": "124",
      "type": "Peixes Grelhados",
      "food_type": "Marisco/Seafood",
      "description": "Peixe fresco do dia grelhado com ervas aromáticas.",
      "price": 900.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name": "Travessa de marisco/seafood plater for one",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos para Compartilhar",
      "food_type": "Marisco/Seafood",
      "description":
          "Travessa variada de mariscos para uma pessoa, incluindo peixes, camarões e lulas.",
      "price": 1550.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name": "Travessa de marisco a dois/seafood plater for two",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos para Compartilhar",
      "food_type": "Marisco/Seafood",
      "description":
          "Generosa travessa de mariscos variados para duas pessoas, com seleção de peixes, camarões e frutos do mar.",
      "price": 2900.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name": "Chicoa c/arroz",
      "rate": "4.9",
      "rating": "124",
      "type": "Especialidades Regionais",
      "food_type": "Marisco/Seafood",
      "description":
          "Prato tradicional de chicoa (peixe seco) servido com arroz.",
      "price": 500.00,
    },
    {
      "image": "assets/img/fish_02.png",
      "name": "Filé de peixe/fish fillet",
      "rate": "4.9",
      "rating": "124",
      "type": "Pratos de Peixe",
      "food_type": "Marisco/Seafood",
      "description": "Filé de peixe fresco preparado ao seu gosto.",
      "price": 1250.00,
    }
  ];

  // Lista de itens para categoria Entradas/Starters (ID: 1)
  List entradasItems = [
   
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
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hello, your Table is \n${this.tableId} ${ServiceCall.userPayload[KKey.name] ?? ""}!",
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
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "Search Food",
                  controller: txtSearch,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Lista de categorias
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: catArr.length,
                  itemBuilder: ((context, index) {
                    var cObj = catArr[index] as Map? ?? {};
                    bool isSelected = cObj["id"] == selectedCategoryId;

                    return CategoryCell(
                      cObj: cObj,
                      // isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedCategoryId = cObj["id"];
                          updateMenuItems();
                        });
                      },
                    );
                  }),
                ),
              ),

              // Seção de itens populares
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title: "Most Popular",
                  onView: () {},
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: mostPopArr.length,
                  itemBuilder: ((context, index) {
                    var mObj = mostPopArr[index] as Map? ?? {};
                    return MostPopularCell(
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
                ),
              ),

              // Seção do menu da categoria selecionada
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title:
                      "Menu: ${catArr.firstWhere((cat) => cat["id"] == selectedCategoryId, orElse: () => {
                            "name": ""
                          })["name"]}",
                  onView: () {},
                ),
              ),
              // 
              buildMenuItems(context, filteredMenuItems),

              // Seção de itens recentes
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: ViewAllTitleRow(
              //     title: "Recent Items",
              //     onView: () {},
              //   ),
              // ),
              // ListView.builder(
              //   physics: const NeverScrollableScrollPhysics(),
              //   shrinkWrap: true,
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
              //   itemCount: recentArr.length,
              //   itemBuilder: ((context, index) {
              //     var rObj = recentArr[index] as Map? ?? {};
              //     return RecentItemRow(
              //       rObj: rObj,
              //       onTap: () {},
              //     );
              //   }),
              // )
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
  // Método para atualizar os itens do menu com base na categoria selecionada
  void updateMenuItems() {
    setState(() {
      switch (selectedCategoryId) {
        case 1:
          filteredMenuItems = entradasItems;
          break;
        case 11:
          filteredMenuItems = mariscoItems;
          break;
        case 12:
          filteredMenuItems = pequenoAlmocoItems;
          break;
        case 13:
          filteredMenuItems = avesItems;
          break;
        case 14:
          filteredMenuItems = carnesItems;
          break;
        case 15:
          filteredMenuItems = verduraItems;
          break;
        case 16:
          filteredMenuItems = dosesItems;
          break;
        case 17:
          filteredMenuItems = sobremesasItems;
          break;
        case 18:
          filteredMenuItems = bebidasItems;
          break;
        default:
          filteredMenuItems = entradasItems;
      }
    });
  }
}
