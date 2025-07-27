import 'dart:async';
import 'dart:convert';

import 'package:dribbble_challenge/src/common/globs.dart';
import 'package:dribbble_challenge/src/common/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  static logout(){
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
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
}