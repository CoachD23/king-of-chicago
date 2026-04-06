import 'package:flutter/material.dart';

class KingOfChicagoApp extends StatelessWidget {
  const KingOfChicagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'King of Chicago',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'King of Chicago',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
