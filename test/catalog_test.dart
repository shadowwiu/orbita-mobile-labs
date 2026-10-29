import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_labs/catalog_controller.dart';
import 'package:orbita_labs/data/catalog_repository.dart';
import 'package:orbita_labs/models/space_object.dart';

void main() {
  CatalogRepository repository() => CatalogRepository(
    () => File('assets/data/space_objects.json').readAsString(),
  );

  test('Каталог содержит шесть объектов с существующими картинками', () async {
    final objects = await repository().load();
    expect(objects.length, 6);
    expect(objects.map((object) => object.id).toSet().length, 6);
    for (final object in objects) {
      expect(File(object.image).existsSync(), isTrue);
      expect(object.facts.length, greaterThanOrEqualTo(3));
    }
  });

  test('Поиск учитывает пробелы, регистр и букву ё', () async {
    final objects = await repository().load();
    expect(
      objects.where((object) => object.matches('  МАРС  ')).single.id,
      'mars',
    );
    expect(
      objects.where((object) => object.matches('далекий')).single.id,
      'neptune',
    );
    expect(
      objects.where((object) => object.matches('спутник')).single.id,
      'moon',
    );
    expect(
      objects.where((object) => object.matches('несуществующий')),
      isEmpty,
    );
  });

  test('Extension форматирует километры и подписи enum', () {
    expect(139820.kilometers, '139 820 км');
    expect(0.kilometers, '0 км');
    expect(SpaceObjectType.giant.label, 'Планета-гигант');
  });

  test('Избранное переключается и не дублирует объекты', () async {
    final controller = CatalogController(repository());
    await controller.load();
    expect(controller.toggleFavorite('earth'), isTrue);
    expect(controller.favoriteCount, 1);
    expect(controller.toggleFavorite('earth'), isFalse);
    expect(controller.favoriteCount, 0);
    controller.dispose();
  });

  test(
    'Повреждённый JSON даёт ошибку, повторная загрузка восстанавливает каталог',
    () async {
      var fail = true;
      final controller = CatalogController(
        CatalogRepository(() async {
          if (fail) return '{broken';
          return File('assets/data/space_objects.json').readAsString();
        }),
      );
      await controller.load();
      expect(controller.error, isNotNull);
      expect(controller.isLoading, isFalse);
      fail = false;
      await controller.load();
      expect(controller.error, isNull);
      expect(controller.objects.length, 6);
      controller.dispose();
    },
  );
}
