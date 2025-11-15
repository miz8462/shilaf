import 'package:intl/intl.dart';

/// 節約額計算のユーティリティ
class SavingsCalculator {
  /// 総節約額を計算
  /// 継続日数 × (週あたりのコスト / 7)
  /// 
  /// [days] 継続日数
  /// [weeklyCost] 週あたりの飲酒コスト（円）
  /// 
  /// 戻り値: 総節約額（円）。weeklyCostがnullまたは0以下の場合は0を返す
  static int calculateTotalSavings({
    required int days,
    int? weeklyCost,
  }) {
    if (weeklyCost == null || weeklyCost <= 0) {
      return 0;
    }
    // 週あたりのコストを1日あたりに変換（週あたりコスト / 7）
    final dailyAmount = weeklyCost / 7;
    // 継続日数 × 1日あたりの節約額
    return (days * dailyAmount).round();
  }

  /// 1日あたりの節約額を計算
  /// 週あたりのコスト / 7
  /// 
  /// [weeklyCost] 週あたりの飲酒コスト（円）
  /// 
  /// 戻り値: 1日あたりの節約額（円）。weeklyCostがnullまたは0以下の場合は0を返す
  static int calculateDailySavings(int? weeklyCost) {
    if (weeklyCost == null || weeklyCost <= 0) {
      return 0;
    }
    return (weeklyCost / 7).round();
  }

  /// 金額をフォーマット（3桁区切り）
  /// 例: 12345 → "12,345円"
  static String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)}円';
  }

  /// 金額をフォーマット（簡易版）
  /// 例: 12345 → "12,345"
  static String formatAmountSimple(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }
}
