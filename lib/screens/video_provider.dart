import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class VideoProvider with ChangeNotifier {
  final String apiUrl = 'http://10.0.2.2:3000/api/videos'; // Use 10.0.2.2 for Android Emulator

  List<Video> _pendingVideos = [];
  List<Video> _approvedVideos = [];
  List<Video> _flaggedVideos = [];

  List<Video> get pendingVideos => List.unmodifiable(_pendingVideos);
  List<Video> get approvedVideos => List.unmodifiable(_approvedVideos);
  List<Video> get flaggedVideos => List.unmodifiable(_flaggedVideos);

  VideoProvider() {
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> videoJson = json.decode(response.body);

        // Reset lists
        _pendingVideos = [];
        _approvedVideos = [];
        _flaggedVideos = [];

        for (var jsonVideo in videoJson) {
          final video = Video.fromJson(jsonVideo);
          switch (video.status.toLowerCase()) {
            case 'pending':
              _pendingVideos.add(video);
              break;
            case 'approved':
              _approvedVideos.add(video);
              break;
            case 'flagged':
              _flaggedVideos.add(video);
              break;
          }
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      print('Error fetching videos: $e');

      // Fallback to a local demo video
      _pendingVideos = [
        Video(
          id: 'demo1',
          babyId: 'Demo123',
          ageWeeks: 35,
          videoUrl: 'http://192.168.163.50:3000/demo.mp4', // Replace with your accessible local IP/asset
          dateUploaded: DateTime.now(),
          status: 'Pending',
          comments: [
            VideoComment(
              text: 'This is a demo comment.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
          ],
        ),
      ];

      notifyListeners();
    }
  }

  Future<void> updateStatus(Video video, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${video.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        await fetchVideos(); // Refresh list
      } else {
        print('Failed to update video status');
      }
    } catch (e) {
      print('Error updating video status: $e');
    }
  }

  Future<void> approveVideo(Video video) async {
    await updateStatus(video, 'Approved');
  }

  Future<void> flagVideo(Video video) async {
    await updateStatus(video, 'Flagged');
  }

  Future<void> undoApprove(Video video) async {
    await updateStatus(video, 'Pending');
  }

  Future<void> undoFlag(Video video) async {
    await updateStatus(video, 'Pending');
  }
}
