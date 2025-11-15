import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/daily_achievement_model.dart';

/// 達成記録を管理するリポジトリ
/// daily_achievementsテーブルとのやり取りを担当
class DailyAchievementRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在ログイン中のユーザーIDを取得
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// 今日の達成記録を取得
  /// 今日の日付で達成記録があるかチェック
  Future<DailyAchievement?> getTodayAchievement() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 今日の日付をYYYY-MM-DD形式で取得
      final today = DateTime.now();
      final todayStr = _formatDate(today);

      // daily_achievementsテーブルから今日の記録を取得
      final response = await _supabase
          .from('daily_achievements')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DailyAchievement.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 今日の達成記録を作成
  /// 1日1回の制限は呼び出し側でチェック
  /// streakIdは必須パラメータとして受け取る
  Future<DailyAchievement> createTodayAchievement({
    required String streakId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 今日の日付をYYYY-MM-DD形式で取得
      final today = DateTime.now();
      final todayStr = _formatDate(today);

      // daily_achievementsテーブルに新規レコードを挿入
      final data = {
        'user_id': userId,
        'streak_id': streakId,
        'date': todayStr,
      };

      final response = await _supabase
          .from('daily_achievements')
          .insert(data)
          .select()
          .single();

      return DailyAchievement.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 今日の達成記録が既に存在するかチェック
  /// 1日1回の制限チェックに使用
  Future<bool> hasTodayAchievement() async {
    try {
      final achievement = await getTodayAchievement();
      return achievement != null;
    } catch (e) {
      return false;
    }
  }

  /// 指定した日付の達成記録を取得
  /// カレンダー表示などで使用（Phase 4-2以降）
  Future<DailyAchievement?> getAchievementByDate(DateTime date) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final dateStr = _formatDate(date);

      final response = await _supabase
          .from('daily_achievements')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DailyAchievement.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 日付をYYYY-MM-DD形式にフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
