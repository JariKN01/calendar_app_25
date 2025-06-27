import 'package:agenda_app/src/extensions/capitalize.dart';
import 'package:agenda_app/src/model/user.dart';
import 'package:agenda_app/src/view/home/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomeController extends StatefulWidget {
  const HomeController({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeControllerState();
  }
}

class _HomeControllerState extends State<HomeController>
    with TickerProviderStateMixin {
  late User? _user = null;
  late String _bannerText;
  late TabController _tabController;
  bool _isLoading = true;
  // Create storage
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Check if the user is logged in
    _checkLoggedIn();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(_onTabChanged); // Check if the user changes tabs
    _bannerText = createBannerText();
  }

  Future<void> _checkLoggedIn() async {
    // Get token from storage, if it exists
    String? token;
    token = await storage.read(key: 'token');

    // Checks if the token exists
    // If the token does not exist, user was never logged in so they need to register
    // If the token is expired the user needs to login again
    if (mounted) {
      if (token == null || token == '') {
        Navigator.pushReplacementNamed(context, '/register');
      } else if (JwtDecoder.isExpired(token)) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }

    // If the user is logged in, get the user object
    await _getUser();

    setState(() {
      _bannerText = createBannerText();
    });

    // Set loading to false after checking the token
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUser() async {
    // Get the users data from storage and converts it to a User object
    String? storageId = await storage.read(key: 'id');
    String? storageName = await storage.read(key: 'name');
    String? storageToken = await storage.read(key: 'token');

    if (storageId != null && storageName != null) {
      int id = int.parse(storageId);
      setState(() {
        _user = User(id: id, name: storageName, token: storageToken);
      });
    }
  }

  // If the user switches tabs, change the banner
  void _onTabChanged() {
    // print('Tab changed to: ${_tabController.index}');
    setState(() {
      _bannerText = createBannerText();
    });
  }

  // Based on the tab the user is on, return the bannerText
  String createBannerText() {
    switch (_tabController.index) {
      case 0:
        return 'Agenda';
      case 1:
        return 'Welkom, ${_user?.name.capitalize()}!';
      case 2:
        return 'Teams';
      default:
        return 'Unknown Tab'; // Fallback case for safety
    }
  }

  @override
  Widget build(BuildContext context) {
    // Displays a spinner while checking if the token exists
    // If this is not used it briefly displays the home screen
    if(_isLoading) {
      return Center(child: CircularProgressIndicator(),);
    }

    return HomeView(
      user: _user,
      bannerText: _bannerText,
      tabController: _tabController,
    );
  }
}
