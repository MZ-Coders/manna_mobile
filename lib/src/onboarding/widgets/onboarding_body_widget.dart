import 'package:dribbble_challenge/src/onboarding/widgets/onboarding_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    // Verifica se já existe uma preferência salva
    _loadPreference();
    super.initState();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedApp = prefs.getString('app_type') ?? 'food_delivery';

      _restaurantName = prefs.getString('restaurant_name') ?? '';
      _restaurantAddress = prefs.getString('restaurant_address') ?? '';
      _restaurantCity = prefs.getString('restaurant_city') ?? '';
      _restaurantLogo = prefs.getString('restaurant_logo') ?? '';
    });
  }

  Future<void> _savePreference(String appType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_type', appType);
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
    
    return Stack(
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
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Flexible(
              flex: 2,
              child: AnimatedTitleWidget(
                  titleDelayDuration: titleDelayDuration,
                  mainPlayDuration: mainPlayDuration,
                  restaurantName: _restaurantName),
            ),
            const SizedBox(
              height: 20,
            ),
            Flexible(
              flex: 1,
              child: AnimatedDescriptionWidget(
                descriptionPlayDuration: mainPlayDuration,
                descriptionDelayDuration: descriptionDelayDuration,
                restaurantAddress: _restaurantAddress, // ADICIONAR ESTA LINHA
                restaurantCity: _restaurantCity,
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão principal
                  GestureDetector(
                    onTap: _proceedToApp,
                    child: AnimatedButtonWidget(
                        buttonDelayDuration: buttonDelayDuration,
                        buttonPlayDuration: buttonPlayDuration),
                  ),
                  
                  // Botão para mostrar o seletor de apps
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _toggleAppSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Escolher aplicativo",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            _showAppSelector ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    const Text(
                      "Selecione o aplicativo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Opção POS App
                    _buildAppOption(
                      title: "POS App",
                      subtitle: "Sistema de ponto de venda",
                      icon: Icons.point_of_sale,
                      value: 'pos',
                    ),
                    
                    const Divider(height: 20),
                    
                    // Opção Food Delivery App
                    _buildAppOption(
                      title: "Restaurante",
                      subtitle: "Aplicativo de pedido no restaurante",
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
                      child: const Text("Confirmar"),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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