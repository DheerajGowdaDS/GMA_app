class Video {
  final String id;
  final String babyId;
  final int ageWeeks;
  final DateTime dateUploaded;
  String status;
  final String videoUrl; // renamed from 'url' to 'videoUrl' for clarity
  List<VideoComment> comments;

  Video({
    required this.id,
    required this.babyId,
    required this.ageWeeks,
    required this.dateUploaded,
    required this.status,
    required this.videoUrl,
    List<VideoComment>? comments,
  }) : comments = comments ?? [];

  void addComment(String text) {
    if (text.trim().isEmpty) return;
    comments.insert(
      0,
      VideoComment(text: text.trim(), timestamp: DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'ageWeeks': ageWeeks,
      'dateUploaded': dateUploaded.toIso8601String(),
      'status': status,
      'url': videoUrl,
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      ageWeeks: json['ageWeeks'] as int,
      dateUploaded: DateTime.parse(json['dateUploaded']),
      status: json['status'] as String,
      videoUrl: json['url'] as String, // keeping 'url' in JSON for compatibility
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => VideoComment.fromJson(e))
          .toList() ??
          [],
    );
  }

  Video copyWith({
    String? id,
    String? babyId,
    int? ageWeeks,
    DateTime? dateUploaded,
    String? status,
    String? videoUrl,
    List<VideoComment>? comments,
  }) {
    return Video(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      ageWeeks: ageWeeks ?? this.ageWeeks,
      dateUploaded: dateUploaded ?? this.dateUploaded,
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
      comments: comments ?? this.comments,
    );
  }
}

class VideoComment {
  final String text;
  final DateTime timestamp;

  VideoComment({
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    return VideoComment(
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
