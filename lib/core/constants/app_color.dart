import 'package:flutter/material.dart';

/// Shilafのカラーパレット
/// アプリ全体で使用する色を定義
class AppColors {
  // プライマリカラー（メイン色）- 空色・水色
  static const Color primary = Color(0xFF4FC3F7); // 空色
  static const Color primaryLight = Color(0xFF80D8FF); // 薄い空色
  static const Color primaryDark = Color(0xFF0091EA); // 濃い空色

  // セカンダリカラー（アクセント色）
  static const Color secondary = Color(0xFF81C784); // 爽やかな緑
  static const Color secondaryLight = Color(0xFFA5D6A7);
  static const Color secondaryDark = Color(0xFF4CAF50);

  // 背景色
  static const Color background = Color(0xFFF8F9FA); // 明るいグレー
  static const Color surface = Colors.white; // カード・コンテナ背景
  static const Color surfaceDark = Color(0xFF1E1E1E); // ダークモード用

  // テキストカラー
  static const Color textPrimary = Color(0xFF212529); // 濃いグレー
  static const Color textSecondary = Color(0xFF6C757D); // グレー
  static const Color textDisabled = Color(0xFFADB5BD); // 薄いグレー
  static const Color textOnPrimary = Colors.white; // プライマリカラー上のテキスト

  // ステータスカラー
  static const Color success = Color(0xFF28A745); // 緑（成功・達成）
  static const Color error = Color(0xFFDC3545); // 赤（エラー）
  static const Color warning = Color(0xFFFFC107); // 黄色（警告）
  static const Color info = Color(0xFF17A2B8); // 青（情報）

  // ボーダー・区切り線
  static const Color divider = Color(0xFFE9ECEF);
  static const Color border = Color(0xFFDEE2E6);

  // その他
  static const Color shadow = Color(0x1A000000); // 影（透明度10%）
  static const Color overlay = Color(0x80000000); // オーバーレイ（透明度50%）

  // グラデーション
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [success, Color(0xFF32CD32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}