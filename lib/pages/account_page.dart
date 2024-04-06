import 'package:flutter/material.dart';
import 'package:ott_mobile/pages/login_page.dart';
import 'package:ott_mobile/pages/register_page.dart';
import 'package:ott_mobile/pages/select_profile_page.dart';
import 'package:ott_mobile/pages/favourite_page.dart';
import 'package:ott_mobile/pages/watch_history_page.dart';
import 'package:ott_mobile/pages/contact_us_page.dart';
import 'package:ott_mobile/pages/settings_page.dart';
import 'package:ott_mobile/pages/logout_page.dart';

bool isLoggedIn() {
  return false; // Replace this with your actual authentication logic.
}

class AccountPage extends StatelessWidget {
  AccountPage({super.key}); // Removed the const from the constructor

  final List<Map<String, dynamic>> menuItems = [
    {
      "name": "Login",
      "icon": Icons.login,
      "show": true,
      "onTap": const LoginPage(),
    },
    {
      "name": "Register",
      "icon": Icons.person_add,
      "show": true,
      "onTap": const RegisterPage(),
    },
    {
      "name": "Select Profile",
      "icon": Icons.group,
      "show": true,
      "onTap": SelectProfilePage(),
    },
    {
      "name": "My Favourites",
      "icon": Icons.favorite,
      "show": true,
      "onTap": FavouritePage(),
    },
    {
      "name": "Watch History",
      "icon": Icons.history,
      "show": true,
      "onTap": WatchHistoryPage(),
    },
    {
      "name": "Contact Us",
      "icon": Icons.contact_support,
      "show": true,
      "onTap": ContactUsPage(),
    },
    {
      "name": "Settings",
      "icon": Icons.settings,
      "show": true,
      "onTap": SettingsPage(),
    },
    {
      "name": "Logout",
      "icon": Icons.logout,
      "show": true,
      "onTap": LogoutPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoggedIn()
            ? const Text(
                'You are logged in',
                style: TextStyle(fontSize: 20, color: Colors.green),
              )
            : SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Since it's inside a SingleChildScrollView
                  itemCount: menuItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = menuItems[index];
                    if (!item["show"]) {
                      return const SizedBox
                          .shrink(); // Do not render if "show" is false
                    }
                    return ListTile(
                      leading: Icon(item["icon"]),
                      title: Text(item["name"]),
                      onTap: () {
                        // Navigator logic here
                        var page = item["onTap"];
                        if (page != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => page),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}
