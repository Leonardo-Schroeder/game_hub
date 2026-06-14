// src/ui/pages/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_hub/src/blocs/auth/auth_bloc.dart';
import 'package:game_hub/src/blocs/auth/auth_event.dart';
import 'package:game_hub/src/blocs/auth/auth_state.dart';

import 'package:game_hub/src/ui/pages/auth/register_screen.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            filled: true,
            fillColor: const Color(0xFF232323),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            // CORREÇÃO: Limpa a pilha de telas para o usuário não conseguir "voltar" ao login
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating, // Fica flutuando mais elegante
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoadingState;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF38006B), Color(0xFF121212)],
                    begin: Alignment.topCenter,
                    end: Alignment.center, 
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        
                        // ÍCONE DO APP
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD500F9), Color(0xFFFF1493)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD500F9).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.gamepad, size: 40, color: Color(0xFF1E1E1E)),
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
                        
                        const SizedBox(height: 16),
                        
                        // TÍTULOS
                        const Text(
                          'GameHub',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                        
                        const Text(
                          'Games & RPG Community',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                        
                        const SizedBox(height: 40),

                        // CARD CENTRAL DE LOGIN
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161618),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Bem-vindo de volta!',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Entre na sua conta para avaliar jogos, montar sua biblioteca e interagir com outros exploradores.',
                                style: TextStyle(fontSize: 14, color: Colors.white54, height: 1.4),
                              ),
                              const SizedBox(height: 24),
                              
                              _buildTextField('E-mail', 'seu@email.com', Icons.email_outlined, _emailController),
                              const SizedBox(height: 16),
                              _buildTextField('Senha', '••••••••', Icons.lock_outline, _passwordController, isPassword: true),
                              
                              const SizedBox(height: 24),
                              
                              // Botão Entrar
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF9D00FF), Color(0xFFE100FF)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context.read<AuthBloc>().add(
                                            LoginRequestedEvent(
                                              _emailController.text.trim(),
                                              _passwordController.text.trim(),
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    // CORREÇÃO: Mantém o fundo transparente para o degradê aparecer enquanto desativado
                                    disabledBackgroundColor: Colors.transparent, 
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              const Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white12, thickness: 1)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('ou', style: TextStyle(color: Colors.white38, fontSize: 14)),
                                  ),
                                  Expanded(child: Divider(color: Colors.white12, thickness: 1)),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Rodapé
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Não tem conta? ', style: TextStyle(color: Colors.white54)),
                                  GestureDetector(
                                    onTap: isLoading 
                                        ? null 
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const RegisterScreen(),
                                              ),
                                            );
                                          },
                                    child: const Text(
                                      'Cadastre-se',
                                      style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}