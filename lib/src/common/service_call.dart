import 'dart:async';
import 'dart:convert';

import 'package:dribbble_challenge/src/common/globs.dart';
import 'package:dribbble_challenge/src/common/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// typedef ResSuccess = Future<void> Function(Map<String, dynamic>);
// typedef ResFailure = Future<void> Function(dynamic);

typedef ResSuccess = void Function(Map<String, dynamic>);
typedef ResFailure = void Function(String);

class ServiceCall {
  static final NavigationService navigationService = locator<NavigationService>();
  static Map userPayload = {};


  static void post(Map<String, dynamic> parameter, String path,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() {
      try {
        var headers = {'Content-Type': 'application/x-www-form-urlencoded'};

        // if(isToken) {
        //   headers["token"] = "";
        // }

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
  Future(() {
    try {
      var headers = {'Content-Type': 'application/json'};

      // if(isToken) {
      //   headers["token"] = "";
      // }

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

  static logout(){
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
  }

// static Future<Map<String, dynamic>?> getMenuItems(String menu_id) async {
//   Completer<Map<String, dynamic>?> completer = Completer();
  
//   post({}, SVKey.baseUrl + "menu/" + menu_id,
//       isToken: false,
//       withSuccess: (Map<String, dynamic> jsonObj) {
//         if (jsonObj['status'] == 200) {
//           completer.complete(jsonObj);
//         } else {
//           completer.completeError(jsonObj['message']);
//         }
//       },
//       failure: (err) {
//         completer.completeError(err);
//       });
      
//   return completer.future;
// }

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

static Future<Map<String, dynamic>> makeApiCall({
    required String url,
    required String method,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Implementar chamada HTTP aqui
      // Por enquanto, simulando resposta
      await Future.delayed(const Duration(seconds: 2));
      
      // Simular resposta de sucesso para demonstração
      if (data['email'] == 'garcom@exemplo.com' && data['password'] == '123456') {
        return {
          'success': true,
          'data': {
            'id': 1,
            'name': 'João Garçom',
            'email': data['email'],
            'role': 'waiter',
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Email ou senha incorretos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão',
      };
    }
  }
}
