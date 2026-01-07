import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:otakutn/onboarding/onboarding_screen.dart';
import 'package:otakutn/pages/login_page.dart' as login_page;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
      
      if (!mounted) return;
      
      if (isFirstTime) {
        
        await prefs.setBool('isFirstTime', false);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
       
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const login_page.LoginPage()),
        );
      }
    } catch (e) {
      // En cas d'erreur, on redirige vers la page de connexion
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const login_page.LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/d05328e1-b580-4f38-9e9d-17cdff583a9c/49ZFXEU3jb.json',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              'OTAKUTN',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your Ultimate Anime Experience',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}