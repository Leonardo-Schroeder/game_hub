// src/ui/pages/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_hub/src/blocs/auth/auth_bloc.dart';
import 'package:game_hub/src/blocs/auth/auth_event.dart';
import 'package:game_hub/src/blocs/auth/auth_state.dart';

import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _onRegisterPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Dispara o evento de registro no BLoC
    context.read<AuthBloc>().add(
  RegisterRequestedEvent(
    username: _usernameController.text, // Pega o nome digitado
    email: _emailController.text,
    password: _passwordController.text,
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            // Sucesso! Limpa a pilha e vai pra Home
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          } else if (state is AuthFailureState) {
            // Falha no Firebase (ex: email já existe)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Evita o erro de overflow no teclado
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
                        
                        // ÍCONE E HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD500F9), Color(0xFFFF1493)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.gamepad, size: 24, color: Color(0xFF1E1E1E)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'GameHub',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
                        
                        const SizedBox(height: 32),

                        // CARD CENTRAL DE CADASTRO
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
                                'Junte-se à Guilda!',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Prepare-se para explorar novos mundos, avaliar jogos e conhecer outros jogadores.',
                                style: TextStyle(fontSize: 14, color: Colors.white54, height: 1.4),
                              ),
                              const SizedBox(height: 24),
                              
                              // Campos de Cadastro com os Controllers
                              _buildTextField('Nome de usuário', 'Ex: RPGMaster', Icons.person_outline, _usernameController),
                              const SizedBox(height: 16),
                              _buildTextField('E-mail', 'seu@email.com', Icons.email_outlined, _emailController),
                              const SizedBox(height: 16),
                              _buildTextField('Senha', '••••••••', Icons.lock_outline, _passwordController, isPassword: true),
                              const SizedBox(height: 16),
                              _buildTextField('Confirmar Senha', '••••••••', Icons.lock_outline, _confirmPasswordController, isPassword: true),
                              
                              const SizedBox(height: 32),
                              
                              // Botão Cadastrar
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
                                  onPressed: state is AuthLoadingState ? null : _onRegisterPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: state is AuthLoadingState
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Criar Conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Rodapé para voltar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Já tem uma conta? ', style: TextStyle(color: Colors.white54)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Entrar',
                                      style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
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