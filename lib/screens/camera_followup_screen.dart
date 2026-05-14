import 'package:flutter/material.dart';

class CameraFollowUpScreen extends StatelessWidget {
  const CameraFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow-up Photo')),
      body: Stack(
        children: [
          Container(color: Colors.black12),
          Opacity(
            opacity: 0.3,
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Slider(
              value: 0.3,
              onChanged: (_) {},
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Capture Follow-up'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
