import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:profile_manager_app/firebase_options.dart';
import 'package:profile_manager_app/providers/auth_provider.dart';
import 'package:profile_manager_app/providers/profile_provider.dart';
import 'package:profile_manager_app/utils/theme.dart';
import 'package:profile_manager_app/view/auth_screen.dart';
import 'package:profile_manager_app/view/home_screen.dart';
import 'package:profile_manager_app/view/spalsh_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Profile Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        home: const AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        if (authProvider.user == null) {
          return const AuthScreen();
        }
        return const HomeScreen();
      },
    );
  }
}