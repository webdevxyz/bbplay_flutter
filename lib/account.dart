import 'package:flutter/material.dart';

bool isLoggedIn() {
  return false;
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.lightBlue[50], // Set a light blue background color
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(
            fontSize: 24, // Increase font size
            fontWeight: FontWeight.bold, // Make font bold
          ),
        ),
      ),
      body: Center(
        child: isLoggedIn()
            ? const Text(
                'You are logged in',
                style: TextStyle(
                  fontSize: 20, // Increase font size for login text
                  color: Colors.green, // Set text color to green
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Welcome to BB Play',
                    style: TextStyle(
                      fontSize: 28, // Increase font size for welcome text
                      fontWeight: FontWeight.bold, // Make font bold
                      color: Color.fromARGB(
                          255, 0, 0, 0), // Set text color to deep purple
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Register Page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 48, 39, 176), // Set button background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15), // Set button padding
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          fontSize: 18), // Increase font size for button text
                    ),
                  ),
                  const SizedBox(height: 10), // Adjust spacing
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Login Page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.orange, // Set button background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15), // Set button padding
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 18), // Increase font size for button text
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
