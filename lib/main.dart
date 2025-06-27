import 'package:agenda_app/src/controller/auth_controller.dart';
import 'package:agenda_app/src/controller/home_controller.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffD6FFFF)),
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