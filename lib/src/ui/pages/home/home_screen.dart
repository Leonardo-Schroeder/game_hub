// src/ui/pages/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/navigation/navigation_bloc.dart';
import '../../../blocs/navigation/navigation_event.dart';
import '../../../blocs/navigation/navigation_state.dart';

// Importando o BLoC de Autenticação
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';

import '../auth/auth_screen.dart';
import '../catalog/catalog_screen.dart';
import '../profile/profile_screen.dart';
import '../review/review_screen.dart';
import 'tabs/dashboard_tab.dart';
import '../../widgets/custom_bottom_nav.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onTabTapped(BuildContext context, int index) {
    // Pegamos o estado atual do AuthBloc diretamente do context
    final authState = context.read<AuthBloc>().state;

    // 👇 Usamos "is! AuthenticatedState" (Se NÃO estiver logado)
    // Isso garante que se o estado for Initial, Failure ou Unauthenticated, ele vai pro Login
    if ((index == 2 || index == 3) && authState is! AuthenticatedState) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } else {
      // Se estiver logado (ou se for abas públicas: Dashboard e Catálogo), navega normalmente
      context.read<NavigationBloc>().add(TabTappedEvent(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardTab(),
      const CatalogScreen(),
      const ReviewScreen(),
      const ProfileScreen(),
    ];

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navigationState) {
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: pages[navigationState.currentIndex], 
          bottomNavigationBar: CustomBottomNav(
            currentIndex: navigationState.currentIndex,
            onTap: (index) => _onTabTapped(context, index),
          ),
        );
      },
    );
  }
}