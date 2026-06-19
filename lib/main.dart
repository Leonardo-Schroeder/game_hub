// ARQUIVO: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Repositories e BLoCs
import 'src/data/repositories/auth_repository.dart';
import 'src/blocs/auth/auth_bloc.dart';
import 'src/blocs/navigation/navigation_bloc.dart';

// Importações do Catálogo
import 'src/data/repositories/catalog_repository.dart';
import 'src/blocs/catalog/catalog_bloc.dart';

// Telas
import 'src/ui/pages/home/home_screen.dart';

// 👇 ESTA É A FUNÇÃO MAIN QUE O CHROME PRECISA PARA ABRIR O APP 👇
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GameHubApp());
}

class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
        BlocProvider<CatalogBloc>(
          create: (context) => CatalogBloc(repository: CatalogRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'GameHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.purple,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Colors.purpleAccent,
            secondary: Colors.pinkAccent,
          ),
        ),
        // 👇 Agora a Home é o ponto de partida absoluto, sem bloqueios!
        home: const HomeScreen(),
      ),
    );
  }
}