import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shilaf/features/timeline/providers/timeline_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      await ref.read(timelineProvider.notifier).addPost(text);
      controller.clear();
    }
  }

  Future<void> _deletePost(BuildContext context, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投稿を削除'),
        content: const Text('この投稿を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(timelineProvider.notifier).deletePost(postId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('投稿を削除しました')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  // デスクトップ/キーボード環境かどうかを判定
  bool _isDesktopOrKeyboardEnvironment(BuildContext context) {
    // Webでない場合（ネイティブアプリ）
    if (!kIsWeb) {
      // デスクトッププラットフォームかどうか
      final platform = defaultTargetPlatform;
      return platform == TargetPlatform.windows ||
          platform == TargetPlatform.linux ||
          platform == TargetPlatform.macOS;
    }

    // Webの場合、画面サイズで判定（600px以下はモバイル扱い）
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600;
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(timelineProvider);
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final isDesktop = _isDesktopOrKeyboardEnvironment(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

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
                    final isMyPost =
                        currentUserId != null && post.userId == currentUserId;

                    // 「今日の達成」由来の投稿かどうかをメッセージパターンで判定
                    final isAchievementPost =
                        post.content.contains('日達成しました！🎉');

                    // 達成投稿は背景色で強調表示
                    if (isAchievementPost) {
                      return ListTile(
                        tileColor: Colors.yellow[50],
                        leading: post.imageUrl != null
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(post.imageUrl!),
                              )
                            : const CircleAvatar(
                                radius: 20,
                                child: Icon(Icons.emoji_events),
                              ),
                        title: Text(
                          post.content,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '${post.userName}',
                            ),
                            Text(
                              '- ${formatter.format(post.createdAt!)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                        trailing: isMyPost
                            ? PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deletePost(context, post.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('削除',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
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
                      subtitle: Row(
                        children: [
                          Text(
                            '${post.userName}',
                          ),
                          Text(
                            '- ${formatter.format(post.createdAt!)}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: isMyPost
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deletePost(context, post.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('削除',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : null,
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: isDesktop
                      ? Focus(
                          canRequestFocus: false,
                          onKeyEvent: (node, event) {
                            // デスクトップ: Shift+Enterで改行、Enterで投稿
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.enter &&
                                !HardwareKeyboard.instance.isShiftPressed) {
                              _submitPost();
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            maxLines: null,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: '投稿を入力してください',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        )
                      : TextField(
                          // モバイル: Enterで改行、投稿ボタンで投稿
                          controller: controller,
                          focusNode: focusNode,
                          maxLines: null,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: '投稿を入力してください',
                            border: OutlineInputBorder(),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitPost,
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
