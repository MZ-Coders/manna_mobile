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

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/l10n/language_service.dart';
import 'package:provider/provider.dart';

import 'dart:async';

// Definindo enum para os tipos de aplicativo
enum AppType { posApp, foodDeliveryApp }

// Variável global para preferências
SharedPreferences? prefs;

void main() async {
  // Inicialização comum aos dois apps
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar serviço de idioma
  final languageService = LanguageService();
  await languageService.loadSavedLanguage();
  
  // Inicializações específicas do Food Delivery app
  setUpLocator();
  HttpOverrides.global = MyHttpOverrides();
  
  // Configuração do EasyLoading primeiro
  configLoading();
  
  // Obter parâmetros da URL
  final restaurantId = getUrlParameter("restaurant");
  final tableId = getUrlParameter("table");
  prefs = await SharedPreferences.getInstance();
  await prefs!.clear();
  print("Dados antigos limpos do SharedPreferences");
  
  // Verificar se restaurantID existe
  if (restaurantId == null || restaurantId.isEmpty) {
    print("ERRO: Restaurant ID não encontrado na URL");
    runApp(const ErrorApp(
      errorType: ErrorType.missingRestaurantId,
      errorMessage: "ID do restaurante não encontrado na URL",
    ));
    return;
  }
  
  // Salvar IDs básicos primeiro
  prefs!.setString('restaurant_id', restaurantId);
  print("Restaurant ID: $restaurantId");

  if (tableId != null) {
    prefs!.setString('table_id', tableId);
    print("Table ID: $tableId");
  } else {
    prefs!.setString('table_id', '');
  }

  // Mostrar loading durante o carregamento
  runApp(const LoadingApp());
  
  // Aguardar carregamento dos dados do restaurante
  print("Carregando dados do restaurante...");
  final loadingSuccess = await loadBasicRestaurantDataSync(restaurantId);
  
  if (!loadingSuccess) {
    print("ERRO: Falha ao carregar dados do restaurante");
    runApp(const ErrorApp(
      errorType: ErrorType.loadingError,
      errorMessage: "Não foi possível carregar os dados do restaurante",
    ));
    return;
  }
  
  print("Dados do restaurante carregados com sucesso");

  if (Globs.udValueBool(Globs.userLogin)) {
    ServiceCall.userPayload = Globs.udValue(Globs.userPayload);
  }
  
  print("Processo inicial completo");
  
  // Iniciar o app principal após o carregamento bem-sucedido
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: languageService),
    ],
    child: const AppSelector(),
  ));
  print("Iniciou AppSelector");
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

// Versão síncrona da função que aguarda o carregamento completo
// Retorna true se carregou com sucesso, false se houve erro
Future<bool> loadBasicRestaurantDataSync(String restaurantUUID) async {
  try {
    // Usar um Completer para aguardar a resposta da API
    final completer = Completer<bool>();
    
    ServiceCall.getMenuItems(restaurantUUID,
        withSuccess: (Map<String, dynamic> data) {
          if (data.containsKey('restaurant') && data['restaurant'] != null) {
            var restaurant = data['restaurant'];
            // Salvar dados básicos do restaurante
            prefs!.setString('restaurant_name', restaurant['name'] ?? '');
            prefs!.setString('restaurant_logo', restaurant['logo'] ?? '');
            prefs!.setString('restaurant_address', restaurant['address'] ?? '');
            prefs!.setString('restaurant_city', restaurant['city'] ?? '');
            print("Dados do restaurante salvos: ${restaurant['name']}");
            completer.complete(true); // Sucesso
          } else {
            print("Erro: Dados do restaurante não encontrados na resposta");
            completer.complete(false); // Falha
          }
        },
        failure: (String error) {
          print("Erro ao buscar dados do restaurante: $error");
          completer.complete(false); // Falha
        });
    
    // Aguarda a conclusão da chamada API
    return await completer.future;
  } catch (e) {
    print("Error loading restaurant data: $e");
    return false; // Falha
  }
}

// Enum para tipos de erro
enum ErrorType {
  missingRestaurantId,
  loadingError,
}

// App de Erro que é mostrado quando há problemas
class ErrorApp extends StatelessWidget {
  final ErrorType errorType;
  final String errorMessage;

  const ErrorApp({
    Key? key,
    required this.errorType,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: ErrorScreen(
        errorType: errorType,
        errorMessage: errorMessage,
      ),
    );
  }
}

// Tela de Erro personalizada
class ErrorScreen extends StatelessWidget {
  final ErrorType errorType;
  final String errorMessage;

  const ErrorScreen({
    Key? key,
    required this.errorType,
    required this.errorMessage,
  }) : super(key: key);

  String _getErrorTitle() {
    switch (errorType) {
      case ErrorType.missingRestaurantId:
        return 'Restaurante Não Encontrado';
      case ErrorType.loadingError:
        return 'Erro de Conexão';
    }
  }

  String _getErrorDescription() {
    switch (errorType) {
      case ErrorType.missingRestaurantId:
        return 'Esta URL não contém as informações necessárias do restaurante. Verifique se você está acessando o link correto fornecido pelo restaurante.';
      case ErrorType.loadingError:
        return 'Não conseguimos carregar as informações do restaurante. Verifique sua conexão com a internet e tente novamente.';
    }
  }

  IconData _getErrorIcon() {
    switch (errorType) {
      case ErrorType.missingRestaurantId:
        return Icons.link_off;
      case ErrorType.loadingError:
        return Icons.wifi_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de erro
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: Colors.red.shade200,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getErrorIcon(),
                  color: Colors.red.shade400,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Título do erro
              Text(
                _getErrorTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 15),
              
              // Descrição do erro
              Text(
                _getErrorDescription(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 30),
              
              // Botão de tentar novamente (apenas para erro de loading)
              if (errorType == ErrorType.loadingError) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    // Recarregar a página
                    if (kIsWeb) {
                      // Para web, recarregar a página
                      // window.location.reload(); // Descomente se necessário
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Informações de contato/suporte
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.support_agent,
                      color: Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Precisa de ajuda?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorType == ErrorType.missingRestaurantId
                          ? 'Entre em contato com o restaurante para obter o link correto'
                          : 'Entre em contato com o suporte técnico se o problema persistir',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// App de Loading que é mostrado durante o carregamento inicial
class LoadingApp extends StatelessWidget {
  const LoadingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carregando...',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoadingScreen(),
    );
  }
}

// Tela de Loading personalizada
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Ícone animado
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Texto de carregamento
            const Text(
              'Carregando dados do restaurante...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 10),
            
            const Text(
              'Por favor, aguarde um momento',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 30),
            
            // Barra de progresso personalizada
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_rotationController.value * 0.8) + 0.2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Manter a função original para uso em outros locais se necessário
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
    _updateTitle();
  }

  void _updateTitle() {
  // Força a atualização do título quando os dados do restaurante estão disponíveis
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      setState(() {
        // Força rebuild para atualizar o título
      });
    }
  });
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

  String _buildAppTitle() {
  String restaurantName = prefs?.getString('restaurant_name') ?? '';
  
  if (restaurantName.isNotEmpty) {
    return 'Manna Software - $restaurantName';
  } else {
    return 'Manna Software';
  }
}

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
    builder: (context, languageService, child) {
    return MaterialApp(
      title: _buildAppTitle(),
      debugShowCheckedModeBanner: false,
       locale: languageService.currentLocale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
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
  },
    );}
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