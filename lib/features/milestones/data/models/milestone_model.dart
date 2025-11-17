/// マイルストーン情報を表すモデル
/// milestonesテーブルのデータ構造に対応
class MilestoneModel {
  final String id; // レコードのUUID
  final String userId; // ユーザーID
  final int milestoneDays; // マイルストーンの日数（1日、3日、7日など）
  final DateTime achievedDate; // 達成日
  final DateTime createdAt; // 作成日時

  MilestoneModel({
    required this.id,
    required this.userId,
    required this.milestoneDays,
    required this.achievedDate,
    required this.createdAt,
  });

  /// SupabaseのJSONデータからMilestoneModelを生成
  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      milestoneDays: json['milestone_days'] as int,
      achievedDate: DateTime.parse(json['achieved_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// MilestoneModelをSupabaseのJSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'milestone_days': milestoneDays,
      'achieved_date': _formatDate(achievedDate),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 日付をYYYY-MM-DD形式にフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// マイルストーンの定義
class MilestoneDefinition {
  final int days; // 日数
  final String title; // タイトル
  final String description; // 説明
  final String emoji; // 絵文字

  const MilestoneDefinition({
    required this.days,
    required this.title,
    required this.description,
    required this.emoji,
  });

  /// 定義済みのマイルストーン一覧
  // TODO: 気の利いたコメントに変更
  static const List<MilestoneDefinition> predefined = [
    MilestoneDefinition(
      days: 1,
      title: '1日達成！',
      description: '継続の第一歩を踏み出しました！',
      emoji: '🎉',
    ),
    MilestoneDefinition(
      days: 3,
      title: '3日達成！',
      description: '3日間続けることができました！',
      emoji: '🌟',
    ),
    MilestoneDefinition(
      days: 7,
      title: '1週間達成！',
      description: '1週間の継続、素晴らしいです！',
      emoji: '🏆',
    ),
    MilestoneDefinition(
      days: 30,
      title: '1ヶ月達成！',
      description: '1ヶ月間の継続、本当におめでとうございます！',
      emoji: '🎊',
    ),
    MilestoneDefinition(
      days: 100,
      title: '100日達成！',
      description: '100日間の継続、素晴らしい成果です！',
      emoji: '💎',
    ),
    MilestoneDefinition(
      days: 365,
      title: '1年達成！',
      description: '1年間の継続、本当に素晴らしいです！',
      emoji: '👑',
    ),
  ];

  /// 日数からマイルストーン定義を取得
  static MilestoneDefinition? getByDays(int days) {
    try {
      return predefined.firstWhere((m) => m.days == days);
    } catch (e) {
      return null;
    }
  }
}
