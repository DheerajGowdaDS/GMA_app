import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import 'video_provider.dart';


class PendingVideoDetailPage extends StatefulWidget {
  final Video video;

  const PendingVideoDetailPage({required this.video, super.key});

  @override
  State<PendingVideoDetailPage> createState() => _PendingVideoDetailPageState();
}

class _PendingVideoDetailPageState extends State<PendingVideoDetailPage> {
  late List<VideoComment> comments;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    comments = widget.video.comments;
  }

  void _addComment(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      comments.insert(0, VideoComment(
        text: text.trim(),
        timestamp: DateTime.now(),
      ));
    });
    _commentController.clear();
  }

  void _editComment(int index) async {
    final controller = TextEditingController(text: comments[index].text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Comment"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: "Comment"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        comments[index] = VideoComment(
          text: result,
          timestamp: DateTime.now(),
        );
      });
    }
  }

  void _deleteComment(int index) {
    setState(() => comments.removeAt(index));
  }

  void _approveVideo() {
    Provider.of<VideoProvider>(context, listen: false).approveVideo(widget.video);
    Navigator.pop(context);
  }

  void _flagVideo() {
    Provider.of<VideoProvider>(context, listen: false).flagVideo(widget.video);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Video Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Placeholder(fallbackHeight: 200),
                    const SizedBox(height: 20),
                    Text("👶 Baby ID: ${video.babyId}", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("📅 Age: ${video.ageWeeks} weeks", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("🕒 Uploaded: ${video.dateUploaded}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const Text("💬 Comments",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      height: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: comments.isEmpty
                          ? const Center(child: Text("No comments yet"))
                          : ListView.separated(
                        reverse: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            title: Text(comment.text),
                            subtitle: Text(
                              "🕓 ${comment.timestamp.toLocal()}".split('.')[0],
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editComment(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteComment(index),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: "Add a comment",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) => _addComment(value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _addComment(_commentController.text),
                          child: const Text("Send"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _approveVideo,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _flagVideo,
                  icon: const Icon(Icons.flag),
                  label: const Text('Flag'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
