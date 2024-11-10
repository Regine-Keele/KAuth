import 'package:cashguard/constants.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Container(
          height: size.width * 0.5,
          width: size.width * 0.5,
          child: Image.asset(splashImage),
        ),
      ),
    );
  }
}
