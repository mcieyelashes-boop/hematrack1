import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/follow_up_photo.dart';
import '../services/app_storage.dart';
import '../services/camera_capture_service.dart';
import '../services/hemangioma_repository.dart';

class CameraFollowUpScreen extends StatefulWidget {
  final String areaId;
  const CameraFollowUpScreen({super.key, required this.areaId});

  @override
  State<CameraFollowUpScreen> createState() => _CameraFollowUpScreenState();
}

class _CameraFollowUpScreenState extends State<CameraFollowUpScreen> {
  final _cameraService = CameraCaptureService();
  bool _loading = true;
  bool _saving = false;
  double _overlayOpacity = 0.35;
  String? _capturedPath;
  String? _baselinePath;
  String? _error;
  double _relativeSize = 1.0;

  @override
  void initState() {
    super.initState();
    final area =
        HemangiomaRepository.instance.findAreaById(widget.areaId);
    if (area != null && area.baselinePhotoPath.isNotEmpty) {
      _baselinePath = area.baselinePhotoPath;
    }
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

  Future<void> _promptAndSave() async {
    final picked = await showModalBottomSheet<double>(
      context: context,
      builder: (ctx) => _SizePickerSheet(initial: _relativeSize),
    );
    if (picked == null) return;
    setState(() => _relativeSize = picked);
    await _saveFollowUp();
  }

  Future<void> _saveFollowUp() async {
    final path = _capturedPath;
    if (path == null) return;
    setState(() => _saving = true);
    try {
      final id = const Uuid().v4();
      final saved = await AppStorage.instance.savePhoto(path, 'followup_$id');
      final photo = FollowUpPhoto(
        id: id,
        areaId: widget.areaId,
        photoPath: saved,
        date: DateTime.now(),
        areaRelativeValue: _relativeSize,
      );
      await HemangiomaRepository.instance.addFollowUp(photo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow-up tersimpan')),
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
      appBar: AppBar(title: const Text('Follow-up Photo')),
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
            if (_baselinePath != null &&
                File(_baselinePath!).existsSync())
              Positioned.fill(
                child: Opacity(
                  opacity: _overlayOpacity,
                  child: Image.file(File(_baselinePath!), fit: BoxFit.cover),
                ),
              )
            else
              Opacity(
                opacity: _overlayOpacity,
                child: Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.blueAccent, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Baseline Overlay',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      value: _overlayOpacity,
                      min: 0.05,
                      max: 0.8,
                      onChanged: (v) =>
                          setState(() => _overlayOpacity = v),
                    ),
                  ],
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
            ),
          ] else ...[
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _capturedPath = null),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ulangi'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _promptAndSave,
                      icon: const Icon(Icons.save),
                      label: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
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

class _SizePickerSheet extends StatefulWidget {
  final double initial;
  const _SizePickerSheet({required this.initial});

  @override
  State<_SizePickerSheet> createState() => _SizePickerSheetState();
}

class _SizePickerSheetState extends State<_SizePickerSheet> {
  late double _value;

  static const _options = [
    (label: 'Sangat mengecil (< 50%)', value: 0.5),
    (label: 'Mengecil (50–80%)', value: 0.7),
    (label: 'Hampir sama (80–120%)', value: 1.0),
    (label: 'Membesar (120–150%)', value: 1.3),
    (label: 'Sangat membesar (> 150%)', value: 1.6),
  ];

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ukuran dibandingkan baseline:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._options.map(
            (opt) => RadioListTile<double>(
              title: Text(opt.label),
              value: opt.value,
              groupValue: _value,
              onChanged: (v) => setState(() => _value = v!),
              dense: true,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _value),
              child: const Text('Konfirmasi & Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
