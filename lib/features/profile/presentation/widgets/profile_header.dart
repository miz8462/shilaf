import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final dynamic user; // 実際の型に合わせて変更してください

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // アバター
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            user?.username?.isNotEmpty == true
                ? user!.username![0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ユーザー名
        Text(
          user?.username ?? '名前が未設定です',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
