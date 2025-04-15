import 'dart:io';

// import 'dart:html' as html;
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/common/globs.dart';
import 'package:dribbble_challenge/src/common/locator.dart';
import 'package:dribbble_challenge/src/common/my_http_overrides.dart';
import 'package:dribbble_challenge/src/common/service_call.dart';
import 'package:dribbble_challenge/src/onboarding/onboarding_screen.dart';
import 'package:dribbble_challenge/src/view/login/welcome_view.dart';
import 'package:dribbble_challenge/src/view/main_tabview/main_tabview.dart';
import 'package:dribbble_challenge/src/view/on_boarding/startup_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';


SharedPreferences? prefs;
void main() async {
  setUpLocator();
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  final tableId = getTableIdFromUrl();

  if (tableId != null) {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('table_id', tableId);
    print("Table ID: $tableId");
  }
  prefs = await SharedPreferences.getInstance();

  if(Globs.udValueBool(Globs.userLogin)) {
    ServiceCall.userPayload = Globs.udValue(Globs.userPayload);
  }

  runApp( const MyApp(defaultHome:  StartupView(),));
}

String? getTableIdFromUrl() {
  if(kIsWeb) {
    print("Is web");
  // final url = html.window.location.href;
  final url = "https://example.com?table_id=12345";
  final uri = Uri.parse(url);
  print("URL: $url");
  return uri.queryParameters['table_id'];
  } else {
    return " ... ";
  }
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

class MyApp extends StatefulWidget {
  final Widget defaultHome;
  const MyApp({super.key, required this.defaultHome});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true,
      ),
      home: const OnBoardingScreen(),
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: (routeSettings){
        switch (routeSettings.name) {
          // case "welcome":
          //     return MaterialPageRoute(builder: (context) => const WelcomeView() );
          case "home":
              return MaterialPageRoute(builder: (context) => const MainTabView() );
          default:
              return MaterialPageRoute(builder: (context) => Scaffold(
                body: Center(
                  child: Text("No path for ${routeSettings.name}")
                ),
              ) );
        }
      },
      builder: (context, child) {
        return FlutterEasyLoading(child: child);
      },
    );
  }
}
