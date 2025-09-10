import 'dart:async';
import 'dart:convert';

import 'package:dribbble_challenge/src/common/globs.dart';
import 'package:dribbble_challenge/src/common/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


typedef ResSuccess = void Function(Map<String, dynamic>);
typedef ResFailure = void Function(String);

class ServiceCall {
  static final NavigationService navigationService = locator<NavigationService>();
  static Map userPayload = {};

  static void post(Map<String, dynamic> parameter, String path,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() async {
      try {
        var headers = {'Content-Type': 'application/x-www-form-urlencoded'};

        if(isToken) {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');
  if (token != null) {
    headers["Authorization"] = "Bearer $token";
  }
}

        http
            .post(Uri.parse(path), body: parameter, headers: headers)
            .then((value) {
          if (kDebugMode) {
            print(value.body);
          }
          try {
            var jsonObj =
                json.decode(value.body) as Map<String, dynamic>? ?? {};

            if (withSuccess != null) withSuccess(jsonObj);
          } catch (err) {
            if (failure != null) failure(err.toString());
          }
        }).catchError( (e) {
           if (failure != null) failure(e.toString());
        });
      } catch (err) {
        if (failure != null) failure(err.toString());
      }
    });
  }

static void get(String path,
    {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
  Future(() async{
    try {
      var headers = {'Content-Type': 'application/json'};

      if(isToken) {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');
  if (token != null) {
    headers["Authorization"] = "Bearer $token";
  }
}

      http
          .get(Uri.parse(path), headers: headers)
          .then((value) {
        if (!kDebugMode) {
          print(value.body);
        }
        try {
          var jsonObj =
              json.decode(value.body) as Map<String, dynamic>? ?? {};
          print(jsonObj);
          if (withSuccess != null) withSuccess(jsonObj);
        } catch (err) {
          if (failure != null) failure(err.toString());
        }
      }).catchError((e) {
        if (failure != null) failure(e.toString());
      });
    } catch (err) {
      if (failure != null) failure(err.toString());
    }
  });
}

static void getMenuItems(
    String menu_id,
    {ResSuccess? withSuccess, ResFailure? failure}) {
  get(SVKey.baseUrl + "menu/" + menu_id,
      isToken: false,
      withSuccess: (Map<String, dynamic> jsonObj) {
        if (jsonObj['success'] == true) {
          if (withSuccess != null) withSuccess(jsonObj);
        } else {
          // print("********************");
          if (failure != null) failure(jsonObj['message']);
        }
      },
      failure: (err) {
        // print("@@@@@@@@@@@@@@@@@@@@@");
        if (failure != null) failure(err);
      });
}

  // Função específica para login
  static void login(String email, String password,
      {ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() {
      try {
        var headers = {'Content-Type': 'application/json'};
        
        var parameter = {
          'email': email,
          'password': password,
        };

        http
            .post(Uri.parse(SVKey.svLogin), 
                 body: json.encode(parameter), 
                 headers: headers)
            .then((value) {
          if (kDebugMode) {
            print("Login Response: ${value.body}");
          }
          try {
            var jsonObj =
                json.decode(value.body) as Map<String, dynamic>? ?? {};

            if (withSuccess != null) withSuccess(jsonObj);
          } catch (err) {
            if (failure != null) failure(err.toString());
          }
        }).catchError((e) {
           if (failure != null) failure(e.toString());
        });
      } catch (err) {
        if (failure != null) failure(err.toString());
      }
    });
  }

 static logout() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Limpar dados específicos do usuário
  await prefs.remove('auth_token');
  await prefs.remove('user_id');
  await prefs.remove('user_name');
  await prefs.remove('user_email');
  await prefs.remove('user_role');
  await prefs.remove('tenant_id');
  await prefs.remove('user_restaurant_id');
  await prefs.remove('user_restaurant_uuid');
  
  Globs.udBoolSet(false, Globs.userLogin);
  userPayload = {};
  navigationService.navigateTo("welcome");
}

// Verificar se usuário está logado
static Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');
  bool isLogged = Globs.udValueBool(Globs.userLogin);
  return token != null && isLogged;
}

// Obter dados do usuário logado
static Future<Map<String, dynamic>?> getCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  if (await isUserLoggedIn()) {
    return {
      'id': prefs.getString('user_id'),
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
      'role': prefs.getString('user_role'),
      'tenant_id': prefs.getString('tenant_id'),
      'restaurant_id': prefs.getString('user_restaurant_id'),
      'restaurant_uuid': prefs.getString('user_restaurant_uuid'),
    };
  }
  return null;
}

