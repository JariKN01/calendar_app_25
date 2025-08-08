import 'package:calendar_app/src/controller/auth_controller.dart';
import 'package:calendar_app/src/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Gets the token from environment so you don't have to login everytime you test
const String token = String.fromEnvironment('TOKEN');

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized before async tasks
  final storage = FlutterSecureStorage();
  // If the token env var is set, write testdata to storage
  if (token.isNotEmpty) {
    // Decode the token
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    await storage.write(key: 'token', value: token);
    await storage.write(key: 'name', value: decodedToken['name']);
    await storage.write(key: 'id', value: decodedToken['id'].toString());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // Optie 1: Groen kleurenschema
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        // Optie 2: Grijs/neutrale kleuren
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        // Optie 3: Oranje kleurenschema
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        // Optie 4: Paars kleurenschema
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        // Optie 5: Volledig aangepast kleurenschema zonder blauw
        // colorScheme: const ColorScheme.light(
        //   primary: Color(0xFF2E7D32), // Donkergroen
        //   primaryContainer: Color(0xFFA5D6A7), // Lichtgroen
        //   secondary: Color(0xFF558B2F), // Groen accent
        //   secondaryContainer: Color(0xFFC8E6C9),
        //   surface: Color(0xFFFAFAFA), // Lichtgrijs
        //   surfaceVariant: Color(0xFFF5F5F5),
        //   background: Color(0xFFFFFFFF), // Wit
        //   error: Color(0xFFD32F2F), // Rood voor errors
        //   onPrimary: Color(0xFFFFFFFF), // Wit tekst op primair
        //   onSecondary: Color(0xFFFFFFFF),
        //   onSurface: Color(0xFF212121), // Donkergrijze tekst
        //   onBackground: Color(0xFF212121),
        //   onError: Color(0xFFFFFFFF),
        // ),
        useMaterial3: true,
      ),
      // Routes for the app
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => HomeController(),

        //Auth
        '/login': (BuildContext context) => LoginController(),
        '/register': (BuildContext context) => RegisterController(),

        //Events
        // '/event': (BuildContext context) => EventList(),
        // '/event/create': (BuildContext context) => EventCreationController(),
        // '/event/update': (BuildContext context) => EventUpdateController(),
        // '/event/delete': (BuildContext context) => EventDeleteController(),
      },
    );
  }
}