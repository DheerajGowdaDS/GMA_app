import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../screens/approved_video_detail_page.dart';

class VideoTile extends StatelessWidget {
  final Video video;

  VideoTile({required this.video});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Baby ID: \${video.babyId}"),
      subtitle: Text("Age: \${video.ageWeeks} weeks"),
      trailing: Icon(Icons.play_arrow),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ApprovedVideoDetailPage(video: video)),
        );
      },
    );
  }
}
