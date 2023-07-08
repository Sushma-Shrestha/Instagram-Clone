import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/change_password_screen.dart';
import 'package:instagram_clone/screens/edit_profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class SettingScreen extends StatelessWidget {
  final String email;
  const SettingScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(
                              email: email,
                            )));
              },
              title: Text(
                'Change Password',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue[400]),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                              email: email,
                            )));
              },
              title: Text(
                'Edit profile',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
