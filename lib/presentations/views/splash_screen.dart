import 'package:edusurvey/core/theme/colors.dart';
import 'package:edusurvey/core/theme/text_styles.dart';
import 'package:edusurvey/presentations/views/login_screen.dart';
import 'package:edusurvey/presentations/views/home_screen.dart';
import 'package:edusurvey/presentations/views/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  /// Check user authentication status
  Future<void> checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isRegistered = prefs.getBool('isRegistered') ?? false;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 3)); // Simulate splash delay

    if (isRegistered) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AllColors.primaryColor,
              AllColors.gradientSecond,
              AllColors.gradientThird,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, color: AllColors.textColor, size: 80),
              Text('Edu Survey', style: TextStyles.titleText),
            ],
          ),
        ),
      ),
    );
  }
}
