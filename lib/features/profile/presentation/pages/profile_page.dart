import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/features/profile/presentation/widgets/profile_bottom_actions.dart';
import 'package:shilaf/features/profile/presentation/widgets/profile_header.dart';
import 'package:shilaf/features/profile/presentation/widgets/profile_menu_list.dart';
import 'package:shilaf/features/profile/providers/user_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: userDataAsync.when(
        data: (user) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    ProfileHeader(user: user),
                    const SizedBox(height: 32),
                    ProfileMenuList(user: user),
                  ],
                ),
              ),
            ),
            ProfileBottomActions(user: user),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('エラー: $err'),
        ),
      ),
    );
  }
}
