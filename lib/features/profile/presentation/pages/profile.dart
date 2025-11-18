import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: Center(
        child: userDataAsync.when(
          data: (user) => Text(
            user?.username ?? '名前が未設定です',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('エラー: $err'),
        ),
      ),
    );
  }
}
