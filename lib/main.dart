import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:otakutn/pages/login_page.dart';
import 'package:otakutn/pages/register_page.dart';
import 'package:otakutn/providers/anime_provider.dart';
import 'package:otakutn/providers/auth_provider.dart';
import 'package:otakutn/services/cloudinary_service.dart';
import 'firebase_options.dart';
import 'package:otakutn/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await CloudinaryService.init();
    runApp(const MyApp());
  } catch (e) {
    print('Firebase initialization error: $e');
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize Firebase'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        initialRoute: '/splash',
        routes: {
          '/': (context) => const LoginPage(),
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
        },
      ),
    );
  }
}