import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/common/extension.dart';
import 'package:dribbble_challenge/src/common/globs.dart';
import 'package:dribbble_challenge/src/common_widget/round_button.dart';
import 'package:dribbble_challenge/src/view/login/rest_password_view.dart';
import 'package:dribbble_challenge/src/view/login/sing_up_view.dart';
import 'package:dribbble_challenge/src/view/main_tabview/main_tabview.dart';
import 'package:dribbble_challenge/src/view/on_boarding/on_boarding_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/service_call.dart';
import '../../common_widget/round_icon_button.dart';
import '../../common_widget/round_textfield.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              Text(
                "Login",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                "Add your details to login",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Your Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundButton(
                title: "Login",
                onPressed: () {
                  btnLogin();
                },
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordView(),
                    ),
                  );
                },
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  //TODO: Action
  void btnLogin() {
    if (!txtEmail.text.isEmail) {
      mdShowAlert(Globs.appName, MSG.enterEmail, () {});
      return;
    }

    if (txtPassword.text.length < 6) {
      mdShowAlert(Globs.appName, MSG.enterPassword, () {});
      return;
    }

    endEditing();

    serviceCallLogin({});
  }

  //TODO: ServiceCall
  void serviceCallLogin(Map<String, dynamic> parameter) {
    Globs.showHUD();
    
    ServiceCall.login(
      txtEmail.text, 
      txtPassword.text,
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        // if (kDebugMode) {
          print('Login response: $responseObj');
        // }
        
        // Verificar se o login foi bem-sucedido
       if (responseObj['user'] != null && responseObj['token'] != null) {
    
        // Salvar dados do usuário
        Map<String, dynamic> userData = responseObj['user'] as Map<String, dynamic>;
        Globs.udSet(userData, Globs.userPayload);
        
        // Salvar token separadamente para uso nas requisições
        String token = responseObj['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_id', userData['id'].toString());
        await prefs.setString('user_name', userData['name'] ?? '');
        await prefs.setString('user_email', userData['email'] ?? '');
        await prefs.setString('user_role', userData['role'] ?? '');
        
        // Salvar dados específicos se existirem
        // if (userData['tenant_id'] != null) {
        //   await prefs.setString('tenant_id', userData['tenant_id'].toString());
        // }
        if (userData['restaurant_id'] != null) {
          await prefs.setString('user_restaurant_id', userData['restaurant_id'].toString());
        }
        if (userData['restaurant_uuid'] != null) {
          await prefs.setString('user_restaurant_uuid', userData['restaurant_uuid']);
        }
        
        print('Dados do usuário salvos: ${userData['name']} (${userData['role']})');
        
        // Marcar como logado
        Globs.udBoolSet(true, Globs.userLogin);
        
        // Atualizar ServiceCall com os dados do usuário
        ServiceCall.userPayload = userData;

        // Navegar para a próxima tela
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainTabView(),
            ),
            (route) => false);
            
      } else {
        // Login falhou
        String errorMessage = responseObj['message'] as String? ?? MSG.fail;
        mdShowAlert(Globs.appName, errorMessage, () {});
      } 
      }, 
      failure: (err) async {
        Globs.hideHUD();
        mdShowAlert(Globs.appName, err, () {});
      }
    );
  }
}