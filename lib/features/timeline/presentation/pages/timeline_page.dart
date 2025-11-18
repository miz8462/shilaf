import 'package:flutter/material.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ダミーデータ（サンプル投稿）
    final samplePosts = [
      '今日はFlutterでタイムラインを作った！',
      'Riverpodの使い方を復習中。',
      'ShilafアプリのUIを改善した。',
      '継続日数が10日を突破！',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('タイムライン'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: samplePosts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.message),
            title: Text(samplePosts[index]),
            subtitle: Text('サンプルユーザー'),
          );
        },
      ),
    );
  }
}
