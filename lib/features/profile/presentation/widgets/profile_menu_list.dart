// lib/features/profile/presentation/widgets/profile_menu_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shilaf/features/profile/presentation/widgets/profile_menu_item.dart';

class ProfileMenuList extends ConsumerWidget {
  final dynamic user; // 実際の型に合わせて変更してください

  const ProfileMenuList({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.edit,
          title: 'プロフィールを編集',
          onTap: () {
            context.push('/profile/edit', extra: user);
          },
        ),
        const Divider(height: 1),
        ProfileMenuItem(
          icon: Icons.notifications_outlined,
          title: '通知設定',
          onTap: () {
            // TODO: 通知設定画面へ遷移
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('通知設定画面（未実装）')),
            );
          },
        ),
      ],
    );
  }
}
