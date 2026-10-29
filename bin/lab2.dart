import 'dart:io';

import 'package:orbita_labs/data/catalog_repository.dart';
import 'package:orbita_labs/data/catalog_report.dart';
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
    for (final line in buildCatalogReport(objects, query)) {
      stdout.writeln(line);
    }
  } on Object catch (error) {
    stderr.writeln('Не удалось прочитать каталог: $error');
    exitCode = 1;
  }
}
