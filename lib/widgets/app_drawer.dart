import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final String currentLocation;

  const AppDrawer({
    super.key,
    this.currentLocation = '/home',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Cabecera personalizada con degradado y perfil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F172A), // Slate-900 (Gris oscuro premium)
                  theme.colorScheme.primary, // Teal primario
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar centrado
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Text(
                        'JP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Textos del perfil alineados a la izquierda
                const Text(
                  'Jhandry Alexis Jaramillo Peñafiel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'jhjaramillope@uide.edu.ec',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Opción: Inicio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.home_rounded,
                color: currentLocation == '/home'
                    ? theme.colorScheme.primary
                    : Colors.grey.shade600,
              ),
              title: Text(
                'Inicio',
                style: TextStyle(
                  fontWeight: currentLocation == '/home'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: currentLocation == '/home'
                      ? theme.colorScheme.primary
                      : Colors.grey.shade800,
                ),
              ),
              selected: currentLocation == '/home',
              selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                context.pop(); // Cerrar drawer
                context.go('/home');
              },
            ),
          ),
          // Opción: Información
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.info_rounded,
                color: currentLocation == '/about'
                    ? theme.colorScheme.primary
                    : Colors.grey.shade600,
              ),
              title: Text(
                'Información',
                style: TextStyle(
                  fontWeight: currentLocation == '/about'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: currentLocation == '/about'
                      ? theme.colorScheme.primary
                      : Colors.grey.shade800,
                ),
              ),
              selected: currentLocation == '/about',
              selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                context.pop(); // Cerrar drawer
                context.go('/about');
              },
            ),
          ),
        ],
      ),
    );
  }
}
