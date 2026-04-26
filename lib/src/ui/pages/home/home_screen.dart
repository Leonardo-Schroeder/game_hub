import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import '../catalog/catalog_screen.dart';
import '../review/review_screen.dart';
import 'tabs/dashboard_tab.dart';
import '../../widgets/custom_bottom_nav.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final bool _isUserLoggedIn = false;

  final List<Widget> _pages = [
    const DashboardTab(),
    const CatalogScreen(),
    const ReviewScreen(),
    const Center(child: Text('Profile Tab', style: TextStyle(color: Colors.white))),
  ];

  void _onTabTapped(int index) {
    if ((index == 2 || index == 3) && !_isUserLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _pages[_currentIndex],
      // Utilizando o widget customizado aqui:
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}