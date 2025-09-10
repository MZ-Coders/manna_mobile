import 'dart:io';

import 'package:dribbble_challenge/src/common/cart_service.dart';
import 'package:dribbble_challenge/src/common/menu_data_service.dart';
import 'package:dribbble_challenge/src/common/api_config.dart';
import 'package:dribbble_challenge/src/view/login/login_view.dart';
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
import 'package:dribbble_challenge/src/view/restaurant_setup/restaurant_setup_view.dart';

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
  
  // Inicializar configuração da API (importante para mobile)
  await ApiConfig.initialize();
  
  // Inicializações específicas do Food Delivery app
  setUpLocator();
  HttpOverrides.global = MyHttpOverrides();
  
  // Configuração do EasyLoading primeiro
  configLoading();
  
  prefs = await SharedPreferences.getInstance();
  
  // NOVA LÓGICA: Verificar se é mobile e se a configuração foi feita
  if (!kIsWeb) {
    // Em mobile, verificar se o restaurante já foi configurado
    bool setupCompleted = prefs!.getBool('restaurant_setup_completed') ?? false;
    
    if (!setupCompleted) {
      // Primeira execução no mobile - mostrar tela de configuração
      runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: languageService),
        ],
        child: const MaterialApp(
          home: RestaurantSetupView(),
          debugShowCheckedModeBanner: false,
        ),
      ));
      return;
    }
    
    // Se já foi configurado, pegar os dados salvos
    final savedRestaurantId = prefs!.getString('restaurant_id');
    final savedTableId = prefs!.getString('table_id');
    
    if (savedRestaurantId == null || savedRestaurantId.isEmpty) {
      // Dados corrompidos, voltar para configuração
      await prefs!.setBool('restaurant_setup_completed', false);
      runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: languageService),
        ],
        child: const MaterialApp(
          home: RestaurantSetupView(),
          debugShowCheckedModeBanner: false,
        ),
      ));
      return;
    }
    
    print("Mobile - Restaurante já configurado: $savedRestaurantId");
    if (savedTableId != null && savedTableId.isNotEmpty) {
      print("Mobile - Mesa configurada: $savedTableId");
    }
    
    // Prosseguir com o carregamento dos dados
    _initializeAppWithRestaurant(savedRestaurantId, languageService);
    return;
  }
  
  // LÓGICA WEB ORIGINAL
  // Obter parâmetros da URL (apenas web)
  final restaurantId = getUrlParameter("restaurant");
  final tableId = getUrlParameter("table");
  
  // Preservar pedidos anteriores antes de limpar
  String? preservedOrders = prefs!.getString('user_orders');
  await prefs!.clear();
  if (preservedOrders != null) {
    await prefs!.setString('user_orders', preservedOrders);
    print("Dados antigos limpos (pedidos preservados)");
  } else {
    print("Dados antigos limpos (nenhum pedido para preservar)");
  }
  
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

  // Prosseguir com carregamento
  _initializeAppWithRestaurant(restaurantId, languageService);
}

