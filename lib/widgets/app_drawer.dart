import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _userName = 'Luis Eduardo Poma';
  static const _userEmail = 'lpoma@uide.edu.ec';

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue, size: 36),
            ),
            accountName: Text(
              _userName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(_userEmail),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => _navigate(context, AppRoutes.home),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => _navigate(context, AppRoutes.about),
          ),
        ],
      ),
    );
  }
}
