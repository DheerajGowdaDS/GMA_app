import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import 'pending_video_detail_page.dart';
import 'video_provider.dart';

class PendingPage extends StatelessWidget {
  const PendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the provider for changes
    final pendingVideos = Provider.of<VideoProvider>(context).pendingVideos;

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Videos')),
      body: pendingVideos.isEmpty
          ? const Center(child: Text("No pending videos."))
          : ListView.builder(
        itemCount: pendingVideos.length,
        itemBuilder: (context, index) {
          final video = pendingVideos[index];
          return ListTile(
            title: Text("Patient ${video.babyId}"),
            subtitle: Text("Weeks: ${video.ageWeeks}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PendingVideoDetailPage(video: video),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
