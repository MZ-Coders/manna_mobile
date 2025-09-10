import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static ApiConfig? _instance;
  static String? _cachedApiUrl;
  
  ApiConfig._internal();
  
  static ApiConfig get instance {
    _instance ??= ApiConfig._internal();
    return _instance!;
  }
  
  /// Obtém a URL base da API de forma síncrona (usa cache)
  static String get mainUrl {
    if (kIsWeb) {
      final currentHost = Uri.base.host;
      if (currentHost == 'test.app.manna.software') {
        return 'https://test.manna.software';
      } else if (currentHost == 'app.manna.software') {
        return 'https://manna.software';
      }
      return 'https://test.manna.software';
    }
    
    // Para mobile, usar valor em cache ou padrão
    return _cachedApiUrl ?? 'https://test.manna.software';
  }
  
  /// Carrega a configuração salva (deve ser chamado no início da app)
  static Future<void> initialize() async {
    if (kIsWeb) return; // Web não precisa de inicialização
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedApiUrl = prefs.getString('api_base_url') ?? 'https://test.manna.software';
      print('API URL carregada: $_cachedApiUrl');
    } catch (e) {
      print('Erro ao carregar API URL: $e');
      _cachedApiUrl = 'https://test.manna.software';
    }
  }
  
  /// Salva a nova configuração de API
  static Future<void> setApiUrl(String apiUrl) async {
    if (kIsWeb) return; // Web não salva configuração
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_base_url', apiUrl);
      _cachedApiUrl = apiUrl;
      print('Nova API URL salva: $apiUrl');
    } catch (e) {
      print('Erro ao salvar API URL: $e');
    }
  }
  
  /// Detecta o ambiente baseado na URL do QR code
  static String detectEnvironmentFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host == 'test.app.manna.software') {
        return 'https://test.manna.software';
      } else if (uri.host == 'app.manna.software') {
        return 'https://manna.software';
      }
    } catch (e) {
      print('Erro ao detectar ambiente da URL: $e');
    }
    
    // Padrão para desenvolvimento ou URLs não reconhecidas
    return 'https://test.manna.software';
  }
  
  /// Obtém informações sobre o ambiente atual
  static Map<String, String> get environmentInfo {
    final url = mainUrl;
    return {
      'environment': url.contains('test') ? 'Teste' : 'Produção',
      'api_url': url,
      'is_production': url.contains('test') ? 'false' : 'true',
    };
  }
}
