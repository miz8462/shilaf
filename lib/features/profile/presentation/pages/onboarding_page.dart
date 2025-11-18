import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shilaf/core/constants/app_color.dart';
import 'package:shilaf/features/profile/providers/user_provider.dart';
import 'package:shilaf/features/streaks/providers/streak_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _weeklyDrinkingCostController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _weeklyDrinkingCostController.dispose();
    super.dispose();
  }

  /// 日付選択ダイアログを表示
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // 2000年から
      lastDate: DateTime.now(), // 今日まで
      locale: const Locale('ja', 'JP'),
      helpText: '継続開始日を選択',
      cancelText: 'キャンセル',
      confirmText: '決定',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 初期設定を完了（データ保存）
  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. ユーザーデータを作成
      final weeklyCostText = _weeklyDrinkingCostController.text.trim();
      final weeklyCost =
          weeklyCostText.isEmpty ? null : int.tryParse(weeklyCostText);

      await ref.read(userNotifierProvider.notifier).createUser(
            username: _usernameController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            weeklyDrinkingCost: weeklyCost,
          );

      // エラーチェック
      final userState = ref.read(userNotifierProvider);
      if (userState.hasError) {
        throw userState.error!;
      }

      // 2. 継続記録を作成
      await ref.read(streakNotifierProvider.notifier).createInitialStreak(
            sobrietyStartDate: _selectedDate,
          );

      // エラーチェック
      final streakState = ref.read(streakNotifierProvider);
      if (streakState.hasError) {
        throw streakState.error!;
      }

      // 成功メッセージ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('初期設定が完了しました！'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/home');
      }
    } catch (error) {
      // エラー表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ウェルカムメッセージ
                  const Icon(
                    Icons.waving_hand,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Shilafへようこそ！',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'あなたの継続の旅を始めましょう',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // ユーザー名入力
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ユーザー名',
                      hintText: '例: Taro',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'ユーザー名を入力してください';
                      }
                      if (value.trim().length < 2) {
                        return 'ユーザー名は2文字以上で入力してください';
                      }
                      if (value.trim().length > 20) {
                        return 'ユーザー名は20文字以内で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 継続開始日選択
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '継続開始日',
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '※ この日から継続日数がカウントされます',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 自己紹介（任意）
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: '自己紹介（任意）',
                      hintText: '例: 健康的な生活を目指しています',
                      prefixIcon: Icon(Icons.edit),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  const SizedBox(height: 24),

                  // 週あたりの飲酒コスト（任意）
                  TextFormField(
                    controller: _weeklyDrinkingCostController,
                    decoration: const InputDecoration(
                      labelText: '週あたりの飲酒コスト（任意）',
                      hintText: '例: 5000',
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: '円',
                      helperText: '節約額計算に使用されます',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final cost = int.tryParse(value.trim());
                        if (cost == null) {
                          return '数値を入力してください';
                        }
                        if (cost < 0) {
                          return '0以上の数値を入力してください';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '※ 設定すると、継続日数に応じた節約額が表示されます',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 完了ボタン
                  ElevatedButton(
                    onPressed: _isLoading ? null : _completeOnboarding,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '完了',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // 注意事項
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ユーザー名や開始日は後から変更できます',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
