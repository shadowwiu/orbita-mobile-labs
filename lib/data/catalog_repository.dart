import 'dart:convert';

import '../models/space_object.dart';

/// Загрузчик передаётся снаружи: Flutter читает assets, Dart — обычный файл.
/// Future представляет результат асинхронного чтения.
class CatalogRepository {
  const CatalogRepository(this.readSource);

  final Future<String> Function() readSource;

  Future<List<SpaceObject>> load() async {
    final source = await readSource();
    final decoded = jsonDecode(source) as List<dynamic>;
    // map принимает анонимную функцию, List<SpaceObject> использует generics.
    return decoded
        .map((item) => SpaceObject.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
