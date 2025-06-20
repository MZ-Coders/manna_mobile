import 'dart:async';

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
  String? restaurantUUID;
  String restaurantName = '';
  bool isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    loadTableId();
    // Iniciar com itens da categoria Entradas/Starters
    // updateMenuItems();
    getDataFromApi();

    txtSearch.addListener(_onSearchChanged);
  }

void _onSearchChanged() {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () {
    setState(() {
      searchText = txtSearch.text.toLowerCase();
      _performSearch();
    });
  });
}

void _performSearch() {
  if (searchText.isEmpty) {
    // Se a pesquisa está vazia, mostrar todos os itens da categoria selecionada
    filteredMenuItems = List.from(originalFilteredItems);
  } else {
    // Pesquisar em TODAS as categorias, não apenas na selecionada
    List<Map<String, dynamic>> allItems = [];
    
    for (var category in allMenuItems) {
      if (category['products'] != null) {
        List products = category['products'];
        
        for (var product in products) {
          Map<String, dynamic> item = {
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
          allItems.add(item);
        }
      }
    }
    
    // Filtrar itens baseado no texto de pesquisa
    filteredMenuItems = allItems.where((item) {
      String itemName = item['name'].toString().toLowerCase();
      String itemDescription = item['description'].toString().toLowerCase();
      String itemType = item['type'].toString().toLowerCase();
      
      return itemName.contains(searchText) || 
             itemDescription.contains(searchText) || 
             itemType.contains(searchText);
    }).toList();
  }
}

  Future<void> loadTableId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = await getTableId();
    setState(() {
      tableId = id;
      restaurantName = prefs.getString('restaurant_name') ?? '';
    });
    print('Table ID: $tableId'); // Aqui o valor real será exibido
  }

  List catArr = [
  ];

  // Categoria selecionada (padrão: Entradas/Starters - ID: 1)
  int selectedCategoryId = 1;

  // Lista de itens filtrados pela categoria
  List filteredMenuItems = [];
  List allMenuItems = [];

  String searchText = '';
  List originalFilteredItems = []; // Para armazenar itens antes da pesquisa

  List popArr = [
  ];

  List mostPopArr = [
  ];

  List recentArr = [
  ];

  List menuItemsArr = [
    
  ];

  List bebidasItems = [
  ];

  // Lista de itens para categoria Verdura/Greenery (ID: 15)
  List verduraItems = [
  ];

// Lista de itens para categoria Doses (ID: 16)
  List dosesItems = [
  ];

// Lista de itens para categoria Sobremesas/Desserts (ID: 17)
  List sobremesasItems = [
  ];

