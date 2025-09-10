import 'dart:async';

import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common/order_count_notifier.dart';
import 'package:dribbble_challenge/src/common/order_tracking_service.dart';
import 'package:dribbble_challenge/src/common_widget/tab_button.dart';
import 'package:dribbble_challenge/src/common_widget/tab_button_with_badge.dart';
import 'package:dribbble_challenge/src/view/more/my_order_view.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_view.dart';
import '../offer/offer_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
  
}

Future<String?> getTableId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('table_id');
}

class _MainTabViewState extends State<MainTabView> {
  int selctTab = 2;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const HomeView();
  String? tableId;
  String restaurantId = '';
  int activeOrdersCount = 0;
  bool hasActiveOrders = false;
  Timer? _orderCheckTimer;
  StreamSubscription? _orderCountSubscription;

  @override
  void initState() {
    super.initState();
    loadTableId();
    loadRestaurantData();
    
    // Configurar timer para verificar pedidos pendentes a cada 10 segundos
    _orderCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        checkActiveOrders();
      }
    });
    
    // Ouvir notificações de mudanças na contagem de pedidos
    _orderCountSubscription = OrderCountNotifier().stream.listen((_) {
      if (mounted) {
        print("Notificação recebida: Atualizando contagem de pedidos na TabBar");
        checkActiveOrders();
      }
    });
  }
  
  @override
  void dispose() {
    _orderCheckTimer?.cancel();
    _orderCountSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadTableId() async {
    final id = await getTableId();
    setState(() {
      tableId = id;
    });
    print('Table ID: $tableId'); // Aqui o valor real será exibido
  }
  
  Future<void> loadRestaurantData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      restaurantId = prefs.getString('restaurant_id') ?? '';
    });
    
    await checkActiveOrders();
  }
  
  Future<void> checkActiveOrders() async {
    if (restaurantId.isEmpty) return;
    
    try {
      // Buscar pedidos do restaurante atual
      List<Map<String, dynamic>> restaurantOrders = 
        await OrderTrackingService.getOrdersByRestaurant(restaurantId);
      
      // Contar pedidos ativos (pendentes, em processamento ou prontos)
      List<String> activeStatusList = ['PENDING', 'PROCESSING', 'READY'];
      int count = restaurantOrders.where((order) => 
        activeStatusList.contains(order['status'] ?? '')).length;
      
      setState(() {
        hasActiveOrders = count > 0;
        activeOrdersCount = count;
      });
      
      print("Verificação de pedidos na TabBar: $count pedidos ativos encontrados");
    } catch (e) {
      print("Erro ao verificar pedidos ativos na TabBar: $e");
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Verificar pedidos ativos quando o widget está totalmente construído ou quando volta ao foco
    if (mounted) {
      checkActiveOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Table ID: $tableId');
    return WillPopScope(
      onWillPop: () async {
        // Se estiver na Home (aba central), impedir voltar
        if (selctTab == 2) {
          // Mostrar diálogo de confirmação para ir para onboarding
          final shouldGoToOnboarding = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Deseja sair?'),
              content: const Text('Você será redirecionado para a tela inicial (onboarding). Deseja continuar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Ir para onboarding'),
                ),
              ],
            ),
          );
          if (shouldGoToOnboarding == true) {
            // Navegar para onboarding removendo todas as rotas anteriores
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            return false;
          }
          return false;
        }
        // Se não estiver na Home, voltar para Home
        setState(() {
          selctTab = 2;
          selectPageView = const HomeView();
        });
        return false;
      },
      child: Scaffold(
        body: PageStorage(bucket: storageBucket, child: selectPageView),
        backgroundColor: const Color(0xfff5f5f5),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: () {
              if (selctTab != 2) {
                selctTab = 2;
                selectPageView = const HomeView();
              }
              if (mounted) {
                setState(() {});
              }
            },
            shape: const CircleBorder(),
            backgroundColor: selctTab == 2 ? TColor.primary : TColor.placeholder,
            child: Image.asset(
              "assets/img/tab_home.png",
              width: 30,
              height: 30,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          surfaceTintColor: TColor.white,
          shadowColor: Colors.black,
          elevation: 1,
          notchMargin: 12,
          height: 64,
          shape: const CircularNotchedRectangle(),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // TabButton(
                //     title: "Menu",
                //     icon: "assets/img/tab_menu.png",
                //     onTap: () {
                //       if (selctTab != 0) {
                //         selctTab = 0;
                //         selectPageView = const MenuView();
                //       }
                //       if (mounted) {
                //         setState(() {});
                //       }
                //     },
                //     isSelected: selctTab == 0),
                TabButton(
                    title: AppLocalizations.of(context).offers,
                    icon: "assets/img/tab_offer.png",
                    onTap: () {
                      if (selctTab != 1) {
                        selctTab = 1;
                        selectPageView = const OfferView();
                      }
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    isSelected: selctTab == 1),
              const  SizedBox(width: 40, height: 40, ),
                TabButtonWithBadge(
                    title: AppLocalizations.of(context).myOrders,
                    icon: "assets/img/shopping_cart.png",
                    onTap: () {
                      if (selctTab != 4) {
                        selctTab = 4;
                        selectPageView = const MyOrderView();
                        checkActiveOrders();
                      }
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    isSelected: selctTab == 4,
                    badgeCount: activeOrdersCount,
                    showBadge: hasActiveOrders && activeOrdersCount > 0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
