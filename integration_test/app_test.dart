import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orbita_labs/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> screenshot(String name) async {
    final bytes = await binding.takeScreenshot(name);
    await File('${Directory.systemTemp.path}/$name.png').writeAsBytes(bytes);
  }

  testWidgets('Android: карточка, лайк, Snackbar, подробности и избранное', (
    tester,
  ) async {
    await tester.pumpWidget(const OrbitaApp());
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await screenshot('01-catalog');
    expect(find.text('ПИбд-33'), findsOneWidget);

    final like = find.byKey(const ValueKey('like-earth'));
    await tester.scrollUntilVisible(
      like,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(like);
    await tester.pumpAndSettle();
    expect(find.text('Земля: добавлено в избранное'), findsOneWidget);
    await screenshot('02-like-snackbar');

    await tester.tap(find.text('Земля'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Знакомься ближе'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Знакомься ближе'), findsOneWidget);
    await screenshot('03-details');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorites-tab')));
    await tester.pumpAndSettle();
    expect(find.text('Земля'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
