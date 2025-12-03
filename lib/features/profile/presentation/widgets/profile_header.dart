import 'package:flutter/material.dart';
import 'package:shilaf/features/profile/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel? user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // アバター
        if (user?.avatarUrl != null)
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: NetworkImage(user!.avatarUrl!),
          )
        else
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              (user?.username.isNotEmpty ?? false)
                  ? user!.username[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        const SizedBox(height: 16),
        // ユーザー名
        Text(
          user?.username ?? '名前が未設定です',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
