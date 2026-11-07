import 'package:flutter/material.dart';

// Phase 1 only contains the pure Dart engine (lib/core) and data (lib/data).
// The game table UI arrives in Phase 2; this is an empty placeholder app.
void main() {
  runApp(const TengriApp());
}

class TengriApp extends StatelessWidget {
  const TengriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Color(0xFF0E1428)),
    );
  }
}
