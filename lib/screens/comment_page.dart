import 'package:flutter/material.dart';

class CommentPage extends StatelessWidget {
  final String videoId;

  CommentPage({required this.videoId});

  final List<Map<String, dynamic>> comments = [
    {'text': "Review needed.", 'likes': 4, 'replies': ['Sure']},
    {'text': "Looks fine", 'likes': 2, 'replies': []},
  ];

  @override
  Widget build(BuildContext context) {
    // Sort comments by likes
    comments.sort((a, b) => (b['likes'] as int).compareTo(a['likes'] as int));

    return Scaffold(
      appBar: AppBar(title: Text("Comments for Video: $videoId")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          final replies = comment['replies'] as List<dynamic>? ?? [];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment['text'] ?? '', style: const TextStyle(fontSize: 16)),
                  if (replies.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text("Replies:", style: TextStyle(color: Colors.grey[600])),
                    ...replies.map((r) => Padding(
                      padding: const EdgeInsets.only(left: 12, top: 2),
                      child: Text("↪ $r"),
                    )),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {},
                      ),
                      const Spacer(),
                      Text("★ ${comment['likes'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
