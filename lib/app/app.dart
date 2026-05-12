import 'package:flutter/material.dart';

class BtgApp extends StatelessWidget {
  const BtgApp({super.key, this.flavorLabel});

  final String? flavorLabel;

  @override
  Widget build(BuildContext context) {
    final title =
        flavorLabel == null ? 'BTG Pactual' : 'BTG Pactual $flavorLabel';
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
