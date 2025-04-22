import 'package:dribbble_challenge/src/common_widget/tab_button.dart';
import 'package:dribbble_challenge/src/view/more/my_order_view.dart';
import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_view.dart';
import '../menu/menu_view.dart';
import '../more/more_view.dart';
import '../offer/offer_view.dart';
import '../profile/profile_view.dart';

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

  @override
  void initState() {
    super.initState();
    loadTableId();
  }

  Future<void> loadTableId() async {
    final id = await getTableId();
    setState(() {
      tableId = id;
    });
    print('Table ID: $tableId'); // Aqui o valor real será exibido
  }


  @override
  Widget build(BuildContext context) {
    print('Table ID: $tableId'); // Aqui o valor real será exibido}');
    return Scaffold(
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
                  title: "Offer",
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
        
              // TabButton(
              //     title: "Profile",
              //     icon: "assets/img/tab_profile.png",
              //     onTap: () {
              //       if (selctTab != 3) {
              //         selctTab = 3;
              //         selectPageView = const ProfileView();
              //       }
              //       if (mounted) {
              //         setState(() {});
              //       }
              //     },
              //     isSelected: selctTab == 3),
              TabButton(
                  title: "My Orders",
                  icon: "assets/img/shopping_cart.png",
                  onTap: () {
                    if (selctTab != 4) {
                      selctTab = 4;
                      selectPageView = const  MyOrderView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 4),
            ],
          ),
        ),
      ),
    );
  }
}
