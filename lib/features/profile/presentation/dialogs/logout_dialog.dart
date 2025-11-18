import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ログアウト確認ダイアログを表示
void showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('ログアウト'),
      content: const Text('ログアウトしますか？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            // TODO: ログアウト処理を実装
            // 例: ref.read(authProvider.notifier).logout();
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ログアウトしました')),
            );
          },
          child: const Text(
            'ログアウト',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
