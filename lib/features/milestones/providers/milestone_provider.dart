import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/features/milestones/data/milestones_repository.dart';
import 'package:shilaf/features/milestones/data/models/milestone_model.dart';
import 'package:shilaf/features/streaks/data/streaks_repository.dart';
import 'package:shilaf/features/streaks/providers/streak_provider.dart';

/// マイルストーンリポジトリのプロバイダー
final milestonesRepositoryProvider = Provider<MilestonesRepository>((ref) {
  return MilestonesRepository();
});

/// 達成済みのマイルストーン一覧を取得するプロバイダー
final achievedMilestonesProvider =
    FutureProvider<List<MilestoneModel>>((ref) async {
  final repository = ref.watch(milestonesRepositoryProvider);
  return await repository.getAchievedMilestones();
});

/// マイルストーンの達成チェックと記録を管理するプロバイダー
final milestoneNotifierProvider =
    AsyncNotifierProvider<MilestoneNotifier, MilestoneModel?>(
        MilestoneNotifier.new);

/// マイルストーンの達成チェックと記録を実行するNotifier
class MilestoneNotifier extends AsyncNotifier<MilestoneModel?> {
  late final MilestonesRepository _repository;
  late final StreaksRepository _streakRepository;

  @override
  FutureOr<MilestoneModel?> build() {
    _repository = ref.watch(milestonesRepositoryProvider);
    _streakRepository = ref.watch(streakRepositoryProvider);
    return null; // 初期値
  }

  /// 現在の継続日数に基づいて達成したマイルストーンをチェック
  /// 達成したマイルストーンがあれば最新のものだけを返す（なければnull）
  /// 例：5日目にログインした場合、1日達成と3日達成の両方が達成されるが、3日達成だけを返す
  Future<MilestoneModel?> checkAndRecordMilestones() async {
    try {
      // 現在の継続記録を取得
      final currentStreak = await _streakRepository.getCurrentStreak();
      if (currentStreak == null) return null;

      // 継続日数を計算（初日=1日目）
      final days = currentStreak.calculateDaysFromStart() + 1;

      // 達成されたマイルストーンを記録するリスト
      final List<MilestoneModel> achievedMilestones = [];

      // 定義済みのマイルストーンをチェック（大きい日数から順に）
      // 降順にソートして、最新のマイルストーンを優先的に取得
      final sortedMilestones = List<MilestoneDefinition>.from(
        MilestoneDefinition.predefined,
      )..sort((a, b) => b.days.compareTo(a.days));

      for (final milestoneDef in sortedMilestones) {
        // N日目が終わった後（N+1日目）になってから達成とする
        // 例：3日達成は4日目になってから表示
        if (days > milestoneDef.days) {
          // 既に達成済みかチェック
          final alreadyAchieved =
              await _repository.hasAchievedMilestone(milestoneDef.days);
          if (!alreadyAchieved) {
            // 達成として記録
            final today = DateTime.now();
            final milestone = await _repository.achieveMilestone(
              milestoneDays: milestoneDef.days,
              achievedDate: today,
            );
            achievedMilestones.add(milestone);
          }
        }
      }

      // プロバイダーを再取得（達成があった場合のみ）
      if (achievedMilestones.isNotEmpty) {
        ref.invalidate(achievedMilestonesProvider);
        // 最新のマイルストーン（最大の日数）だけを返す
        achievedMilestones
            .sort((a, b) => b.milestoneDays.compareTo(a.milestoneDays));
        return achievedMilestones.first;
      }

      return null;
    } catch (e) {
      // エラーは無視（ログ出力などは必要に応じて）
      return null;
    }
  }
}
