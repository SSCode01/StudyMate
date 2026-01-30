import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: const Color(0xFF4A2E1B),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bghp.png", fit: BoxFit.cover),
          ),
          const Center(
            child: Text(
              "Coming soon",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
