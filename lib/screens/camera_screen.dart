import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  bool lightingOk = false;
  bool bboxOk = false;
  bool framePassed = false;
  bool isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium,
        enableAudio: false);
    await _controller!.initialize();

    if (mounted) setState(() {});
  }

  Future<void> _startRecording() async {
    if (!_controller!.value.isStreamingImages) {
      setState(() {
        _isRecording = true;
        isStreaming = true;
      });

      _controller!.startImageStream((CameraImage image) async {
        if (!mounted || !_isRecording) return;
        await Future.delayed(const Duration(seconds: 1));
        final jpeg = await _convertToJpeg(image);
        if (jpeg.isNotEmpty) {
          await sendFrame(jpeg);
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      isStreaming = false;
    });

    try {
      await _controller!.stopImageStream();
    } catch (_) {
      print("Stream already stopped.");
    }
  }

  Future<void> sendFrame(Uint8List frameBytes) async {
    final uri = Uri.parse('http://192.168.0.70:5000/analyze-frame');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('frame', frameBytes,
          filename: 'frame.jpg'));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        lightingOk = jsonResponse['lighting_ok'] ?? false;
        bboxOk = jsonResponse['bbox_in_frame'] ?? false;
        framePassed = jsonResponse['frame_passed'] ?? false;
      });
    } else {
      print("Frame failed: ${response.body}");
    }
  }

  // Converts CameraImage in YUV format to JPEG
  Future<Uint8List> _convertToJpeg(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;
      final yPlane = image.planes[0];
      final uvRowStride = image.planes[1].bytesPerRow;
      final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      final imgRgb = img.Image(width: width, height: height);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
          final int yp = yPlane.bytes[y * yPlane.bytesPerRow + x];
          final int up = image.planes[1].bytes[uvIndex];
          final int vp = image.planes[2].bytes[uvIndex];

          int r = (yp + 1.370705 * (vp - 128)).round();
          int g = (yp - 0.337633 * (up - 128) - 0.698001 * (vp - 128)).round();
          int b = (yp + 1.732446 * (up - 128)).round();

          imgRgb.setPixelRgb(
              x, y, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
        }
      }

      return Uint8List.fromList(img.encodeJpg(imgRgb));
    } catch (e) {
      print("JPEG conversion error: $e");
      return Uint8List(0);
    }
  }

  Widget _buildStatusIcon(bool status, String label) {
    return Row(
      children: [
        Icon(status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Baby Movement Check')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusIcon(lightingOk, 'Lighting'),
              _buildStatusIcon(bboxOk, 'B-Box'),
              _buildStatusIcon(framePassed, 'Passed'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            child: Text(_isRecording ? 'Stop' : 'Start'),
          ),
        ],
      ),
    );
  }
}