// SUBSTITUA o método purchase() em lib/src/common/service_call.dart

static void purchaseOld(Map<String, dynamic> purchaseData,
    {ResSuccess? withSuccess, ResFailure? failure}) {
  Future(() async {
    try {
      var headers = {'Content-Type': 'application/json'};

      // 🔥 ADICIONAR TOKEN DE AUTORIZAÇÃO (NOVO)
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      if (kDebugMode) {
        print("=== ENVIANDO PEDIDO PARA API ===");
        print("URL: ${SVKey.baseUrl}orders");
        print("Headers: $headers");
        print("Purchase Data: ${json.encode(purchaseData)}");
        print("================================");
      }

      http
          .post(Uri.parse(SVKey.baseUrl + "orders"), 
               body: json.encode(purchaseData), 
               headers: headers)
          .then((value) {
        if (kDebugMode) {
          print("=== RESPOSTA DA API ===");
          print("Status Code: ${value.statusCode}");
          print("Response Body: ${value.body}");
          print("=======================");
        }
        
        try {
          var jsonObj = json.decode(value.body) as Map<String, dynamic>? ?? {};

          // Verificar se o pedido foi criado com sucesso
          if (jsonObj['success'] == true || 
              value.statusCode == 200 || 
              value.statusCode == 201) {
            
            print('✅ Pedido enviado com sucesso!');
            if (withSuccess != null) withSuccess(jsonObj);
          } else {
            String errorMessage = jsonObj['message'] ?? 
                                 jsonObj['error'] ?? 
                                 'Erro ao processar pedido';
            print('❌ Erro no pedido: $errorMessage');
            if (failure != null) failure(errorMessage);
          }
        } catch (err) {
          print('❌ Erro ao processar resposta: $err');
          if (failure != null) failure('Erro ao processar resposta: $err');
        }
      }).catchError((e) {
        print('❌ Erro na requisição HTTP: $e');
        if (failure != null) failure('Erro de conexão: $e');
      });
    } catch (err) {
      print('❌ Erro geral: $err');
      if (failure != null) failure('Erro interno: $err');
    }
  });
}
  // Função para registar compra
static void purchase(Map<String, dynamic> purchaseData,
    {ResSuccess? withSuccess, ResFailure? failure}) {
  Future(() {
    try {
      var headers = {'Content-Type': 'application/json'};

      if (kDebugMode) {
        print("Purchase Data: ${json.encode(purchaseData)}");
      }

      http
          .post(Uri.parse(SVKey.baseUrl + "orders"), 
               body: json.encode(purchaseData), 
               headers: headers)
          .then((value) {
        if (kDebugMode) {
          print("Purchase Response: ${value.body}");
        }
        try {
          var jsonObj =
              json.decode(value.body) as Map<String, dynamic>? ?? {};

          if (jsonObj['success'] == true || value.statusCode == 200 || value.statusCode == 201) {
            if (withSuccess != null) withSuccess(jsonObj);
          } else {
            if (failure != null) failure(jsonObj['message'] ?? 'Erro ao processar compra');
          }
        } catch (err) {
          if (failure != null) failure(err.toString());
        }
      }).catchError((e) {
         if (failure != null) failure(e.toString());
      });
    } catch (err) {
      if (failure != null) failure(err.toString());
    }
  });
}

// Função para verificar status de um pedido específico
static void getOrderStatus(String orderId,
    {ResSuccess? withSuccess, ResFailure? failure}) {
  Future(() {
    try {
      var headers = {'Content-Type': 'application/json'};
      
      // Adicionar token de autorização se disponível
      SharedPreferences.getInstance().then((prefs) {
        String? token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        // Fazer a requisição GET para a API
        http
          .get(Uri.parse(SVKey.baseUrl + "orders/" + orderId + "/status"), 
               headers: headers)
          .then((value) {
            if (kDebugMode) {
              print("Order Status Response: ${value.body}");
            }
            try {
              var jsonObj = json.decode(value.body) as Map<String, dynamic>? ?? {};

              if (jsonObj['success'] == true || value.statusCode == 200) {
                if (withSuccess != null) withSuccess(jsonObj);
              } else {
                if (failure != null) failure(jsonObj['message'] ?? 'Erro ao obter status do pedido');
              }
            } catch (err) {
              if (failure != null) failure(err.toString());
            }
          }).catchError((e) {
             if (failure != null) failure(e.toString());
          });
      });
    } catch (err) {
      if (failure != null) failure(err.toString());
    }
  });
}
}