// account_page.dart
import 'package:flutter/material.dart';
import 'package:ott_mobile/pages/login_page.dart';
import 'package:ott_mobile/pages/register_page.dart';

bool isLoggedIn() {
  return false;
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoggedIn()
            ? const Text(
                'You are logged in',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Welcome to The BrandBook Play!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text('Already have an Account? Sign In'),
                  ),
                ],
              ),
      ),
    );
  }
}
