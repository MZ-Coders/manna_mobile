import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:dribbble_challenge/main.dart';

class Globs {
  static const appName = "Food Delivery";

  static const userPayload = "user_payload";
  static const userLogin = "user_login";

  static void showHUD({String status = "loading ....."}) async {
    await Future.delayed(const Duration(milliseconds: 1));
    EasyLoading.show(status: status);
  }

  static void hideHUD() {
    EasyLoading.dismiss();
  }


  static void udSet(dynamic data, String key){
    var jsonStr = json.encode(data);
    prefs?.setString(key, jsonStr);
  }

  static void udStringSet(String data, String key){
    prefs?.setString(key, data);
  }

  static void udBoolSet(bool data, String key) {
    prefs?.setBool(key, data);
  }

  static void udIntSet(int data, String key)  {
    prefs?.setInt(key, data);
  }

  static void udDoubleSet(double data, String key)  {
    prefs?.setDouble(key, data);
  }

  static dynamic udValue(String key) {
    return json.decode(prefs?.get(key) as String? ?? "{}");
  }

  static String udValueString(String key) {
    return prefs?.get(key) as String? ?? "";
  }

  static bool udValueBool(String key) {
    return prefs?.get(key) as bool? ?? false;
  }

  static bool udValueTrueBool(String key) {
    return prefs?.get(key) as bool? ?? true;
  }

  static int udValueInt(String key) {
    return prefs?.get(key) as int? ?? 0;
  }

  static double udValueDouble(String key) {
    return prefs?.get(key) as double? ?? 0.0;
  }

  static void udRemove(String key) {
    prefs?.remove(key);
  }

  static Future<String> timeZone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } on PlatformException {
        return "";
    }
  }
}

class SVKey {
  // Função para determinar a mainUrl baseada na URL atual
  static String get mainUrl {
    if (kIsWeb) {
      final currentHost = Uri.base.host;
      if (currentHost == 'test.manna.software') {
        return 'https://test.app.manna.software';
      } else if (currentHost == 'app.manna.software') {
        return 'https://manna.software';
      }
    }
    // URL padrão para desenvolvimento/mobile ou se não corresponder aos casos acima (ambiente de teste)
    return 'https://test.app.manna.software';
  }
  
  static String get baseUrl => '$mainUrl/api/';
  static String get nodeUrl => mainUrl;

  static String get svLogin => '${baseUrl}login';
  static String get svSignUp => '${baseUrl}sign_up';
  static String get svForgotPasswordRequest => '${baseUrl}forgot_password_request';
  static String get svForgotPasswordVerify => '${baseUrl}forgot_password_verify';
  static String get svForgotPasswordSetNew => '${baseUrl}forgot_password_set_new';
}

class KKey {
  static const payload = "payload";
  static const status = "status";
  static const message = "message";
  static const authToken = "auth_token";
  static const name = "name";
  static const email = "email";
  static const mobile = "mobile";
  static const address = "address";
  static const userId = "user_id";
  static const resetCode = "reset_code";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
}

class MSG {
  static const enterEmail = "Please enter your valid email address.";
  static const enterName = "Please enter your name.";
  static const enterCode = "Please enter valid reset code.";

  static const enterMobile = "Please enter your valid mobile number.";
  static const enterAddress = "Please enter your address.";
  static const enterPassword =
      "Please enter password minimum 6 characters at least.";
  static const enterPasswordNotMatch =
      "Please enter password not match.";
  static const success = "success";
  static const fail = "fail";
}
