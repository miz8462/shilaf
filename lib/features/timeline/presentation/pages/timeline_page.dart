import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shilaf/features/timeline/providers/timeline_provider.dart';

class TimelinePage extends ConsumerWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(timelineProvider);
    final controller = TextEditingController();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('タイムライン')),
      body: Column(
        children: [
          // 投稿一覧
          Expanded(
            child: postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'まだ投稿はありません',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    // 「今日の達成」由来の投稿かどうかをメッセージパターンで判定
                    final isAchievementPost =
                        post.content.contains('日達成しました！🎉');

                    // 達成投稿はカードで強調表示
                    if (isAchievementPost) {
                      return Card(
                        color: Colors.amber[50],
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: post.imageUrl != null
                              ? CircleAvatar(
                                  radius: 22,
                                  backgroundImage: NetworkImage(post.imageUrl!),
                                )
                              : const CircleAvatar(
                                  radius: 22,
                                  child: Icon(Icons.emoji_events),
                                ),
                          title: Text(
                            post.content,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${post.userName} - ${formatter.format(post.createdAt!)}',
                          ),
                          trailing: const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                          ),
                        ),
                      );
                    }

                    // 通常投稿は従来どおり
                    return ListTile(
                      // 投稿者のプロフィール画像（アバター）を表示
                      leading: post.imageUrl != null
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(post.imageUrl!),
                            )
                          : const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person),
                            ),
                      title: Text(post.content),
                      subtitle: Text(
                        '${post.userName} - ${formatter.format(post.createdAt!)}',
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('エラー: $err')),
            ),
          ),
          const Divider(),

          // 投稿フォーム
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: '投稿を入力してください',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      await ref.read(timelineProvider.notifier).addPost(text);
                      controller.clear();
                    }
                  },
                  child: const Text('投稿'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
