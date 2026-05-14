import 'package:camera/camera.dart';

class CameraCaptureService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('Tidak ada kamera tersedia');
    }

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  Future<String> capturePhoto() async {
    final activeController = _controller;
    if (activeController == null || !activeController.value.isInitialized) {
      throw StateError('Kamera belum siap');
    }

    final file = await activeController.takePicture();
    return file.path;
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
