// lib/src/common/login_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String baseUrl = 'https://manna.software/api';
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login bem-sucedido
        return {
          'success': true,
          'data': responseData,
          'message': 'Login realizado com sucesso',
        };
      } else {
        // Erro de autenticação
        return {
          'success': false,
          'message': responseData['message'] ?? 'Credenciais inválidas',
          'data': null,
        };
      }
    } catch (e) {
      // Erro de conexão
      return {
        'success': false,
        'message': 'Erro de conexão. Verifique sua internet e tente novamente.',
        'data': null,
      };
    }
  }
}

// Atualização da LoginScreen para usar a API real
