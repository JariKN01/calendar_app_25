//Authentication, Register & Login
import 'dart:convert';
import 'dart:io';
import 'package:agenda_app/src/constants.dart';
import 'package:http/http.dart' as http;
import 'package:agenda_app/src/view/auth/login_view.dart';
import 'package:agenda_app/src/view/auth/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginController extends StatefulWidget {
  final String name; // The username to put in the 'Gebruikersnaam' field
  const LoginController({super.key, this.name = ''});

  @override
  State<StatefulWidget> createState() {
    return _LoginControllerState();
  }
}

class _LoginControllerState extends State<LoginController> {
  late String _name;
  // Holds the data for the username field in the view
  late TextEditingController _usernameController;
  // Holds the data for the password field in the view
  late TextEditingController _passwordController;
  // The error message that is displayed in the view, if it is not null
  String? _errorMessage;

  // Create storage
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _usernameController = TextEditingController(text: _name);
    _passwordController = TextEditingController(text: '');
    _errorMessage = null;

    // Check if the user is logged in
    _checkIfLoggedIn();
  }

  Future<void> _handleLogin() async {
    // Gets the username and password from the form fields and maps them
    String username = _usernameController.text;
    String password = _passwordController.text;
    Map<String, String> userCredentials = {
      'name': username,
      'password': password
    };

    // URL to API login endpoint
    final url = Uri.parse('${Constants.baseApiUrl}/auth/login');
    dynamic response;

    try { // Tries to log the user in
      response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(userCredentials)
      );
    } catch (e) {
      // print(e);
      setState(() {
        _errorMessage = 'Er ging iets fout. \nProbeer het opnieuw';
      });
    }

    // Checks if the response was ok, if so save the user data
    if (response.statusCode == 200) {
      setState(() {
        _errorMessage = null;
      });

      // Decode the response body
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];

      // Write values to storage
      await storage.write(key: 'token', value: data['token']);
      // Id & name is not implemented in the API yet so they are only added if they exist
      if (data['id'] != null) {
        String id = data['id'].toString();
        await storage.write(key: 'id', value: id);
      }
      if (data['name'] != null) {
        await storage.write(key: 'name', value: data['name']);
      }

      // Go to home page
      // Check if the widget is still mounted
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } else if (response.statusCode == 401) {
      setState(() {
        _errorMessage = 'Gebruikersnaam of wachtwoord is incorrect';
      });
    } else {
      setState(() {
        _errorMessage = 'Er ging iets fout. \nProbeer het opnieuw';
      });
    }
  }

  Future<void> _checkIfLoggedIn() async {
    // Get token from storage, if it exists
    String? token = await storage.read(key: 'token') ?? '';

    // If the token exists & is not expired go to the home page
    if (token != '' && !JwtDecoder.isExpired(token)) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginView(
      usernameController: _usernameController,
      passwordController: _passwordController,
      onLoginPressed: _handleLogin, // Pass the login function to the view
      errorMessage: _errorMessage,
    );
  }
}

class RegisterController extends StatefulWidget{
  const RegisterController({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return _RegisterControllerState();
  }
}

class _RegisterControllerState extends State<RegisterController>{
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordCheckController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: '');
    _passwordController = TextEditingController(text: '');
    _passwordCheckController = TextEditingController(text: '');
    _errorMessage = null;
  }

  Future<void> _handleRegister() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String passwordCheck = _passwordCheckController.text;

    if(password != passwordCheck){
      setState(() {
        _errorMessage = "Wachtwoorden komen niet overeen";
      });
      return;
    }
    
    Map<String, String> userToBeCredentials = {
      'name': username,
      'password': password
    };

    final url = Uri.parse('${Constants.baseApiUrl}/auth/register');
    dynamic response;

    try{ // Tries to log the user in
      response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(userToBeCredentials)
      );
    } 
    catch (e){
      // print(e);
      setState(() {
        _errorMessage = 'Er ging iets fout. \nProbeer het opnieuw';
      });
    }

    if(response.statusCode == 201){
      setState(() {
        _errorMessage = null;
      });

      if(mounted){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginController(name: username)
          ),
        );
      }
    }
    else if(response.statusCode == 400){
      setState(() {
        _errorMessage = "Gebruikersnaam is al in gebruik! \nKies alstublieft een andere!";
      });
    }
    else{
      setState(() {
        _errorMessage = "Er ging wellicht iets mis, probeer opnieuw!";
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RegisterView(
      usernameController: _usernameController,
      passwordController: _passwordController,
      passwordCheckController: _passwordCheckController,
      onRegisterPressed: _handleRegister, // Pass the login function to the view
      errorMessage: _errorMessage,
    );
  }
}