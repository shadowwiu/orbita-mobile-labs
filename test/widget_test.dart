import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_labs/data/catalog_repository.dart';
import 'package:orbita_labs/main.dart';

void main() {
  final source = File('assets/data/space_objects.json').readAsStringSync();
  OrbitaApp app() =>
      OrbitaApp(repository: CatalogRepository(() => Future.value(source)));

  Future<void> showLike(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('like-earth')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> openCatalog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  testWidgets('В AppBar есть ФИО и группа, карточка содержит изображение', (
    tester,
  ) async {
    await openCatalog(tester);
    expect(find.text('Понькин Егор Валерьевич'), findsOneWidget);
    expect(find.text('ПИбд-33'), findsOneWidget);
    expect(find.text('Земля'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Лайк показывает Snackbar, отмена восстанавливает состояние', (
    tester,
  ) async {
    await openCatalog(tester);
    await showLike(tester);
    await tester.tap(find.byKey(const ValueKey('like-earth')));
    await tester.pumpAndSettle();
    expect(find.text('Земля: добавлено в избранное'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await tester.tap(find.text('Отменить'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsNothing);
  });

  testWidgets('Лайк в подробностях синхронизирован с избранным', (
    tester,
  ) async {
    await openCatalog(tester);
    await showLike(tester);
    await tester.tap(find.text('Земля'));
    await tester.pumpAndSettle();
    expect(find.text('Знакомься ближе'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('like-earth')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorites-tab')));
    await tester.pumpAndSettle();
    expect(find.text('Сохранённые миры'), findsOneWidget);
    expect(find.text('Земля'), findsOneWidget);
    await tester.drag(find.byType(SnackBar), const Offset(0, 300));
    await tester.pumpAndSettle();
    await showLike(tester);
    await tester.tap(find.byKey(const ValueKey('like-earth')));
    await tester.pumpAndSettle();
    expect(find.text('Здесь будут любимые миры'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Поиск и фильтр спутников отбирают нужные карточки', (
    tester,
  ) async {
    await openCatalog(tester);
    await tester.enterText(find.byKey(const ValueKey('search')), 'марс');
    await tester.pumpAndSettle();
    expect(find.text('Марс'), findsOneWidget);
    expect(find.text('Земля'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('search')),
      'нет такого мира',
    );
    await tester.pumpAndSettle();
    expect(find.text('Миры не найдены'), findsOneWidget);
    await tester.tap(find.byTooltip('Очистить поиск'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Спутники'));
    await tester.pumpAndSettle();
    expect(find.text('Луна'), findsOneWidget);
    expect(find.text('Земля'), findsNothing);
  });

  testWidgets('Ошибка чтения даёт экран с повтором', (tester) async {
    await tester.pumpWidget(
      OrbitaApp(
        repository: CatalogRepository(() => Future.error(Exception('No data'))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Каталог недоступен'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('Узкий экран 320 px не вызывает переполнений', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('catalog-scroll')),
      const Offset(0, -380),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
