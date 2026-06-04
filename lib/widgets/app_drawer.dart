import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              'Jhandry Alexis Jaramillo Peñafiel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('jhandry.jaramillo@uide.edu.ec'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'JP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              context.pop(); // Close drawer
              context.go('/home'); // Navigate to home
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Información'),
            onTap: () {
              context.pop(); // Close drawer
              context.go('/about'); // Navigate to about
            },
          ),
        ],
      ),
    );
  }
}
