class Comment {
  final String uid;
  final String comment;
  final DateTime timestamp;

  Comment({
    required this.uid,
    required this.comment,
    required this.timestamp,
  });

  /// From SQLite Map (timestamp stored as ISO8601 string or integer milliseconds)
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      uid: map['uid'],
      comment: map['comment'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  /// To SQLite Map (store timestamp as ISO8601 string)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
