import 'package:flutter/material.dart';

// Mock function to simulate authentication state
// Replace this with your actual authentication check
bool isLoggedIn() {
  return false; // Assume user is not logged in for this example
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Center(
        child: isLoggedIn()
            ? Text('You are logged in')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Welcome to BB Play'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Register Page
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Register'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Login Page
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
      ),
    );
  }
}
