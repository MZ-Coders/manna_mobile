import 'dart:math' as math;
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
  // Widget para construir a lista de eventos como carrossel overlapped
  Widget buildEventsList(BuildContext context, List eventsList) {
    PageController pageController = PageController(
      viewportFraction: 0.75, // Reduzido de 0.85 para mostrar mais dos cards laterais
      initialPage: 0,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Próximos Eventos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColor.primaryText,
                ),
              ),
              if (eventsList.length > 2)
                Text(
                  "Ver todos",
                  style: TextStyle(
                    fontSize: 14,
                    color: TColor.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        
        // Carrossel horizontal overlapped
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: eventsList.length,
            itemBuilder: (context, index) {
              var event = eventsList[index] as Map? ?? {};
              return AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  double value = 1.0;
                  double distortionValue = 0.0;
                  
                  if (pageController.position.haveDimensions) {
                    value = pageController.page! - index;
                    
                    // Calcula a escala baseada na posição - mais conservadora
                    double scale = 1.0;
                    
                    if (value.abs() <= 1.0) {
                      // Card atual ou adjacente - redução mais sutil
                      scale = 1.0 - (value.abs() * 0.12); // Reduzido de 0.15 para 0.12
                    } else {
                      // Cards distantes - mantém mais visibilidade
                      scale = 0.88; // Aumentado de 0.85 para 0.88
                    }
                    
                    distortionValue = scale;
                  }
                  
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspectiva
                      ..rotateY(pageController.position.haveDimensions ? 
                        (pageController.page! - index) * 0.2 : 0) // Reduzido de 0.3 para 0.2
                      ..translate(pageController.position.haveDimensions ? 
                        (pageController.page! - index) * -40 : 0), // Reduzido de -60 para -40
                    child: Transform.scale(
                      scale: distortionValue.clamp(0.88, 1.0), // Aumentado range mínimo
                      child: Opacity(
                        opacity: (1.0 - (pageController.position.haveDimensions ? 
                          (pageController.page! - index).abs() * 0.2 : 0)).clamp(0.8, 1.0), // Aumentado de 0.7 para 0.8
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6), // Aumentado de 4 para 6
                          child: buildOverlappedEventCard(context, event, index),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        // Indicador de pontos melhorado
        if (eventsList.length > 1)
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                eventsList.length,
                (index) => AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    double selectedness = Curves.easeOut.transform(
                      math.max(
                        0.0,
                        1.0 - ((pageController.page ?? 0.0) - index).abs(),
                      ),
                    );
                    return Container(
                      width: selectedness > 0.5 ? 24.0 : 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: TColor.primary.withOpacity(0.3 + (selectedness * 0.7)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // Widget para construir um card de evento com efeito overlapped otimizado
  Widget buildOverlappedEventCard(BuildContext context, Map event, int index) {
    // Formatação da data do evento
    String formattedDate = "";
    String dayMonth = "";
    if (event['event_date'] != null) {
      try {
        DateTime eventDate = DateTime.parse(event['event_date']);
        formattedDate = "${eventDate.day}/${eventDate.month}/${eventDate.year}";
        dayMonth = "${eventDate.day}\n${_getMonthName(eventDate.month)}";
      } catch (e) {
        formattedDate = event['event_date'];
        dayMonth = "00\nJAN";
      }
    }
    
    // Gradientes mais dramáticos para o efeito overlapped
    List<List<Color>> gradientSets = [
      [Colors.deepPurple.shade400, Colors.deepPurple.shade700, Colors.black87],
      [Colors.indigo.shade400, Colors.indigo.shade700, Colors.black87],
      [Colors.teal.shade400, Colors.teal.shade700, Colors.black87],
      [Colors.orange.shade400, Colors.red.shade600, Colors.black87],
      [Colors.pink.shade400, Colors.purple.shade700, Colors.black87],
      [Colors.green.shade400, Colors.green.shade700, Colors.black87],
    ];
    
    List<Color> gradientColors = gradientSets[index % gradientSets.length];
    IconData typeIcon = Icons.event;
    
    if (event['type'] == 'PROMOTION') {
      gradientColors = [Colors.orange.shade400, Colors.red.shade600, Colors.black87];
      typeIcon = Icons.local_offer;
    } else if (event['type'] == 'ANNOUNCEMENT') {
      gradientColors = [Colors.green.shade400, Colors.green.shade700, Colors.black87];
      typeIcon = Icons.campaign;
    }
    
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          // Sombra principal mais intensa
          BoxShadow(
            color: gradientColors[1].withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          // Sombra secundária para profundidade
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Padrões decorativos mais elaborados
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Elementos decorativos com formas geométricas
          Positioned(
            top: 30,
            left: -20,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 40,
            right: -15,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
          ),
          
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com tipo e data mais elaborado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tipo do evento com design premium
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              typeIcon,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            event['type'] == 'PROMOTION' 
                                ? 'PROMOÇÃO'
                                : event['type'] == 'ANNOUNCEMENT'
                                    ? 'ANÚNCIO'
                                    : 'EVENTO',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Data em formato premium
                    Container(
                      width: 70,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.95),
                            Colors.white.withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayMonth.split('\n')[0],
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: gradientColors[1],
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 2,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: gradientColors[1].withOpacity(0.5),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          Text(
                            dayMonth.split('\n')[1],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: gradientColors[1].withOpacity(0.8),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Título do evento mais impactante
                Container(
                  child: Text(
                    event['name'] ?? "Evento",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Descrição estilizada
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      event['description'] ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Footer com data e call-to-action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Data formatada com design premium
                    if (formattedDate.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.schedule_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Botão de ação sutil
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 20,
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
  
  // Widget para construir um card de evento no formato horizontal/carrossel
  Widget buildEventCardHorizontal(BuildContext context, Map event) {
    // Formatação da data do evento
    String formattedDate = "";
    String dayMonth = "";
    if (event['event_date'] != null) {
      try {
        DateTime eventDate = DateTime.parse(event['event_date']);
        formattedDate = "${eventDate.day}/${eventDate.month}/${eventDate.year}";
        dayMonth = "${eventDate.day}\n${_getMonthName(eventDate.month)}";
      } catch (e) {
        formattedDate = event['event_date'];
        dayMonth = "00\nJAN";
      }
    }
    
    // Cor do tipo de evento
    Color typeColor = Colors.blue;
    Color gradientStart = Colors.blue.shade400;
    Color gradientEnd = Colors.blue.shade600;
    IconData typeIcon = Icons.event;
    
    if (event['type'] == 'PROMOTION') {
      typeColor = Colors.orange;
      gradientStart = Colors.orange.shade400;
      gradientEnd = Colors.orange.shade600;
      typeIcon = Icons.local_offer;
    } else if (event['type'] == 'ANNOUNCEMENT') {
      typeColor = Colors.green;
      gradientStart = Colors.green.shade400;
      gradientEnd = Colors.green.shade600;
      typeIcon = Icons.campaign;
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Padrão decorativo de fundo
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com tipo e data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tipo do evento
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            typeIcon,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event['type'] == 'PROMOTION' 
                                ? 'PROMOÇÃO'
                                : event['type'] == 'ANNOUNCEMENT'
                                    ? 'ANÚNCIO'
                                    : 'EVENTO',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Data em formato compacto
                    Container(
                      width: 50,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayMonth.split('\n')[0],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                          Text(
                            dayMonth.split('\n')[1],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Título do evento
                Text(
                  event['name'] ?? "Evento",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Descrição
                Expanded(
                  child: Text(
                    event['description'] ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Data formatada na parte inferior
                if (formattedDate.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
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
  
  // Widget para construir um card de evento
  // Widget para construir um card de evento (versão vertical - backup)
  Widget buildEventCardVertical(BuildContext context, Map event) {
    // Formatação da data do evento
    String formattedDate = "";
    String dayMonth = "";
    if (event['event_date'] != null) {
      try {
        DateTime eventDate = DateTime.parse(event['event_date']);
        formattedDate = "${eventDate.day}/${eventDate.month}/${eventDate.year} às ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}";
        dayMonth = "${eventDate.day}\n${_getMonthName(eventDate.month)}";
      } catch (e) {
        formattedDate = event['event_date'];
        dayMonth = "00\nJAN";
      }
    }
    
    // Cor do tipo de evento
    Color typeColor = Colors.blue;
    Color gradientStart = Colors.blue.shade400;
    Color gradientEnd = Colors.blue.shade600;
    IconData typeIcon = Icons.event;
    
    if (event['type'] == 'PROMOTION') {
      typeColor = Colors.orange;
      gradientStart = Colors.orange.shade400;
      gradientEnd = Colors.orange.shade600;
      typeIcon = Icons.local_offer;
    } else if (event['type'] == 'ANNOUNCEMENT') {
      typeColor = Colors.green;
      gradientStart = Colors.green.shade400;
      gradientEnd = Colors.green.shade600;
      typeIcon = Icons.campaign;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Card principal com gradient
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          
          // Padrão de fundo decorativo
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Conteúdo do card
          Container(
            height: 180,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Seção da data
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayMonth.split('\n')[0],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      Text(
                        dayMonth.split('\n')[1],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: typeColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Conteúdo principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tipo do evento
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              typeIcon,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event['type'] == 'PROMOTION' 
                                  ? 'PROMOÇÃO'
                                  : event['type'] == 'ANNOUNCEMENT'
                                      ? 'ANÚNCIO'
                                      : 'EVENTO',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Título do evento
                      Text(
                        event['name'] ?? "Evento",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Descrição
                      Text(
                        event['description'] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Data formatada
                      if (formattedDate.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
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
          
          // Padrão decorativo no canto superior direito
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Padrão decorativo no canto inferior esquerdo
          Positioned(
            bottom: -15,
            left: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper para obter nome do mês
  String _getMonthName(int month) {
    const months = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
                    'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
    return months[month - 1];
  }
}