import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_post_model.freezed.dart';
part 'timeline_post_model.g.dart';

@freezed
class TimelinePost with _$TimelinePost {
  const factory TimelinePost({
    required String id, // posts.id
    required String userId, // posts.user_id
    String? userName, // JOINしたユーザー名（users.name）
    required String content, // posts.content
    DateTime? createdAt, // posts.created_at
    String? imageUrl, // posts.image_url または投稿者のアバターURLとして利用
  }) = _TimelinePost;

  factory TimelinePost.fromJson(Map<String, dynamic> json) {
    return TimelinePost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      userName: json['users']?['username'] as String?, // ← ネスト対応
      imageUrl: json['users']?['avatar_url'] as String?, // 投稿者のアバターURL
    );
  }
}
