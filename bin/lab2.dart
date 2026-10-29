import 'dart:io';

import 'package:orbita_labs/data/catalog_repository.dart';
import 'package:orbita_labs/models/space_object.dart';

/// Запуск из корня проекта: dart run bin/lab2.dart [поисковый запрос].
Future<void> main(List<String> args) async {
  final source = File.fromUri(
    Platform.script.resolve('../assets/data/space_objects.json'),
  );
  final repository = CatalogRepository(() => source.readAsString());

  try {
    final List<SpaceObject> objects = await repository.load();
    final query = args.join(' ');
    final found = objects.where((object) => object.matches(query)).toList();
    stdout.writeln('ОРБИТА · Каталог небесных тел');
    stdout.writeln('Понькин Егор Валерьевич · ПИбд-33');
    stdout.writeln('Найдено объектов: ${found.length}');

    // Цикл выполняет осмысленную задачу: печатает найденные объекты.
    for (final object in found) {
      stdout.writeln(object.summary());
    }

    final giants = found
        .where((object) => object.type == SpaceObjectType.giant)
        .length;
    stdout.writeln('Планет-гигантов в выборке: $giants');
  } on Object catch (error) {
    stderr.writeln('Не удалось прочитать каталог: $error');
    exitCode = 1;
  }
}
