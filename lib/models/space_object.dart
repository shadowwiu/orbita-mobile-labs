/// Тип небесного тела. Enum ограничивает набор допустимых значений.
enum SpaceObjectType { rocky, giant, satellite }

/// Extension добавляет читаемое название существующему типу.
extension SpaceObjectTypeLabel on SpaceObjectType {
  String get label => switch (this) {
    SpaceObjectType.rocky => 'Каменистая планета',
    SpaceObjectType.giant => 'Планета-гигант',
    SpaceObjectType.satellite => 'Спутник',
  };
}

extension Kilometers on int {
  String get kilometers {
    final digits = toString();
    final result = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) result.write(' ');
      result.write(digits[i]);
    }
    return '$result км';
  }
}

/// Класс с полями, конструктором и методами, общий для приложения и ЛР 2.
class SpaceObject {
  const SpaceObject({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
    required this.image,
    required this.diameterKm,
    required this.day,
    required this.temperature,
    required this.description,
    required this.facts,
  });

  factory SpaceObject.fromJson(Map<String, dynamic> json) => SpaceObject(
    id: json['id'] as String,
    name: json['name'] as String,
    subtitle: json['subtitle'] as String,
    type: SpaceObjectType.values.byName(json['type'] as String),
    image: json['image'] as String,
    diameterKm: json['diameterKm'] as int,
    day: json['day'] as String,
    temperature: json['temperature'] as String,
    description: json['description'] as String,
    facts: List<String>.from(json['facts'] as List),
  );

  final String id;
  final String name;
  final String subtitle;
  final SpaceObjectType type;
  final String image;
  final int diameterKm;
  final String day;
  final String temperature;
  final String description;
  final List<String> facts;

  bool matches(String query) {
    final normalized = query.trim().toLowerCase().replaceAll('ё', 'е');
    return '$name $subtitle ${type.label}'
        .toLowerCase()
        .replaceAll('ё', 'е')
        .contains(normalized);
  }

  String summary() =>
      '$name — ${type.label}, диаметр: ${diameterKm.kilometers}';
}
