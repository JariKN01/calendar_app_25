Future<void> _handleRegister() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String passwordCheck = _passwordCheckController.text;

    print("Registreren met gebruikersnaam: $username");

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
    print("API aanroepen: $url");
    dynamic response;

    try{ // Tries to log the user in
      response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(userToBeCredentials)
      );
      print("API response status: ${response.statusCode}");
      print("API response body: ${response.body}");
    }
    catch (e){
      print("API fout: $e");
      setState(() {
        _errorMessage = 'Fout: ${e.toString()}';
      });
      return; // Stop verdere verwerking
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
      print("Onverwachte statuscode: ${response.statusCode}");
      setState(() {
        _errorMessage = "Er ging wellicht iets mis, probeer opnieuw!";
      });
    }
  }
