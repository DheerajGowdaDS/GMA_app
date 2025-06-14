import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import 'flagged_video_detail_page.dart';
import 'video_provider.dart';

class FlaggedPage extends StatelessWidget {
  final List<Video>? videos;

  const FlaggedPage({this.videos, super.key});

  @override
  Widget build(BuildContext context) {
    final flaggedVideos = videos ?? Provider.of<VideoProvider>(context).flaggedVideos;

    return Scaffold(
      appBar: AppBar(title: const Text('Flagged Videos')),
      body: flaggedVideos.isEmpty
          ? const Center(child: Text("No flagged videos."))
          : ListView.builder(
        itemCount: flaggedVideos.length,
        itemBuilder: (context, index) {
          final video = flaggedVideos[index];
          return ListTile(
            title: Text("Patient ${video.babyId}"),
            subtitle: Text("Weeks: ${video.ageWeeks}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlaggedVideoDetailPage(video: video),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
