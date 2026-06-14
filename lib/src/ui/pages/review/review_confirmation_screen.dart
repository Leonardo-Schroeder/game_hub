import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import '../home/home_screen.dart';

class ReviewConfirmationScreen extends StatelessWidget {
  const ReviewConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o padding superior para ajustar o degradê do fundo
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        width: double.infinity,
        // Mantemos o degradê roxo de fundo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF38006B), Color(0xFF0D0D0D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5], // Aumentei um pouco para preencher melhor
          ),
        ),
        child: Column(
          children: [
            // Espaço exato da barra de status
            SizedBox(height: statusBarHeight + 20),
            
            // --- HEADER DA TELA ---
            const Text(
              'GameHub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            )
            // Animação: Entra esmaecendo e descendo
            .animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 8),
            const Text(
              'Games & RPG Community',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            )
            // Animação: Entra esmaecendo com um pequeno atraso
            .animate().fadeIn(delay: 200.ms, duration: 600.ms),
            
            // Spacer flexível para empurrar o card para o centro
            const Spacer(flex: 2),

            // --- CARD CENTRAL ANIMADO ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF161618),
                borderRadius: BorderRadius.circular(24),
                // Adicionei uma sombra neon bem sutil roxa atrás do card
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9D00FF).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ocupa apenas o tamanho necessário
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  
                  // Ícone com fundo degradê (O selo de verificado)
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD500F9), Color(0xFFFF1493)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.verified, 
                        color: Colors.white, 
                        size: 80,
                      ),
                    ),
                  )
                  // ANIMAÇÃO DO ÍCONE:
                  .animate(delay: 400.ms) // Começa depois do header
                  .fadeIn(duration: 400.ms) // Esmaece
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 800.ms) // Aumenta de tamanho com efeito elástico
                  .shimmer(delay: 1200.ms, duration: 1000.ms, color: Colors.white24), // Dá um brilho extra depois de entrar
                  
                  const SizedBox(height: 40),
                  
                  // Texto de Sucesso
                  const Text(
                    'Resenha salva\ncom sucesso!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Aumentei um pouco o tamanho
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  )
                  // ANIMAÇÃO DO TEXTO: Entra subindo devagar
                  .animate(delay: 800.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 60),
                  
                  // Botão "Voltar" com degradê
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9D00FF), Color(0xFFE100FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      // Sombra neon rosa atrás do botão
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE100FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Voltar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  // ANIMAÇÃO DO BOTÃO: Entra por último, subindo
                  .animate(delay: 1000.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 16),
                ],
              ),
            )
            // ANIMAÇÃO DO CARD INTEIRO: Ele surge e dá uma leve "quicada"
            .animate(delay: 300.ms).fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack, duration: 600.ms),
            
            // Spacer flexível inferior (menor que o superior para centralizar melhor visualmente)
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}