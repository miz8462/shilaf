import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/features/profile/providers/user_provider.dart';
import 'package:shilaf/features/timeline/data/timeline_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final timelineProvider =
    AsyncNotifierProvider<TimelineNotifier, List<TimelinePost>>(() {
  return TimelineNotifier();
});

class TimelineNotifier extends AsyncNotifier<List<TimelinePost>> {
  @override
  Future<List<TimelinePost>> build() async {
    // 初期ロード時にDBから投稿一覧を取得
    return await fetchPosts();
  }

  Future<List<TimelinePost>> fetchPosts() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('posts')
        // users テーブルから username と avatar_url をJOIN取得
        .select('id, user_id, content, created_at, users(username, avatar_url)')
        .order('created_at', ascending: false);

    // Supabaseのレスポンスをモデルに変換
    final posts =
        (response as List).map((json) => TimelinePost.fromJson(json)).toList();
    return posts;
  }

  Future<void> addPost(String content) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('ログインが必要です');
    }

    final response = await supabase
        .from('posts')
        .insert({
          'user_id': user.id,
          'content': content,
        })
        .select()
        .single();

    final currentUser = await ref.read(currentUserDataProvider.future);

    final newPost = TimelinePost(
      id: response['id'] as String,
      userId: user.id,
      content: response['content'] as String,
      createdAt: DateTime.parse(response['created_at'] as String).toLocal(),
      userName: currentUser?.username ?? '不明',
      // 投稿者自身のアバターURLを設定（タイムライン表示用）
      imageUrl: currentUser?.avatarUrl,
    );
    // stateを更新
    state = AsyncData([newPost, ...state.value ?? []]);
  }

  Future<void> deletePost(String postId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('ログインが必要です');
    }

    // 投稿を削除
    await supabase
        .from('posts')
        .delete()
        .eq('id', postId)
        .eq('user_id', user.id);

    // stateを更新（削除した投稿を除外）
    final currentPosts = state.value ?? [];
    final updatedPosts =
        currentPosts.where((post) => post.id != postId).toList();
    state = AsyncData(updatedPosts);
  }
}
