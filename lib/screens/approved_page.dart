import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import 'approved_video_detail_page.dart';
import 'video_provider.dart';

class ApprovedPage extends StatelessWidget {
  final List<Video>? videos;

  const ApprovedPage({this.videos, super.key});

  @override
  Widget build(BuildContext context) {
    final approvedVideos = videos ?? Provider.of<VideoProvider>(context).approvedVideos;

    return Scaffold(
      appBar: AppBar(title: const Text('Approved Videos')),
      body: approvedVideos.isEmpty
          ? const Center(child: Text("No approved videos."))
          : ListView.builder(
        itemCount: approvedVideos.length,
        itemBuilder: (context, index) {
          final video = approvedVideos[index];
          return ListTile(
            title: Text("Patient ${video.babyId}"),
            subtitle: Text("Weeks: ${video.ageWeeks}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApprovedVideoDetailPage(video: video),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
