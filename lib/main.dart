import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'dart:async';

void main() {
  runApp(const MoneyTargetTrackerApp());
}

class MoneyTargetTrackerApp extends StatefulWidget {
  const MoneyTargetTrackerApp({super.key});

  @override
  State<MoneyTargetTrackerApp> createState() => _MoneyTargetTrackerAppState();
}

class _MoneyTargetTrackerAppState extends State<MoneyTargetTrackerApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Target Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: _showSplash ? const SplashScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
