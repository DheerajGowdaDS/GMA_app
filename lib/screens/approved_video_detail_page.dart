import 'package:flutter/material.dart';
import '../models/video_model.dart';

class ApprovedVideoDetailPage extends StatefulWidget {
  final Video video;

  const ApprovedVideoDetailPage({required this.video, super.key});

  @override
  State<ApprovedVideoDetailPage> createState() => _ApprovedVideoDetailPageState();
}

class _ApprovedVideoDetailPageState extends State<ApprovedVideoDetailPage> {
  late List<VideoComment> comments;
  final TextEditingController _newCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    comments = widget.video.comments;
  }

  void _addNewComment() {
    final text = _newCommentController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        comments.insert(0, VideoComment(
          text: text,
          timestamp: DateTime.now(),
        ));
      });
      _newCommentController.clear();
    }
  }

  void _editComment(int index) async {
    final controller = TextEditingController(text: comments[index].text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Comment"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Comment"),
          autofocus: true,
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

  @override
  void dispose() {
    _newCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Approved Video Detail"),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Replace this Placeholder with your actual video player
            const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 20),
            Text("👶 Baby ID: ${video.babyId}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("📅 Age: ${video.ageWeeks} weeks", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("🕒 Uploaded: ${video.dateUploaded}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Divider(),
            const Text("💬 Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
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
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCommentController,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addNewComment(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNewComment,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
