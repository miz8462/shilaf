import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shilaf/features/profile/data/avatar_service.dart';
import 'package:shilaf/features/profile/data/models/user_model.dart';

/// ユーザー情報（usersテーブル）を扱うリポジトリ
class UsersRepository {
  final SupabaseClient _supabase;
  final AvatarService _avatarService;

  UsersRepository({
    SupabaseClient? supabaseClient,
    AvatarService? avatarService,
  })  : _supabase = supabaseClient ?? Supabase.instance.client,
        _avatarService = avatarService ?? AvatarService();

  /// 現在ログイン中のユーザー情報を取得
  Future<UserModel?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  /// 初期設定が完了しているかどうか
  /// → users テーブルにレコードがあれば true とみなす
  Future<bool> hasCompletedOnboarding() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// 新規ユーザー作成（初期設定時）
  Future<UserModel> createUser({
    required String username,
    String? bio,
    int? weeklyDrinkingCost,
  }) async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    final insertData = <String, dynamic>{
      'id': authUser.id,
      'username': username,
      'bio': bio,
      'avatar_url': null,
      'weekly_drinking_cost': weeklyDrinkingCost,
      'created_at': now,
      'updated_at': null,
    };

    final data = await _supabase
        .from('users')
        .insert(insertData)
        .select()
        .single();

    return UserModel.fromJson(data);
  }

  /// プロフィール更新（ユーザー名 / 自己紹介 / アバターURL / 週あたり飲酒コスト）
  Future<UserModel> updateUser({
    String? username,
    String? bio,
    String? avatarUrl,
    int? weeklyDrinkingCost,
  }) async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('User not authenticated');
    }

    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (username != null) updateData['username'] = username;
    if (bio != null) updateData['bio'] = bio;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
    if (weeklyDrinkingCost != null) {
      updateData['weekly_drinking_cost'] = weeklyDrinkingCost;
    }

    final data = await _supabase
        .from('users')
        .update(updateData)
        .eq('id', authUser.id)
        .select()
        .single();

    return UserModel.fromJson(data);
  }

  /// ユーザー名の重複チェック
  Future<bool> isUsernameAvailable(String username) async {
    final authUser = _supabase.auth.currentUser;
    final currentId = authUser?.id;

    final List<dynamic> rows = await _supabase
        .from('users')
        .select('id')
        .eq('username', username);

    if (rows.isEmpty) {
      // 誰も使っていない
      return true;
    }

    // すでに1件以上ある場合、自分のIDのものだけなら OK
    if (currentId == null) return false;
    return rows.every((row) => row['id'] == currentId);
  }

  /// モバイル用: File からアバター画像をアップロードして URL を返す
  Future<String> uploadAvatar(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;

    final result = ImagePickerResult(
      file: imageFile,
      fileName: fileName,
    );

    return _avatarService.uploadAvatar(result);
  }

  /// Web 用: バイト列とファイル名からアバター画像をアップロードして URL を返す
  Future<String> uploadAvatarFromBytes(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final result = ImagePickerResult(
      bytes: imageBytes,
      fileName: fileName,
    );

    return _avatarService.uploadAvatar(result);
  }
}


