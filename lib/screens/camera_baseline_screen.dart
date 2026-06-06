import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/app_storage.dart';
import '../services/camera_capture_service.dart';
import '../services/hemangioma_repository.dart';

class CameraBaselineScreen extends StatefulWidget {
  final String areaId;
  const CameraBaselineScreen({super.key, required this.areaId});

  @override
  State<CameraBaselineScreen> createState() => _CameraBaselineScreenState();
}

class _CameraBaselineScreenState extends State<CameraBaselineScreen> {
  final _cameraService = CameraCaptureService();
  bool _loading = true;
  bool _saving = false;
  String? _capturedPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initialize();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _capture() async {
    try {
      final path = await _cameraService.capturePhoto();
      if (mounted) setState(() => _capturedPath = path);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _saveBaseline() async {
    final path = _capturedPath;
    if (path == null) return;
    setState(() => _saving = true);
    try {
      final saved =
          await AppStorage.instance.savePhoto(path, 'baseline_${widget.areaId}');
      await HemangiomaRepository.instance
          .updateAreaBaseline(widget.areaId, saved);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Baseline tersimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _saving = false);
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
                    : _capturedPath != null
                        ? Image.file(File(_capturedPath!), fit: BoxFit.cover)
                        : controller != null &&
                                controller.value.isInitialized
                            ? CameraPreview(controller)
                            : const Center(
                                child: Text('Kamera tidak tersedia')),
          ),
          if (_capturedPath == null) ...[
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
            ),
          ] else ...[
            const Positioned(
              top: 24,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Foto baseline berhasil diambil. Simpan atau ulangi.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _capturedPath = null),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ulangi'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _saveBaseline,
                      icon: const Icon(Icons.save),
                      label: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
