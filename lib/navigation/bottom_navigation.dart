import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.brown[700],
      unselectedItemColor: Colors.grey[600],
      backgroundColor: const Color(0x4BF0CCAA), // Color similar al ejemplo de Kotlin
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Sedes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menú',
        ),
      ],
    );
  }
}

class ScaffoldWithBottomNavigation extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const ScaffoldWithBottomNavigation({
    Key? key,
    required this.child,
    required this.currentRoute,
  }) : super(key: key);

  @override
  State<ScaffoldWithBottomNavigation> createState() => _ScaffoldWithBottomNavigationState();
}

class _ScaffoldWithBottomNavigationState extends State<ScaffoldWithBottomNavigation> {
  int _calculateSelectedIndex() {
    final String location = widget.currentRoute;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/headquarters')) {
      return 1;
    }
    if (location.startsWith('/menu')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/headquarters');
        break;
      case 2:
        context.go('/menu');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _calculateSelectedIndex(),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}