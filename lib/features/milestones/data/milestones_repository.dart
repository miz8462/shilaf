import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/milestone_model.dart';

/// マイルストーンを管理するリポジトリ
/// milestonesテーブルとのやり取りを担当
class MilestonesRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在ログイン中のユーザーIDを取得
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// 指定した日数のマイルストーンが既に達成されているかチェック
  Future<bool> hasAchievedMilestone(int milestoneDays) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('milestones')
          .select('id')
          .eq('user_id', userId)
          .eq('milestone_days', milestoneDays)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// 達成済みのマイルストーン一覧を取得
  Future<List<MilestoneModel>> getAchievedMilestones() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('milestones')
          .select()
          .eq('user_id', userId)
          .order('milestone_days', ascending: true);

      return (response as List)
          .map((json) => MilestoneModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// マイルストーンを達成として記録
  Future<MilestoneModel> achieveMilestone({
    required int milestoneDays,
    required DateTime achievedDate,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 既に達成済みかチェック
      final alreadyAchieved = await hasAchievedMilestone(milestoneDays);
      if (alreadyAchieved) {
        throw Exception('このマイルストーンは既に達成済みです');
      }

      // milestonesテーブルに新規レコードを挿入
      final data = {
        'user_id': userId,
        'milestone_days': milestoneDays,
        'achieved_date': _formatDate(achievedDate),
      };

      final response =
          await _supabase.from('milestones').insert(data).select().single();

      return MilestoneModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザーのすべてのマイルストーンを削除
  /// 継続をリセットした際に使用
  Future<void> deleteAllMilestones() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('milestones').delete().eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// 日付をYYYY-MM-DD形式にフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
