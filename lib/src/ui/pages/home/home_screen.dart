// src/ui/pages/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/navigation/navigation_bloc.dart';
import '../../../blocs/navigation/navigation_event.dart';
import '../../../blocs/navigation/navigation_state.dart';

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
    final authState = context.read<AuthBloc>().state;

    if ((index == 2 || index == 3) && authState is! AuthenticatedState) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } else {
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

    // O MultiBlocListener permite ouvir mudanças de estado silenciosamente
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            // Toda vez que deslogar, forçamos o App a voltar para a aba 0 (Home/Dashboard)
            if (authState is UnauthenticatedState || authState is AuthFailureState) {
              context.read<NavigationBloc>().add(TabTappedEvent(0));
            }
          },
        ),
      ],
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, navigationState) {
          // Precisamos ler o authState aqui dentro para montar a trava
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              
              Widget bodyWidget;
              
              // 🔥 TRAVA DE SEGURANÇA MÁXIMA 🔥
              // Se a aba selecionada for 2 (Review) ou 3 (Profile) e não tiver usuário logado,
              // NUNCA tente desenhar essas telas. Retorna apenas um loading enquanto 
              // o listener ali em cima joga o usuário para a aba 0.
              if ((navigationState.currentIndex == 2 || navigationState.currentIndex == 3) && 
                  authState is! AuthenticatedState) {
                bodyWidget = const Center(
                  child: CircularProgressIndicator(color: Colors.purpleAccent),
                );
              } else {
                // Desenha a tela normalmente
                bodyWidget = pages[navigationState.currentIndex];
              }

              return Scaffold(
                backgroundColor: const Color(0xFF121212),
                body: bodyWidget, 
                bottomNavigationBar: CustomBottomNav(
                  currentIndex: navigationState.currentIndex,
                  onTap: (index) => _onTabTapped(context, index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}