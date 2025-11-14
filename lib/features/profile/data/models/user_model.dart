/// ユーザー情報を表すモデル
/// usersテーブルのデータ構造に対応
class UserModel {
  final String id; // Supabase AuthのUUID
  final String username; // ユーザー名
  final String? bio; // 自己紹介（任意）
  final String? avatarUrl; // プロフィール画像URL（任意）
  final DateTime createdAt; // 登録日時
  final DateTime? updatedAt; // 更新日時

  UserModel({
    required this.id,
    required this.username,
    this.bio,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// SupabaseのJSONデータからUserModelを生成
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// UserModelをSupabaseのJSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'bio': bio,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// コピーを作成（一部のフィールドを更新）
  UserModel copyWith({
    String? id,
    String? username,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}