import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/streak_model.dart';

/// 継続日数を管理するリポジトリ
/// streaksテーブルとのやり取りを担当
class StreaksRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在ログイン中のユーザーIDを取得
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// 日付を00:00:00に正規化
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 指定された開始日から今日までの日数を計算
  int _calculateStreakDays(DateTime startDate) {
    final today = _normalizeDate(DateTime.now());
    final normalizedStart = _normalizeDate(startDate);
    return today.difference(normalizedStart).inDays + 1;
  }

  /// 自分の現在の継続記録を取得
  Future<StreakModel?> getCurrentStreak() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // streaksテーブルから自分のデータを取得
      final response = await _supabase
          .from('streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return StreakModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 初回の継続記録を作成
  /// 初期設定画面で呼ばれる
  Future<StreakModel> createInitialStreak({
    required DateTime sobrietyStartDate,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 開始日からの経過日数を計算（正規化した日付を使用）
      final normalizedDate = _normalizeDate(sobrietyStartDate);
      final daysSinceStart = _calculateStreakDays(normalizedDate);

      // streaksテーブルに新規レコードを挿入
      final data = {
        'user_id': userId,
        'sobriety_start_date': normalizedDate.toIso8601String(),
        'current_streak_days': daysSinceStart,
        'total_resets': 0,
      };

      final response =
          await _supabase.from('streaks').insert(data).select().single();

      return StreakModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 継続日数を更新（再計算）
  /// 開始日は変更せず、経過日数だけ更新
  Future<StreakModel> updateStreakDays() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 現在の継続記録を取得
      final currentStreak = await getCurrentStreak();
      if (currentStreak == null) {
        throw Exception('Streak not found');
      }

      // 最新の経過日数を計算
      final updatedDays = _calculateStreakDays(currentStreak.sobrietyStartDate);

      // streaksテーブルを更新
      final data = {
        'current_streak_days': updatedDays,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('streaks')
          .update(data)
          .eq('user_id', userId)
          .select()
          .single();

      return StreakModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 継続開始日を変更
  /// プロフィール編集などで使用
  Future<StreakModel> updateStartDate(DateTime newStartDate) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 新しい開始日からの経過日数を計算
      final normalizedDate = _normalizeDate(newStartDate);
      final daysSinceStart = _calculateStreakDays(normalizedDate);

      // streaksテーブルを更新
      final data = {
        'sobriety_start_date': normalizedDate.toIso8601String(),
        'current_streak_days': daysSinceStart,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('streaks')
          .update(data)
          .eq('user_id', userId)
          .select()
          .single();

      return StreakModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 継続記録をリセット
  /// 新しい開始日を設定してリセット回数を+1
  Future<StreakModel> resetStreak(DateTime newStartDate) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 現在の継続記録を取得
      final currentStreak = await getCurrentStreak();
      if (currentStreak == null) {
        throw Exception('Streak not found');
      }

      // 新しい開始日からの経過日数を計算
      final normalizedDate = _normalizeDate(newStartDate);
      final daysSinceStart = _calculateStreakDays(normalizedDate);

      // リセット回数を増やす
      final newResetCount = currentStreak.totalResets + 1;

      // streaksテーブルを更新
      final data = {
        'sobriety_start_date': normalizedDate.toIso8601String(),
        'current_streak_days': daysSinceStart,
        'total_resets': newResetCount,
        'last_achievement_date': null, // リセット
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('streaks')
          .update(data)
          .eq('user_id', userId)
          .select()
          .single();

      return StreakModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 最後の達成日を更新
  /// 達成記録作成時に呼ばれる
  Future<StreakModel> updateLastAchievementDate(
      DateTime achievementDate) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // streaksテーブルを更新
      final data = {
        'last_achievement_date': achievementDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('streaks')
          .update(data)
          .eq('user_id', userId)
          .select()
          .single();

      return StreakModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 開始日からの経過日数を計算（ヘルパーメソッド）
  int calculateDaysFromDate(DateTime startDate) {
    return _calculateStreakDays(startDate);
  }
}
