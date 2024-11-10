import 'package:cashguard/constants.dart';
import 'package:cashguard/controllers/application_controller.dart';
import 'package:cashguard/screens/homescreen.dart';
import 'package:cashguard/screens/onboardingscreen.dart';
// import 'package:cashguard/screens/resultscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const CashGuard());
  Get.put(ApplicationController(), permanent: true);
}

class CashGuard extends StatelessWidget {
  const CashGuard({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CashGuard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}
