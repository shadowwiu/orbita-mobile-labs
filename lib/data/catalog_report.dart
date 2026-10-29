import '../models/space_object.dart';

/// Общая логика лабораторной 2 для консоли и экрана Android.
List<String> buildCatalogReport(List<SpaceObject> objects, String query) {
  final found = objects.where((object) => object.matches(query)).toList();
  final lines = <String>[
    'ОРБИТА · Каталог небесных тел',
    'Понькин Егор Валерьевич · ПИбд-33',
    'Найдено объектов: ${found.length}',
  ];
  for (final object in found) {
    lines.add(object.summary());
  }
  final giants = found
      .where((object) => object.type == SpaceObjectType.giant)
      .length;
  lines.add('Планет-гигантов в выборке: $giants');
  return lines;
}
