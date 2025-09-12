import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common/menu_data_service.dart';
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
  List eventItems = []; // Eventos do restaurante
  List dailySpecialsItems = []; // Ofertas do dia
  bool isLoading = true;
  
  // Estado para controlar qual visualização está ativa: 'offers', 'events' ou 'daily'
  String currentView = 'offers';

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
  List filteredMenuItems = [];

  @override
  void initState() {
    super.initState();
    loadRestaurantData();
    loadMenuData();
  }

  Future<void> loadRestaurantData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      restaurantName = prefs.getString('restaurant_name') ?? '';
    });
  }

  // Função para carregar dados usando o serviço centralizado
  Future<void> loadMenuData() async {
    setState(() {
      isLoading = true;
    });
    
    // Verificar se o MenuDataService já tem os dados carregados
    if (MenuDataService().isInitialized) {
      // Usar os dados já em cache
      setState(() {
        allMenuItems = MenuDataService().menuItems;
        eventItems = MenuDataService().events;
        dailySpecialsItems = MenuDataService().dailySpecials;
        
        // Filtrar itens em promoção
        filterPromotionItems();
        
        isLoading = false;
      });
      
      print("Dados carregados do cache:");
      print("- Menu: ${allMenuItems.length} categorias");
      print("- Eventos: ${eventItems.length}");
      print("- Ofertas do dia: ${dailySpecialsItems.length}");
      print("- Itens em promoção: ${promotionItems.length}");
    } else {
      // Inicializar o serviço se ainda não estiver inicializado
      final success = await MenuDataService().initialize();
      
      if (success) {
        setState(() {
          allMenuItems = MenuDataService().menuItems;
          eventItems = MenuDataService().events;
          dailySpecialsItems = MenuDataService().dailySpecials;
          
          // Filtrar itens em promoção
          filterPromotionItems();
          
          isLoading = false;
        });

        print("Dados carregados da API:");
        print("- Menu: ${allMenuItems.length} categorias");
        print("- Eventos: ${eventItems.length}");
        print("- Ofertas do dia: ${dailySpecialsItems.length}");
        print("- Itens em promoção: ${promotionItems.length}");
      } else {
        // Caso a inicialização falhe, tentar carregar diretamente
        getDataFromApi();
        getEventsFromApi();
      }
    }
  }

  // Métodos originais mantidos como fallback em caso de falha do serviço
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
            
            // Processar daily_specials
            if (data.containsKey('daily_specials') && data['daily_specials'] != null) {
              if (data['daily_specials'] is List) {
                setState(() {
                  List rawDailySpecials = data['daily_specials'];
                  List formattedDailySpecials = [];

                  for (var special in rawDailySpecials) {
                    formattedDailySpecials.add({
                      "id": special['id'],
                      "image": special['image_url'] ?? "assets/img/offer_3.png",
                      "name": special['name'],
                      "description": special['description'],
                      "price": double.tryParse(special['price'].toString()) ?? 0.0,
                      "type": "daily_special",
                      "food_type": "Ofertas do Dia",
                      "rate": "4.9",
                      "rating": "124",
                    });
                  }
                  
                  dailySpecialsItems = formattedDailySpecials;
                });
                
                print("Ofertas do dia carregadas: ${dailySpecialsItems.length}");
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

  // Buscar eventos do restaurante
  Future<void> getEventsFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    String? restaurantUUID = prefs.getString('restaurant_id');
    
    try {
      // Usando a mesma API que retorna menu, que também retorna eventos
      ServiceCall.getMenuItems(restaurantUUID ?? '',
          withSuccess: (Map<String, dynamic> data) {
            if (data.containsKey('events') && data['events'] != null) {
              if (data['events'] is List) {
                setState(() {
                  List rawEvents = data['events'];
                  List formattedEvents = [];
                  
                  for (var event in rawEvents) {
                    // Formatando dados do evento para exibição
                    formattedEvents.add({
                      "id": event['id'],
                      "image": event['image_url'] ?? "assets/img/offer_3.png",
                      "name": event['title'],
                      "description": event['description'],
                      "event_date": event['event_date'],
                      "type": event['type'],
                    });
                  }
                  
                  eventItems = formattedEvents;
                  isLoading = false;
                });
                
                print("Eventos carregados: ${eventItems.length}");
              }
            }
          },
          failure: (String error) {
            print("Erro ao buscar eventos: $error");
            setState(() {
              isLoading = false;
            });
          });
    } catch (e) {
      print("Error fetching events: $e");
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
                  children: [
                    // Texto com Expanded para evitar overflow
                    Flexible(
                      child: Expanded(
                        child: Text(
                          (currentView == 'offers' ? 
                            AppLocalizations.of(context).latestOffers : 
                            "Eventos") + " - $restaurantName",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                          // overflow: TextOverflow.ellipsis, // Adiciona "..." se muito longo
                          // maxLines: 1, // Limita a uma linha
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Espaçamento entre texto e ícone
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
                      currentView == 'offers' ?
                        AppLocalizations.of(context).findDiscounts :
                        currentView == 'events' ?
                        "Confira os próximos eventos e promoções" :
                        "Confira as ofertas especiais de hoje",
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
                child: Row(
                  children: [
                    // Botão para alternar para Ofertas
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: RoundButton(
                          title: AppLocalizations.of(context).checkOffers, 
                          fontSize: 12,
                          onPressed: () {
                            setState(() {
                              currentView = 'offers';
                            });
                          },
                          type: currentView == 'offers' 
                              ? RoundButtonType.bgPrimary 
                              : RoundButtonType.textPrimary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Botão para alternar para Do Dia
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: RoundButton(
                          title: "Do Dia",
                          fontSize: 12,
                          onPressed: () {
                            setState(() {
                              currentView = 'daily';
                            });
                          },
                          type: currentView == 'daily' 
                              ? RoundButtonType.bgPrimary 
                              : RoundButtonType.textPrimary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Botão para alternar para Eventos
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: RoundButton(
                          title: "Eventos",
                          fontSize: 12,
                          onPressed: () {
                            setState(() {
                              currentView = 'events';
                            });
                          },
                          type: currentView == 'events' 
                              ? RoundButtonType.bgPrimary 
                              : RoundButtonType.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              isLoading 
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : currentView == 'offers'
                  ? (promotionItems.isEmpty
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
                                AppLocalizations.of(context).noPromotions,
                                style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context).checkBack,
                                style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : buildMenuItems(context, promotionItems))
                  : currentView == 'daily'
                    ? (dailySpecialsItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.today_outlined,
                                  size: 60,
                                  color: TColor.secondaryText,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Sem ofertas do dia",
                                  style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "Volte amanhã para conferir as ofertas especiais",
                                  style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : buildMenuItems(context, dailySpecialsItems))
                    : (eventItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_outlined,
                                  size: 60,
                                  color: TColor.secondaryText,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Sem eventos disponíveis",
                                  style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "Volte mais tarde para conferir novos eventos",
                                  style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : buildEventsList(context, eventItems)),
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
  
  // Widget para construir a lista de eventos
  Widget buildEventsList(BuildContext context, List eventsList) {
    // Detectar se a tela é larga (web/tablet) ou estreita (mobile)
    bool isWideScreen = MediaQuery.of(context).size.width >= 1000;
    
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 16 : 0),
      itemCount: eventsList.length,
      itemBuilder: ((context, index) {
        var event = eventsList[index] as Map? ?? {};
        return buildEventCard(context, event);
      }),
    );
  }
  
  // Widget para construir um card de evento
  Widget buildEventCard(BuildContext context, Map event) {
    // Formatação da data do evento
    String formattedDate = "";
    if (event['event_date'] != null) {
      try {
        DateTime eventDate = DateTime.parse(event['event_date']);
        formattedDate = "${eventDate.day}/${eventDate.month}/${eventDate.year} às ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        formattedDate = event['event_date'];
      }
    }
    
    // Cor do tipo de evento
    Color typeColor = Colors.blue;
    IconData typeIcon = Icons.event;
    
    if (event['type'] == 'PROMOTION') {
      typeColor = Colors.orange;
      typeIcon = Icons.local_offer;
    } else if (event['type'] == 'ANNOUNCEMENT') {
      typeColor = Colors.green;
      typeIcon = Icons.campaign;
    }
    
    // Verificar se há uma imagem para mostrar
    bool hasImage = event['image'] != null && event['image'].toString().isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho com título e tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: hasImage 
                ? const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  )
                : BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  typeIcon,
                  color: typeColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event['name'] ?? "Evento",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['type'] ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Imagem do evento (se existir)
          if (hasImage)
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: event['image'].toString().startsWith('http') || event['image'].toString().startsWith('https')
                // Imagem remota
                ? Image.network(
                    event['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                // Imagem local
                : Image.asset(
                    event['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
                  ),
            ),
          
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descrição
                Text(
                  event['description'] ?? "",
                  style: TextStyle(
                    fontSize: 16,
                    color: TColor.primaryText,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Data do evento
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: TColor.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: TColor.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}