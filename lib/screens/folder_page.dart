import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'video_provider.dart';
import '../models/video_model.dart';
import 'approved_video_detail_page.dart';
import 'flagged_video_detail_page.dart';
import 'pending_video_detail_page.dart';

class FolderPage extends StatelessWidget {
  final String folderName;

  const FolderPage({super.key, required this.folderName});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VideoProvider>(context);

    List<Video> videos;
    Widget Function(Video) detailPage;

    switch (folderName) {
      case 'Approved':
        videos = provider.approvedVideos;
        detailPage = (video) => ApprovedVideoDetailPage(video: video);
        break;
      case 'Flagged':
        videos = provider.flaggedVideos;
        detailPage = (video) => FlaggedVideoDetailPage(video: video);
        break;
      case 'Pending':
      default:
        videos = provider.pendingVideos;
        detailPage = (video) => PendingVideoDetailPage(video: video);
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text('$folderName Videos')),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            title: Text("Patient ${video.babyId}"),
            subtitle: Text("Weeks: ${video.ageWeeks}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => detailPage(video)),
              );
            },
          );
        },
      ),
    );
  }
}
