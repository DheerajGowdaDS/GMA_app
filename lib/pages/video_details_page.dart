import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoDetailsPage extends StatefulWidget {
  final Map<String, dynamic> videoData;

  const VideoDetailsPage({super.key, required this.videoData});

  @override
  State<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  late VideoPlayerController controller;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoData['url']),
    )..initialize().then((_) => setState(() {}));

    chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    chewieController?.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final babyInfo =
        widget.videoData['baby_info'] as Map<String, dynamic>? ?? {};
    final technicalDetails =
        widget.videoData['technical_details'] as Map<String, dynamic>? ?? {};

    final videoTitle = widget.videoData['title'] ?? 'Untitled';
    final status = widget.videoData['status'] ?? 'Unknown';

    final techDetails = {
      ...technicalDetails,
      'Video Title': videoTitle,
      'Status': status,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(videoTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Video Player
              if (controller.value.isInitialized && chewieController != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Chewie(controller: chewieController!),
                  ),
                )
              else
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),

              const SizedBox(height: 24),

              // Baby Info
              sectionHeader("👶 Baby Information", context),
              infoCard(babyInfo, emptyMessage: "No baby information provided"),

              const SizedBox(height: 20),

              // Technical Details
              sectionHeader("🛠️ Technical Details", context),
              infoCard(techDetails, emptyMessage: "No technical details found"),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget infoCard(Map<String, dynamic> data, {required String emptyMessage}) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(emptyMessage),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: data.entries.map((entry) {
          return ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${entry.value}'),
          );
        }).toList(),
      ),
    );
  }
}
