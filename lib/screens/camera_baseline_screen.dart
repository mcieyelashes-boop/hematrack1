import 'package:flutter/material.dart';

class CameraBaselineScreen extends StatelessWidget {
  const CameraBaselineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baseline Photo')),
      body: Stack(
        children: [
          Container(color: Colors.black12),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pinkAccent, width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Capture Baseline'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
