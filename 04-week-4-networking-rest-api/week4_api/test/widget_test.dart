import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/widgets/post_tile.dart';

void main() {
  testWidgets('PostTile menampilkan id, title, dan body', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PostTile(
          post: const Post(userId: 1, id: 5, title: 'Judul', body: 'Isi'),
          onTap: () => tapped = true,
        ),
      ),
    ));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Judul'), findsOneWidget);
    expect(find.text('Isi'), findsOneWidget);
    await tester.tap(find.byType(PostTile));
    expect(tapped, isTrue);
  });
}
