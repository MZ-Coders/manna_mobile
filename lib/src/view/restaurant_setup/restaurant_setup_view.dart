import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/common/service_call.dart';
import 'package:dribbble_challenge/src/common/globs.dart';
import 'package:dribbble_challenge/src/common/api_config.dart';
import 'qr_scanner_view.dart';
import 'package:restart_app/restart_app.dart';

class RestaurantSetupView extends StatefulWidget {
  const RestaurantSetupView({Key? key}) : super(key: key);

  @override
  State<RestaurantSetupView> createState() => _RestaurantSetupViewState();
}

class _RestaurantSetupViewState extends State<RestaurantSetupView>
    with TickerProviderStateMixin {
  final TextEditingController _restaurantIdController = TextEditingController();
  final TextEditingController _tableIdController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCameraAvailable = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkCameraPermission();
    _showCurrentEnvironment();
    _loadExistingData(); // Carregar dados existentes se houver
  }
  
  // Carregar dados existentes para permitir reconfiguração
  Future<void> _loadExistingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingRestaurantId = prefs.getString('restaurant_id');
      final existingTableId = prefs.getString('table_id');
      
      if (existingRestaurantId != null && existingRestaurantId.isNotEmpty) {
        setState(() {
          _restaurantIdController.text = existingRestaurantId;
          if (existingTableId != null && existingTableId.isNotEmpty) {
            _tableIdController.text = existingTableId;
          }
        });
        
        print('📋 Dados existentes carregados: $existingRestaurantId');
        
        // Mostrar mensagem informativa
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dados existentes carregados. Você pode modificar e salvar novamente.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 4),
            ),
          );
        });
      }
    } catch (e) {
      print('⚠️ Erro ao carregar dados existentes: $e');
    }
  }
  
  void _showCurrentEnvironment() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final envInfo = ApiConfig.environmentInfo;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ambiente atual: ${envInfo['environment']} (${envInfo['api_url']})'),
          backgroundColor: envInfo['environment'] == 'Produção' ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  void dispose() {
    _restaurantIdController.dispose();
    _tableIdController.dispose();
    _urlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _isCameraAvailable = status == PermissionStatus.granted || 
                          status == PermissionStatus.limited;
    });
    
    if (!_isCameraAvailable) {
      final newStatus = await Permission.camera.request();
      setState(() {
        _isCameraAvailable = newStatus == PermissionStatus.granted || 
                            newStatus == PermissionStatus.limited;
      });
    }
  }

  Future<void> _scanQRCode() async {
    if (!_isCameraAvailable) {
      _showError('Permissão de câmera necessária para escanear QR Code');
      return;
    }

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QRScannerView(),
        ),
      );
      
      if (result != null && result is String && result.isNotEmpty) {
        _processScannedUrl(result);
      }
      
    } catch (e) {
      _showError('Erro ao escanear QR Code: $e');
    }
  }

  void _processScannedUrl(String url) {
    try {
      print('📱 Processando URL escaneada: $url');
      final uri = Uri.parse(url);
      
      // Procurar por diferentes variações do parâmetro restaurant
      final restaurantId = uri.queryParameters['restaurant'] ?? 
                          uri.queryParameters['restaurant_id'] ??
                          uri.queryParameters['rest_id'];
      
      final tableId = uri.queryParameters['table_id'] ?? 
                     uri.queryParameters['table'] ?? 
                     uri.queryParameters['mesa_id'];
      
      print('🏪 Restaurant ID encontrado: $restaurantId');
      print('🪑 Table ID encontrado: $tableId');
      
      if (restaurantId != null) {
        // Detectar ambiente baseado na URL do QR code usando ApiConfig
        final detectedApiUrl = ApiConfig.detectEnvironmentFromUrl(url);
        print('🌐 Ambiente detectado: $detectedApiUrl');
        
        // Guardar a configuração do ambiente detectado
        _saveEnvironmentConfig(detectedApiUrl);
        
        setState(() {
          _restaurantIdController.text = restaurantId;
          if (tableId != null) {
            _tableIdController.text = tableId;
          }
        });
        _tabController.animateTo(1); // Mudar para aba manual para confirmação
      } else {
        _showError('URL inválida. Não encontrados parâmetros de restaurante (restaurant, restaurant_id, rest_id).');
      }
    } catch (e) {
      print('❌ Erro ao processar URL: $e');
      _showError('URL inválida: $e');
    }
  }

  Future<void> _saveEnvironmentConfig(String apiBaseUrl) async {
    await ApiConfig.setApiUrl(apiBaseUrl);
    final envInfo = ApiConfig.environmentInfo;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ambiente detectado: ${envInfo['environment']}'),
        backgroundColor: envInfo['environment'] == 'Produção' ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _processUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Digite uma URL válida');
      return;
    }
    _processScannedUrl(url);
  }

  Future<void> _validateAndSave() async {
    final restaurantId = _restaurantIdController.text.trim();
    
    if (restaurantId.isEmpty) {
      _showError('ID do restaurante é obrigatório');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 Iniciando validação do restaurante: $restaurantId');
      print('🌐 URL da API atual: ${ApiConfig.mainUrl}');
      
      // Validar se o restaurante existe
      bool isValid = await _validateRestaurant(restaurantId);
      
      print('✅ Resultado da validação: $isValid');
      
      if (!isValid) {
        _showError('Restaurante não encontrado. Verifique o ID.');
        return;
      }

      print('💾 Restaurante validado, salvando dados...');
      
      // Salvar dados
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('restaurant_id', restaurantId);
      
      final tableId = _tableIdController.text.trim();
      if (tableId.isNotEmpty) {
        await prefs.setString('table_id', tableId);
      }
      
      await prefs.setBool('restaurant_setup_completed', true);
      
      print('🚀 Dados salvos com sucesso, finalizando configuração...');

      // Resetar loading ANTES do restart para evitar estado permanente
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Aguardar um pouco antes de finalizar
      await Future.delayed(const Duration(milliseconds: 500));

      // Reiniciar a aplicação - o main.dart detectará que
      // restaurant_setup_completed = true e iniciará o AppSelector
      if (mounted && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            print('📱 Configuração concluída, reiniciando aplicação...');
            Restart.restartApp();
          } else {
            print('⚠️ Context não disponível no PostFrameCallback');
          }
        });
      } else {
        print('⚠️ Context não disponível para finalização');
      }
      
    } catch (e) {
      _showError('Erro ao salvar configuração: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _validateRestaurant(String restaurantId) async {
    try {
      print('🔍 Validando restaurante: $restaurantId');
      print('🌐 Base URL: ${SVKey.baseUrl}');
      print('📞 URL completa: ${SVKey.baseUrl}menu/$restaurantId');
      
      // Usar um Completer para aguardar a resposta do ServiceCall
      final Completer<Map<String, dynamic>?> completer = Completer<Map<String, dynamic>?>();
      
      ServiceCall.getMenuItems(restaurantId,
        withSuccess: (Map<String, dynamic> data) {
          print('✅ Resposta da API: ${data.toString().substring(0, 200)}...');
          
          // Verificar se o completer ainda não foi completado (evitar timeout race condition)
          if (!completer.isCompleted) {
            if (data.containsKey('success') && data['success'] == true &&
                data.containsKey('restaurant') && data['restaurant'] != null) {
              final restaurant = data['restaurant'];
              print('🏪 Restaurante validado: ${restaurant['name']} (ID: ${restaurant['id']})');
              completer.complete(restaurant);
            } else {
              print('❌ Resposta inválida - success: ${data['success']}, restaurant: ${data.containsKey('restaurant')}');
              completer.complete(null);
            }
          }
        },
        failure: (String error) {
          print('❌ Erro na chamada da API: $error');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        }
      );
      
      // Aguardar a resposta com timeout aumentado para 30 segundos
      final restaurantData = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Timeout na validação do restaurante (30s)');
          return null;
        },
      );
      
      if (restaurantData != null) {
        // Salvar dados completos do restaurante para o OnBoarding usar
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('restaurant_name', restaurantData['name'] ?? '');
        await prefs.setString('restaurant_address', restaurantData['address'] ?? '');
        await prefs.setString('restaurant_city', restaurantData['city'] ?? '');
        await prefs.setString('restaurant_logo', restaurantData['logo'] ?? '');
        await prefs.setString('restaurant_phone', restaurantData['phone'] ?? '');
        
        print('💾 Dados completos do restaurante salvos');
        return true;
      }
      
      return false;
      
    } catch (e) {
      print('💥 Exceção na validação: $e');
      return false;
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TColor.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                     Image.asset(
                      'assets/manna_software__.png',
                      // width: 80,
                      // height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.restaurant,
                        size: 80,
                        color: TColor.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Configurar Restaurante',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure o restaurante para começar a usar o app',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: TColor.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: TColor.primary,
                  unselectedLabelColor: TColor.secondaryText,
                  indicatorColor: TColor.primary,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.qr_code_scanner),
                      text: 'QR Code',
                    ),
                    Tab(
                      icon: Icon(Icons.edit),
                      text: 'Manual',
                    ),
                    Tab(
                      icon: Icon(Icons.link),
                      text: 'URL',
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQRTab(),
                    _buildManualTab(),
                    _buildUrlTab(),
                  ],
                ),
              ),
              
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Save button
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 120,
            color: TColor.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 0),
          Text(
            'Escaneie o QR Code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aponte a câmera para o QR Code fornecido pelo restaurante',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: TColor.secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isCameraAvailable ? _scanQRCode : null,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                _isCameraAvailable ? 'Abrir Scanner' : 'Câmera não disponível',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCameraAvailable ? TColor.primary : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Configuração Manual',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Digite os dados fornecidos pelo restaurante',
                    style: TextStyle(
                      fontSize: 16,
                      color: TColor.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Restaurant ID
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID do Restaurante *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: TColor.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextField(
                        controller: _restaurantIdController,
                        decoration: InputDecoration(
                          hintText: 'Ex: abc123-def456-ghi789',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: TColor.primary),
                          ),
                          prefixIcon: Icon(Icons.store, color: TColor.primary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Table ID (optional) - keep visible and editable
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesa (Opcional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: TColor.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tableIdController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Mesa 5, Table 12',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: TColor.primary),
                          ),
                          prefixIcon: Icon(Icons.table_restaurant, color: TColor.primary),
                        ),
                      ),
                    ],
                  ),

                  // const Spacer(flex: 2,),
                  const SizedBox(height: 4),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: TColor.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'O ID do restaurante é obrigatório. A mesa pode ser configurada depois.',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColor.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUrlTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Cole a URL',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cole o link fornecido pelo restaurante',
                    style: TextStyle(
                      fontSize: 16,
                      color: TColor.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'URL do Restaurante',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: TColor.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'https://app.manna.software?restaurant_id=abc123&table_id=5',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: TColor.primary),
                      ),
                      prefixIcon: Icon(Icons.link, color: TColor.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processUrl,
                      icon: const Icon(Icons.content_paste, color: Colors.white),
                      label: const Text(
                        'Processar URL',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
