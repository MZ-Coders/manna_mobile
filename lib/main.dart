import 'dart:io';

import 'package:dribbble_challenge/src/common/cart_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Imports do primeiro app (POS)
import 'package:dribbble_challenge/src/home_pos.dart';
import 'package:dribbble_challenge/src/core/theme/app_colors.dart';

// Imports do segundo app (Food Delivery)
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/common/globs.dart';
import 'package:dribbble_challenge/src/common/locator.dart';
import 'package:dribbble_challenge/src/common/my_http_overrides.dart';
import 'package:dribbble_challenge/src/common/service_call.dart';
import 'package:dribbble_challenge/src/onboarding/onboarding_screen.dart';
import 'package:dribbble_challenge/src/view/main_tabview/main_tabview.dart';
import 'package:dribbble_challenge/src/view/on_boarding/startup_view.dart';

// Definindo enum para os tipos de aplicativo
enum AppType { posApp, foodDeliveryApp }

// Variável global para preferências
SharedPreferences? prefs;

void main() async {
  // Inicialização comum aos dois apps
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializações específicas do Food Delivery app
  setUpLocator();
  HttpOverrides.global = MyHttpOverrides();
  
  // Obter TableID para o Food Delivery app
  // final tableId = getTableIdFromUrl();
  final restaurantId = getUrlParameter("restaurant");
  final tableId = getUrlParameter("table");
  prefs = await SharedPreferences.getInstance();
  
  // if (tableId != null) {
  //   prefs!.setString('table_id', tableId);
  // }

  

  if (restaurantId != null) {
    prefs!.setString('restaurant_id', restaurantId);
    print("Restaurant ID: $restaurantId");

    await loadBasicRestaurantData(restaurantId);
  } else {
    prefs!.setString('restaurant_id', '');
  }

  if (tableId != null) {
    prefs!.setString('table_id', tableId);
    print("Table ID: $tableId");
  } else {
    prefs!.setString('table_id', '');
  }
  if (Globs.udValueBool(Globs.userLogin)) {
    ServiceCall.userPayload = Globs.udValue(Globs.userPayload);
  }
  
  // Configuração do EasyLoading
  configLoading();
  
  // Sempre iniciar com a tela de onboarding para seleção de app
  runApp(const AppSelector());
}

String? getTableIdFromUrl() {
  if (kIsWeb) {
    // Para testes, usando uma URL fixa
    final url = "https://example.com?table_id=12345";
    final uri = Uri.parse(url);
    return uri.queryParameters['table_id'];
  } else {
    return null;
  }
}

String? getUrlParameter(String key) {
  if (kIsWeb) {
    final uri = Uri.base; // Pega a URL real em execução
    return uri.queryParameters[key];
  }
  return null;
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 5.0
    ..progressColor = TColor.primaryText
    ..backgroundColor = TColor.primary
    ..indicatorColor = Colors.yellow
    ..textColor = TColor.primaryText
    ..userInteractions = false
    ..dismissOnTap = false;
}

Future<void> loadBasicRestaurantData(String restaurantUUID) async {
  try {
    ServiceCall.getMenuItems(restaurantUUID,
        withSuccess: (Map<String, dynamic> data) {
          if (data.containsKey('restaurant') && data['restaurant'] != null) {
            var restaurant = data['restaurant'];
            // Salvar dados básicos do restaurante
            prefs!.setString('restaurant_name', restaurant['name'] ?? '');
            prefs!.setString('restaurant_logo', restaurant['logo'] ?? '');
            prefs!.setString('restaurant_address', restaurant['address'] ?? '');
            prefs!.setString('restaurant_city', restaurant['city'] ?? '');
            print("Dados do restaurante carregados: ${restaurant['name']}");
          }
        },
        failure: (String error) {
          print("Erro ao buscar dados do restaurante: $error");
        });
  } catch (e) {
    print("Error loading restaurant data: $e");
  }
}

// App Selector que sempre inicia com a tela de Onboarding
class AppSelector extends StatefulWidget {
  const AppSelector({Key? key}) : super(key: key);

  @override
  State<AppSelector> createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || 
        state == AppLifecycleState.paused) {
      // Limpar todos os dados quando app é fechado/minimizado
      clearAllData();
    }
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    CartService.clearCart();
    print("Todos os dados foram limpos!");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Selector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const OnBoardingScreen(), // Inicia sempre com a tela de onboarding
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: (routeSettings) {
        // Verificar qual app foi selecionado quando a navegação ocorrer
        switch (routeSettings.name) {
          case "home":
            // Verifica o tipo de app selecionado
            final appType = prefs?.getString('app_type') ?? 'food_delivery';
            
            if (appType == 'pos') {
              return MaterialPageRoute(builder: (context) => const POSAppRouter());
            } else {
              return MaterialPageRoute(builder: (context) => const MainTabView());
            }
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text("No path for ${routeSettings.name}"),
                ),
              ),
            );
        }
      },
      builder: (context, child) {
        return FlutterEasyLoading(child: child);
      },
    );
  }
}

// Router para o app POS
class POSAppRouter extends StatelessWidget {
  const POSAppRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aqui podemos definir qualquer configuração específica do POS antes de navegar
    // para a página principal do POS
    return const MainPage();
  }
}

// App POS do primeiro arquivo main.dart
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String pageActive = 'Home';

  _pageView() {
    switch (pageActive) {
      case 'Home':
        return const HomePosPage();
      case 'Menu':
        return Container();
      case 'History':
        return Container();
      case 'Promos':
        return Container();
      case 'Settings':
        return Container();
      default:
        return const HomePosPage();
    }
  }

  _setPage(String page) {
    setState(() {
      pageActive = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.only(top: 24, right: 12, left: 12),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
            child: _sideMenu(),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 24, right: 12),
              padding: const EdgeInsets.only(top: 12, right: 12, left: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                color: Colors.white,
              ),
              child: _pageView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideMenu() {
    return Column(children: [
      _logo(),
      const SizedBox(height: 20),
      Expanded(
        child: ListView(
          children: [
            _itemMenu(
              menu: 'Home',
              icon: Icons.rocket_sharp,
            ),
            _itemMenu(
              menu: 'Menu',
              icon: Icons.format_list_bulleted_rounded,
            ),
            _itemMenu(
              menu: 'History',
              icon: Icons.history_toggle_off_rounded,
            ),
            _itemMenu(
              menu: 'Promos',
              icon: Icons.discount_outlined,
            ),
            _itemMenu(
              menu: 'Settings',
              icon: Icons.sports_soccer_outlined,
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _logo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary,
          ),
          child: const Icon(
            Icons.fastfood,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Manna POS',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _itemMenu({required String menu, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: GestureDetector(
        onTap: () => _setPage(menu),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: pageActive == menu
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.slowMiddle,
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: pageActive == menu 
                        ? Colors.white 
                        : AppColors.secondaryText,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    menu,
                    style: TextStyle(
                      color: pageActive == menu 
                          ? Colors.white 
                          : AppColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

// Classe auxiliar para facilitar a troca entre aplicativos
class AppSwitcherHelper {
  static Future<void> switchToApp(AppType appType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Salvar a preferência
    if (appType == AppType.posApp) {
      await prefs.setString('app_type', 'pos');
    } else {
      await prefs.setString('app_type', 'food_delivery');
    }
  }
}