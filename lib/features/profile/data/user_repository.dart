import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/user_model.dart';

/// ユーザー情報を管理するリポジトリ
/// usersテーブルとのやり取りを担当
class UsersRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在ログイン中のユーザーIDを取得
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// 自分のユーザーデータを取得
  /// 初期設定が完了しているかの判定にも使用
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // usersテーブルから自分のデータを取得
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle(); // 1件または null を返す

      // データがない場合（初期設定未完了）
      if (response == null) {
        return null;
      }

      // JSONからモデルに変換
      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 初期設定が完了しているかチェック
  /// usersテーブルにデータがあれば完了
  Future<bool> hasCompletedOnboarding() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// 新規ユーザーの初回データを作成
  /// 初期設定画面で呼ばれる
  Future<UserModel> createUser({
    required String username,
    String? bio,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // usersテーブルに新規レコードを挿入
      final data = {
        'id': userId, // Supabase AuthのUUIDを使用
        'username': username,
        'bio': bio,
      };

      final response =
          await _supabase.from('users').insert(data).select().single();

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザー情報を更新
  /// プロフィール編集画面で使用（Phase 3-2）
  Future<UserModel> updateUser({
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 更新するデータを準備（nullでないもののみ）
      final Map<String, dynamic> data = {};
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      // 更新日時を追加
      data['updated_at'] = DateTime.now().toIso8601String();

      // usersテーブルを更新
      final response = await _supabase
          .from('users')
          .update(data)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザー名の重複チェック（オプション機能）
  /// 将来的にユーザー名を一意にしたい場合に使用
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      // データがなければ使用可能
      return response == null;
    } catch (e) {
      return false;
    }
  }
}