// Nova função para inicializar app com dados do restaurante
Future<void> _initializeAppWithRestaurant(String restaurantId, LanguageService languageService) async {
  // Mostrar loading durante o carregamento
  runApp(const LoadingApp());
  
  // Aguardar carregamento dos dados do restaurante e menu
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
  
  // Inicializar o serviço de dados do menu em segundo plano
  // Isso carrega o menu completo uma única vez
  MenuDataService().initialize().then((success) {
    if (success) {
      print("Dados do menu carregados com sucesso");
    } else {
      print("Aviso: Falha ao carregar dados do menu, será tentado novamente mais tarde");
    }
  });
  
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
      title: 'Error - Manna Software',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: AppLocalizations.supportedLocales,
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

  String _getErrorTitle(BuildContext context) {
    switch (errorType) {
      case ErrorType.missingRestaurantId:
        return AppLocalizations.of(context).restaurantNotFound;
      case ErrorType.loadingError:
        return 'Erro de Conexão';
    }
  }

  String _getErrorDescription(BuildContext context) {
  switch (errorType) {
    case ErrorType.missingRestaurantId:
      return AppLocalizations.of(context).missingRestaurantMessage;
    case ErrorType.loadingError:
      return AppLocalizations.of(context).loadingRestaurantError;
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
                _getErrorTitle(context),
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
                _getErrorDescription(context),
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
                  label: Text(AppLocalizations.of(context).tryAgain),
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
                    Text(
                     AppLocalizations.of(context).needHelp,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorType == ErrorType.missingRestaurantId
                          ? AppLocalizations.of(context).contactRestaurantMessage
                          : AppLocalizations.of(context).contactSupportMessage,
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
      title: 'Manna Software - Loading',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
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
            Text(
              AppLocalizations.of(context).loadingRestaurantData,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 10),
            
            Text(
              AppLocalizations.of(context).pleaseWait,
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
    
    // Preservar dados essenciais durante operações de impressão
    String? preservedOrders = prefs.getString('user_orders');
    String? preservedRestaurantId = prefs.getString('restaurant_id');
    String? preservedTableId = prefs.getString('table_id');
    bool? preservedSetupCompleted = prefs.getBool('restaurant_setup_completed');
    String? preservedRestaurantName = prefs.getString('restaurant_name');
    String? preservedRestaurantLogo = prefs.getString('restaurant_logo');
    String? preservedRestaurantAddress = prefs.getString('restaurant_address');
    String? preservedRestaurantCity = prefs.getString('restaurant_city');
    String? preservedUserPayload = prefs.getString('user_payload');
    bool? preservedUserLogin = prefs.getBool('user_login');
    String? preservedAuthToken = prefs.getString('auth_token');
    String? preservedUserId = prefs.getString('user_id');
    String? preservedUserName = prefs.getString('user_name');
    String? preservedUserEmail = prefs.getString('user_email');
    String? preservedUserRole = prefs.getString('user_role');
    String? preservedTenantId = prefs.getString('tenant_id');
    String? preservedUserRestaurantId = prefs.getString('user_restaurant_id');
    String? preservedUserRestaurantUuid = prefs.getString('user_restaurant_uuid');
    
    await prefs.clear();
    
    // Restaurar dados essenciais
    if (preservedOrders != null) {
      await prefs.setString('user_orders', preservedOrders);
    }
    if (preservedRestaurantId != null) {
      await prefs.setString('restaurant_id', preservedRestaurantId);
    }
    if (preservedTableId != null) {
      await prefs.setString('table_id', preservedTableId);
    }
    if (preservedSetupCompleted != null) {
      await prefs.setBool('restaurant_setup_completed', preservedSetupCompleted);
    }
    if (preservedRestaurantName != null) {
      await prefs.setString('restaurant_name', preservedRestaurantName);
    }
    if (preservedRestaurantLogo != null) {
      await prefs.setString('restaurant_logo', preservedRestaurantLogo);
    }
    if (preservedRestaurantAddress != null) {
      await prefs.setString('restaurant_address', preservedRestaurantAddress);
    }
    if (preservedRestaurantCity != null) {
      await prefs.setString('restaurant_city', preservedRestaurantCity);
    }
    if (preservedUserPayload != null) {
      await prefs.setString('user_payload', preservedUserPayload);
    }
    if (preservedUserLogin != null) {
      await prefs.setBool('user_login', preservedUserLogin);
    }
    if (preservedAuthToken != null) {
      await prefs.setString('auth_token', preservedAuthToken);
    }
    if (preservedUserId != null) {
      await prefs.setString('user_id', preservedUserId);
    }
    if (preservedUserName != null) {
      await prefs.setString('user_name', preservedUserName);
    }
    if (preservedUserEmail != null) {
      await prefs.setString('user_email', preservedUserEmail);
    }
    if (preservedUserRole != null) {
      await prefs.setString('user_role', preservedUserRole);
    }
    if (preservedTenantId != null) {
      await prefs.setString('tenant_id', preservedTenantId);
    }
    if (preservedUserRestaurantId != null) {
      await prefs.setString('user_restaurant_id', preservedUserRestaurantId);
    }
    if (preservedUserRestaurantUuid != null) {
      await prefs.setString('user_restaurant_uuid', preservedUserRestaurantUuid);
    }
    
    CartService.clearCart();
    print("Dados temporários limpos (dados essenciais preservados)");
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
          case "login":  // NOVA ROTA
            return MaterialPageRoute(builder: (context) => const LoginView());
          case "home":
            // Verifica o tipo de app selecionado
            final appType = prefs?.getString('app_type') ?? 'food_delivery';
            
            if (appType == 'pos') {
              return MaterialPageRoute(builder: (context) => const POSAppRouter());
            }
            else if (appType == 'garcon') {
              return MaterialPageRoute(builder: (context) => const LoginView());
            }
             else {
              return MaterialPageRoute(builder: (context) => const MainTabView());
            }
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text("${AppLocalizations.of(context).noPathFor} ${routeSettings.name}"),
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
              menu: AppLocalizations.of(context).home,
              icon: Icons.rocket_sharp,
            ),
            _itemMenu(
              menu: AppLocalizations.of(context).menu,
              icon: Icons.format_list_bulleted_rounded,
            ),
            _itemMenu(
              menu: AppLocalizations.of(context).history,
              icon: Icons.history_toggle_off_rounded,
            ),
            _itemMenu(
              menu: AppLocalizations.of(context).promos,
              icon: Icons.discount_outlined,
            ),
            _itemMenu(
              menu: AppLocalizations.of(context).settings,
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