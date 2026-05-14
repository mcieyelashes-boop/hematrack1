import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/camera_capture_service.dart';

class CameraFollowUpScreen extends StatefulWidget {
  const CameraFollowUpScreen({super.key});

  @override
  State<CameraFollowUpScreen> createState() => _CameraFollowUpScreenState();
}

class _CameraFollowUpScreenState extends State<CameraFollowUpScreen> {
  final CameraCaptureService _cameraService = CameraCaptureService();
  bool _loading = true;
  double _overlayOpacity = 0.35;
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
      appBar: AppBar(title: const Text('Follow-up Photo')),
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
          Opacity(
            opacity: _overlayOpacity,
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Baseline Overlay',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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
                  'Samakan posisi dengan baseline. Atur transparansi overlay bila perlu.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 112,
            left: 20,
            right: 20,
            child: Card(
              child: Slider(
                value: _overlayOpacity,
                min: 0.05,
                max: 0.8,
                onChanged: (value) => setState(() => _overlayOpacity = value),
              ),
            ),
          ),
          if (_lastPhotoPath != null)
            Positioned(
              bottom: 176,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Foto follow-up tersimpan: $_lastPhotoPath'),
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _capture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Follow-up'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
