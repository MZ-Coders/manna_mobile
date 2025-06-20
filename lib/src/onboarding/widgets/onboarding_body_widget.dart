import 'package:dribbble_challenge/src/onboarding/widgets/onboarding_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common_widget/language_selector.dart';
import 'package:dribbble_challenge/l10n/app_localizations.dart';

class OnBoardingBodyWidget extends StatefulWidget {
  const OnBoardingBodyWidget({super.key});

  @override
  State<OnBoardingBodyWidget> createState() => _OnBoardingBodyWidgetState();
}

class _OnBoardingBodyWidgetState extends State<OnBoardingBodyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showAppSelector = false;
  String _selectedApp = 'food_delivery'; // Valor padrão

  String _restaurantName = '';
  String _restaurantAddress = '';
  String _restaurantCity = '';
  String _restaurantLogo = '';
  
  // Adicionar flag para controlar se os dados já foram carregados
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    print("OnBoarding initState");
    _loadPreference();
    print("Fim initState");
  }

  Future<void> _loadPreference() async {
    print("Iniciando _loadPreference");
    try {
      final prefs = await SharedPreferences.getInstance();
      print("SharedPreferences obtido");
      
      // Sempre carregar os dados mais recentes do SharedPreferences
      final newSelectedApp = prefs.getString('app_type') ?? 'food_delivery';
      final newRestaurantName = prefs.getString('restaurant_name') ?? '';
      final newRestaurantAddress = prefs.getString('restaurant_address') ?? '';
      final newRestaurantCity = prefs.getString('restaurant_city') ?? '';
      final newRestaurantLogo = prefs.getString('restaurant_logo') ?? '';
      
      print("Dados carregados:");
      print("- App Type: $newSelectedApp");
      print("- Restaurant Name: $newRestaurantName");
      print("- Restaurant Address: $newRestaurantAddress");
      print("- Restaurant City: $newRestaurantCity");
      print("- Restaurant Logo: $newRestaurantLogo");
      
      // Apenas atualizar o estado se os dados realmente mudaram ou se é a primeira carga
      if (!_dataLoaded || 
          _selectedApp != newSelectedApp ||
          _restaurantName != newRestaurantName ||
          _restaurantAddress != newRestaurantAddress ||
          _restaurantCity != newRestaurantCity ||
          _restaurantLogo != newRestaurantLogo) {
        
        setState(() {
          _selectedApp = newSelectedApp;
          _restaurantName = newRestaurantName;
          _restaurantAddress = newRestaurantAddress;
          _restaurantCity = newRestaurantCity;
          _restaurantLogo = newRestaurantLogo;
          _dataLoaded = true;
        });
        
        print("Estado atualizado com novos dados");
      } else {
        print("Dados não mudaram, mantendo estado atual");
      }
    } catch (e) {
      print("Erro ao carregar preferências: $e");
      setState(() {
        _dataLoaded = true; // Marcar como carregado mesmo com erro
      });
    }
  }

  Future<void> _savePreference(String appType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_type', appType);
      print("Preferência salva: $appType");
    } catch (e) {
      print("Erro ao salvar preferência: $e");
    }
  }

  // Método para recarregar dados quando necessário
  Future<void> _refreshData() async {
    print("Recarregando dados...");
    await _loadPreference();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _proceedToApp() {
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(400.ms, () {
          Navigator.of(context).pushNamed('home');
        });
      }
    });
  }

  void _toggleAppSelector() {
    setState(() {
      _showAppSelector = !_showAppSelector;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainPlayDuration = 1000.ms;
    final leavesDelayDuration = 600.ms;
    final titleDelayDuration = mainPlayDuration + 50.ms;
    final descriptionDelayDuration = titleDelayDuration + 300.ms;
    final buttonDelayDuration = descriptionDelayDuration + 100.ms;
    final buttonPlayDuration = mainPlayDuration - 200.ms;
    
    // Exibir loading enquanto os dados não foram carregados
    if (!_dataLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: Stack(
        children: [

          Column(
            
            children: [
              const Flexible(
                child: SizedBox(
                  height: 50,
                ),
              ),
              Flexible(
                flex: 6,
                child: AnimatedDishWidget(
                  dishPlayDuration: mainPlayDuration,
                  leavesDelayDuration: leavesDelayDuration,
                  restaurantLogo: _restaurantLogo,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    if (_restaurantLogo.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      // Placeholder para logo se necessário
                    ),
                    AnimatedTitleWidget(
                        titleDelayDuration: titleDelayDuration,
                        mainPlayDuration: mainPlayDuration,
                        restaurantName: _restaurantName),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Flexible(
                flex: 1,
                child: AnimatedDescriptionWidget(
                  descriptionPlayDuration: mainPlayDuration,
                  descriptionDelayDuration: descriptionDelayDuration,
                  restaurantAddress: _restaurantAddress,
                  restaurantCity: _restaurantCity,
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Seletor de idioma
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon(
                        //   Icons.language,
                        //   size: 20,
                        //   color: Colors.grey.shade600,
                        // ),
                        // const SizedBox(width: 8),
                        LanguageSelector(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                    // Botão principal
                    GestureDetector(
                      onTap: _proceedToApp,
                      child: AnimatedButtonWidget(
                          buttonDelayDuration: buttonDelayDuration,
                          buttonPlayDuration: buttonPlayDuration),
                    ),
                    
                    // Botão para recarregar dados (útil para debug)
                    const SizedBox(height: 10),
                    if (_restaurantName.isEmpty) // Mostrar apenas se não há dados do restaurante
                      TextButton(
                        onPressed: _refreshData,
                        child: Text(
                          AppLocalizations.of(context).reloadData,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    
                    // Botão para mostrar o seletor de apps (comentado conforme original)
                    // const SizedBox(height: 20),
                    // InkWell(
                    //   onTap: _toggleAppSelector,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(20),
                    //       border: Border.all(color: Colors.grey.shade300),
                    //     ),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Text(
                    //           AppLocalizations.of(context).chooseApp,
                    //           style: TextStyle(
                    //             color: Colors.grey.shade700,
                    //             fontSize: 12,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 5),
                    //         Icon(
                    //           _showAppSelector ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    //           size: 16,
                    //           color: Colors.grey.shade700,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          )
              .animate(
                autoPlay: false,
                controller: _controller,
              )
              .blurXY(begin: 0, end: 25, duration: 600.ms, curve: Curves.easeInOut)
              .scaleXY(begin: 1, end: 0.6)
              .fadeOut(
                begin: 1,
              ),
              
          // Painel de seleção de app que aparece quando _showAppSelector é true
          if (_showAppSelector)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context).selectApp,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Opção POS App
                      _buildAppOption(
                        title: AppLocalizations.of(context).posApp,
                        subtitle: AppLocalizations.of(context).posDescription,
                        icon: Icons.point_of_sale,
                        value: 'pos',
                      ),
                      
                      const Divider(height: 20),
                      
                      // Opção Food Delivery App
                      _buildAppOption(
                        title: AppLocalizations.of(context).restaurant,
                        subtitle: AppLocalizations.of(context).restaurantAppDescription,
                        icon: Icons.restaurant,
                        value: 'food_delivery',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Botão para confirmar a seleção
                      ElevatedButton(
                        onPressed: () async {
                          await _savePreference(_selectedApp);
                          setState(() {
                            _showAppSelector = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context).confirm),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedApp == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedApp = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.orange, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.orange : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.orange,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}