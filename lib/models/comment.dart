class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userAvatar: json['userAvatar'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
    };
  }

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? text,
    DateTime? timestamp,
    int? likes,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}