import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/camera_capture_service.dart';

class CameraBaselineScreen extends StatefulWidget {
  const CameraBaselineScreen({super.key});

  @override
  State<CameraBaselineScreen> createState() => _CameraBaselineScreenState();
}

class _CameraBaselineScreenState extends State<CameraBaselineScreen> {
  final CameraCaptureService _cameraService = CameraCaptureService();
  bool _loading = true;
  String? _lastPhotoPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initialize();
    } catch (error) {
      _error = error.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _capture() async {
    try {
      final path = await _cameraService.capturePhoto();
      if (mounted) setState(() => _lastPhotoPath = path);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraService.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Baseline Photo')),
      body: Stack(
        children: [
          Positioned.fill(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : controller != null && controller.value.isInitialized
                        ? CameraPreview(controller)
                        : const Center(child: Text('Kamera tidak tersedia')),
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pinkAccent, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            top: 24,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Posisikan hemangioma di dalam kotak. Foto ini akan menjadi baseline.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (_lastPhotoPath != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Foto tersimpan: $_lastPhotoPath'),
                ),
              ),
            ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _capture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Baseline'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