// Lista de itens para categoria Aves/Birds (ID: 13)
  List avesItems = [
  ];

  // Lista de itens para categoria Carne/Beef (ID: 14)
  List carnesItems = [
  ];

  // Lista de itens para categoria Pequeno-Almoço/Breakfast (ID: 12)
  List pequenoAlmocoItems = [
  ];

  // Lista de itens para categoria Marisco/Seafood (ID: 11)
  List mariscoItems = [
  ];

  // Lista de itens para categoria Entradas/Starters (ID: 1)
  List entradasItems = [
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading 
    ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              "Loading menu...",
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (restaurantName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  restaurantName,
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      )
    : SingleChildScrollView(
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
                    Expanded(
                      child: Text(
                        _buildWelcomeMessage(),
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
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
    hintText: searchText.isEmpty ? "Search Food" : "Searching...",
    controller: txtSearch,
    left: Container(
      alignment: Alignment.center,
      width: 30,
      child: searchText.isEmpty 
        ? Image.asset(
            "assets/img/search.png",
            width: 20,
            height: 20,
          )
        : IconButton(
            onPressed: () {
              txtSearch.clear();
              searchText = '';
              _performSearch();
            },
            icon: Icon(
              Icons.clear,
              size: 20,
              color: TColor.secondaryText,
            ),
          ),
    ),
  ),
),
              const SizedBox(height: 20),

// Mostrar resultado da pesquisa se houver texto
if (searchText.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Icon(Icons.search, size: 16, color: TColor.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Searching for "$searchText" - ${filteredMenuItems.length} results found',
            style: TextStyle(
              color: TColor.secondaryText,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  ),

const SizedBox(height: 10),

              // Lista de categorias
             // Lista de categorias (esconder durante pesquisa)
if (searchText.isEmpty)
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
          onTap: () {
            // Limpar pesquisa ao selecionar categoria
            txtSearch.clear();
            searchText = '';
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
              // Seção de itens populares (esconder durante pesquisa)
if (searchText.isEmpty) ...[
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
],

             
              // Seção do menu da categoria selecionada
              // Seção do menu da categoria selecionada
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: ViewAllTitleRow(
    title: searchText.isEmpty 
      ? "Menu: ${catArr.firstWhere((cat) => cat["id"] == selectedCategoryId, orElse: () => {"name": "Carregando..."})["name"]}"
      : "Search Results",
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

    // Verificar se há resultados de pesquisa
  if (searchText.isNotEmpty && filteredMenuItems.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: TColor.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$searchText"',
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              color: TColor.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              txtSearch.clear();
              searchText = '';
              _performSearch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

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
      return Column(
  children: [
    // Mostrar categoria apenas durante pesquisa
    if (searchText.isNotEmpty)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: TColor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          mObj["type"].toString(),
          style: TextStyle(
            color: TColor.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    MenuItemRow(
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
    ),
  ],
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
       return Column(
  children: [
    // Mostrar categoria apenas durante pesquisa
    if (searchText.isNotEmpty)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: TColor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          mObj["type"].toString(),
          style: TextStyle(
            color: TColor.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    MenuItemRow(
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
    ),
  ],
);
      }),
    );
  }
}


void createMostPopularFromAPI() {
  List popularItems = [];
  
  // Pegar alguns produtos de diferentes categorias para mostrar como populares
  for (var category in allMenuItems.take(3)) { // Primeiras 3 categorias
    if (category['products'] != null && (category['products'] as List).isNotEmpty) {
      var products = category['products'] as List;
      
      // Pegar o primeiro produto de cada categoria
      var firstProduct = products.first;
      popularItems.add({
        "id": firstProduct['id'],
        "image": firstProduct['image_url'] ?? "assets/img/sopa_2.jpg",
        "name": firstProduct['name'],
        "rate": "4.9",
        "rating": "124",
        "type": category['category_name'],
        "food_type": category['category_name'],
        "description": firstProduct['description'] ?? '',
        "price": double.tryParse(firstProduct['current_price'].toString()) ?? 0.0,
      });
    }
  }
  
  mostPopArr = popularItems;
}
  // Método para atualizar os itens do menu com base na categoria selecionada
void updateMenuItems() {
  print("=== updateMenuItems chamada ===");
  print("selectedCategoryId: $selectedCategoryId");
  setState(() {
    // Encontrar a categoria selecionada pelos dados reais da API
    var selectedCategory = allMenuItems.firstWhere(
      (category) => category['category_id'] == selectedCategoryId,
      orElse: () => null,
    );

    print("=== Categories ===");
    print("selectedCategory: $selectedCategory");
    
    if (selectedCategory != null && selectedCategory['products'] != null) {
      // Converter produtos da API para o formato esperado
      List<Map<String, dynamic>> categoryItems = (selectedCategory['products'] as List).map((product) {
        return {
          "id": product['id'],
          "image": product['image_url'] ?? "assets/img/dess_1.png", 
          "name": product['name'],
          "rate": "4.9",
          "rating": "124",
          "type": selectedCategory['category_name'],
          "food_type": selectedCategory['category_name'],
          "description": product['description'] ?? '',
          "price": double.tryParse(product['current_price'].toString()) ?? 0.0,
          "regular_price": double.tryParse(product['regular_price'].toString()) ?? 0.0,
          "is_on_promotion": product['is_on_promotion'] ?? false,
        };
      }).toList();
      
      // Armazenar os itens originais antes de aplicar pesquisa
      originalFilteredItems = List.from(categoryItems);
      
      // Aplicar pesquisa se houver texto no campo
      if (searchText.isNotEmpty) {
        _performSearch();
      } else {
        filteredMenuItems = List.from(originalFilteredItems);
      }
      
      print("Número de itens filtrados: ${filteredMenuItems.length}");
    } else {
      originalFilteredItems = [];
      filteredMenuItems = [];
    }
  });
}

  String getDefaultCategoryImage(int index) {
  // Lista de imagens padrão que você pode rotacionar
  List<String> defaultImages = [
    "assets/img/manna_entradas.png",
    "assets/img/manna_marisco.png",
    "assets/img/manna_pequeno_almoco.png",
    "assets/img/manna_aves.png",
    "assets/img/manna_carne.png",
    "assets/img/manna_verdura.png",
    "assets/img/manna_doses.png",
    "assets/img/manna_desserts.png",
    "assets/img/manna_drink.png",
  ];
  
  // Usar módulo para rotacionar as imagens
  return defaultImages[index % defaultImages.length];
}

String _buildWelcomeMessage() {
  String message = "Hello";
  
  // Adicionar nome do usuário se existir
  String userName = ServiceCall.userPayload[KKey.name] ?? "";
  if (userName.isNotEmpty) {
    message += " $userName";
  }
  
  message += "!";
  
  // Adicionar informação da mesa apenas se existir
  if (tableId != null && tableId!.isNotEmpty) {
    message += "\nYour Table is $tableId";
  }
  
  // Adicionar nome do restaurante
  if (restaurantName.isNotEmpty) {
    message += "\nWelcome to $restaurantName";
  }
  
  return message;
}

  void createCategoriesFromAPI() {
  print("=== createCategoriesFromAPI chamada ===");
  print("Número de categorias na API: ${allMenuItems.length}");

  List newCatArr = [];
  
  for (int i = 0; i < allMenuItems.length; i++) {
    var menuCategory = allMenuItems[i];
    
    newCatArr.add({
      "id": menuCategory['category_id'], // Usar o ID real da API
      "image": menuCategory['image_url'], // Imagem da API
      "name": menuCategory['category_name']
    });
  }
  
  catArr = newCatArr;
}

 // Give function to receive data from API
Future<void> getDataFromApi() async {

  final prefs = await SharedPreferences.getInstance();
  String? restaurantUUID = prefs.getString('restaurant_id');
  
  try {
    ServiceCall.getMenuItems(restaurantUUID ?? '',
        withSuccess: (Map<String, dynamic> data) {
          if (data.containsKey('menu') && data['menu'] != null) {
            if (data['menu'] is List && (data['menu'] as List).isNotEmpty) {
              setState(() {
                // Armazenar todos os dados do menu
                allMenuItems = data['menu'];
                
                // Criar categorias dinamicamente baseadas na API
                createCategoriesFromAPI();
                
                // Selecionar a primeira categoria automaticamente
                if (catArr.isNotEmpty) {
                  selectedCategoryId = catArr[0]['id'];
                  updateMenuItems();
                }
                
                // Criar itens populares dinamicamente
                createMostPopularFromAPI();

                isLoading = false;
              });
              
              print("Menu carregado com ${allMenuItems.length} categorias");
            }
          }
        },
        failure: (String error) {
          setState(() {
            isLoading = false; // ADICIONAR ESTA LINHA
          });
          print("Erro ao buscar dados: $error");
        });
  } catch (e) {
    print("Error fetching data: $e");
    setState(() {
    isLoading = false; // ADICIONAR ESTA LINHA
  });
  }
}

@override
void dispose() {
  _debounce?.cancel();
  txtSearch.removeListener(_onSearchChanged);
  txtSearch.dispose();
  super.dispose();
}
}
