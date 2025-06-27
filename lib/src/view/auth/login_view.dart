import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback? onLoginPressed; // Accept the callback
  final _formKey = GlobalKey<FormState>();
  final String? errorMessage; // Accept an error message

  LoginView({
    super.key,
    required this.usernameController,
    required this.passwordController,
    this.onLoginPressed,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Makes it so the app start underneath the appbar/status bar in fe android
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.inversePrimary,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(10),
        child: Center(
          child: Form(
            key: _formKey,
            child: SizedBox(
              // Sets the max width so the content isn't the screen width
              width: 250,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                  // If the keyboard is opened the screen becomes smaller and is
                  // made scrollable
                  return SingleChildScrollView(
                    // Makes the column the same size as the viewport
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welkom bij de agenda app! \nLog in om te starten',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 60),
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'Gebruikersnaam',
                              labelStyle: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary
                              ),
                              border: OutlineInputBorder(),
                              filled: true,
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Vul uw gebruikersnaam in';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Wachtwoord',
                              labelStyle: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary
                              ),
                              border: OutlineInputBorder(),
                              filled: true,
                            ),
                            obscureText: true,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Vul uw wachtwoord in';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              // Validate the form when the login button is pressed
                              if (_formKey.currentState?.validate() ?? false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Bezig met inloggen...'),
                                      duration: Duration(seconds: 1),
                                    )
                                );
                                onLoginPressed!(); // Call the login function
                              }
                            },
                            child: Text('Log in'),
                          ),
                          if (errorMessage !=
                              null) // Display the error if there is one
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                errorMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          SizedBox(height: 20),
                          TextButton( // Button to the register screen
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/register');
                            },
                            child: Text('Registreren'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}