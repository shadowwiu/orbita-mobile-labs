import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'catalog_controller.dart';
import 'data/catalog_repository.dart';
import 'models/space_object.dart';

const background = Color(0xFF10151D);
const surface = Color(0xFF1A222D);
const accent = Color(0xFFC4ECA0);
const muted = Color(0xFF9AA9B9);

void main() => runApp(const OrbitaApp());

class OrbitaApp extends StatefulWidget {
  const OrbitaApp({super.key, this.repository});
  final CatalogRepository? repository;

  @override
  State<OrbitaApp> createState() => _OrbitaAppState();
}

class _OrbitaAppState extends State<OrbitaApp> {
  late final CatalogController controller;

  @override
  void initState() {
    super.initState();
    controller = CatalogController(
      widget.repository ??
          CatalogRepository(
            () => rootBundle.loadString('assets/data/space_objects.json'),
          ),
    );
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Орбита · ПИбд-33',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        primary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: accent,
        contentTextStyle: TextStyle(color: background),
        actionTextColor: background,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(height: 1.65),
        bodyMedium: TextStyle(height: 1.45),
      ),
    ),
    home: CatalogPage(controller: controller),
  );
}

/// ЛР 4: один контроллер хранит лайки для списка и экрана подробностей.
void toggleFavorite(
  BuildContext context,
  CatalogController controller,
  SpaceObject object,
) {
  final liked = controller.toggleFavorite(object.id);
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          liked
              ? '${object.name}: добавлено в избранное'
              : '${object.name}: удалено из избранного',
        ),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () => controller.toggleFavorite(object.id),
        ),
      ),
    );
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.controller});
  final CatalogController controller;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final searchController = TextEditingController();
  String query = '';
  int tab = 0;
  int filter = 0;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final objects = controller.objects.where((object) {
        final inTab = tab == 0 || controller.isFavorite(object.id);
        final inType = switch (filter) {
          1 => object.type != SpaceObjectType.satellite,
          2 => object.type == SpaceObjectType.satellite,
          _ => true,
        };
        return inTab && inType && object.matches(query);
      }).toList();

      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 76,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Понькин Егор Валерьевич',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text('ПИбд-33', style: TextStyle(fontSize: 12, color: muted)),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: CircleAvatar(
                backgroundColor: surface,
                child: Icon(Icons.public, color: accent),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          backgroundColor: surface,
          indicatorColor: accent.withValues(alpha: .17),
          onDestinationSelected: (value) => setState(() => tab = value),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore, color: accent),
              label: 'Каталог',
            ),
            NavigationDestination(
              key: const ValueKey('favorites-tab'),
              icon: Badge(
                isLabelVisible: controller.favoriteCount > 0,
                label: Text('${controller.favoriteCount}'),
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: const Icon(Icons.favorite, color: accent),
              label: 'Избранное',
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: CustomScrollView(
                key: const ValueKey('catalog-scroll'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: accent),
                              SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'О Р Б И Т А  /  КОСМИЧЕСКИЙ АТЛАС',
                                  style: TextStyle(fontSize: 10, color: accent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            tab == 0
                                ? 'Большая вселенная.\nТвои открытия.'
                                : 'Твоя личная\nвселенная.',
                            style: const TextStyle(
                              fontSize: 34,
                              height: 1.12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            tab == 0
                                ? 'От знакомой Земли до далёкого Нептуна.\nВыбери мир, который хочется узнать ближе.'
                                : 'Сохраняй миры, которые тебя вдохновляют.',
                            style: const TextStyle(color: muted, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            key: const ValueKey('search'),
                            controller: searchController,
                            onChanged: (value) => setState(() => query = value),
                            decoration: InputDecoration(
                              hintText: 'Найти свой мир',
                              hintStyle: const TextStyle(color: muted),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: muted,
                              ),
                              suffixIcon: query.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Очистить поиск',
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        searchController.clear();
                                        setState(() => query = '');
                                      },
                                    ),
                              filled: true,
                              fillColor: surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final (index, label) in [
                                'Все',
                                'Планеты',
                                'Спутники',
                              ].indexed)
                                ChoiceChip(
                                  label: Text(label),
                                  selected: filter == index,
                                  showCheckmark: false,
                                  selectedColor: accent,
                                  labelStyle: TextStyle(
                                    color: filter == index ? background : muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => filter = index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tab == 0
                                      ? 'Исследуй космос'
                                      : 'Сохранённые миры',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${objects.length} объектов',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                  if (controller.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (controller.error != null)
                    SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.cloud_off,
                        title: 'Каталог недоступен',
                        message: controller.error!,
                        action: FilledButton(
                          onPressed: controller.load,
                          child: const Text('Повторить'),
                        ),
                      ),
                    )
                  else if (objects.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyState(
                        icon: tab == 1 && query.isEmpty
                            ? Icons.favorite_border
                            : Icons.search_off,
                        title: tab == 1 && query.isEmpty && filter == 0
                            ? 'Здесь будут любимые миры'
                            : 'Миры не найдены',
                        message: tab == 1 && query.isEmpty && filter == 0
                            ? 'Нажми на сердце у карточки в каталоге.'
                            : 'Попробуй другой запрос или категорию.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.separated(
                        itemCount: objects.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 18),
                        itemBuilder: (context, index) => SpaceCard(
                          object: objects[index],
                          controller: controller,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Text(
                        'ЕСТЬ ЕЩЁ СТОЛЬКО НЕИЗВЕСТНОГО',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: muted,
                          fontSize: 9,
                          letterSpacing: 1.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// ЛР 3: список Card с текстом и локальным изображением Image.asset.
class SpaceCard extends StatelessWidget {
  const SpaceCard({super.key, required this.object, required this.controller});
  final SpaceObject object;
  final CatalogController controller;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: surface,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: InkWell(
      key: ValueKey('card-${object.id}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DetailPage(object: object, controller: controller),
        ),
      ),
      child: Stack(
        children: [
          Hero(
            tag: 'image-${object.id}',
            child: PlanetImage(object: object),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD080C12)],
                    stops: [0.42, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background.withValues(alpha: .75),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                child: Text(
                  object.type.label,
                  style: const TextStyle(fontSize: 10, color: accent),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 10,
            bottom: 12,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        object.name,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        object.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                FavoriteButton(object: object, controller: controller),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PlanetImage extends StatelessWidget {
  const PlanetImage({super.key, required this.object});
  final SpaceObject object;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 5 / 3,
    child: Image.asset(
      object.image,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      semanticLabel: 'Иллюстрация: ${object.name}',
      errorBuilder: (_, error, stack) => const ColoredBox(
        color: surface,
        child: Icon(Icons.public, size: 80, color: accent),
      ),
    ),
  );
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.object,
    required this.controller,
  });
  final SpaceObject object;
  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    final liked = controller.isFavorite(object.id);
    return IconButton(
      key: ValueKey('like-${object.id}'),
      tooltip: liked
          ? 'Убрать ${object.name} из избранного'
          : 'Сохранить ${object.name}',
      isSelected: liked,
      onPressed: () => toggleFavorite(context, controller, object),
      icon: const Icon(Icons.favorite_border, color: muted),
      selectedIcon: const Icon(Icons.favorite, color: accent),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.object, required this.controller});
  final SpaceObject object;
  final CatalogController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(object.name)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: SingleChildScrollView(
              key: const ValueKey('detail-scroll'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'image-${object.id}',
                    child: PlanetImage(object: object),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          object.type.label.toUpperCase(),
                          style: const TextStyle(
                            color: accent,
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                object.name,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            FavoriteButton(
                              object: object,
                              controller: controller,
                            ),
                          ],
                        ),
                        Text(
                          object.subtitle,
                          style: const TextStyle(color: muted),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            StatTile(
                              label: 'Диаметр',
                              value: object.diameterKm.kilometers,
                              icon: Icons.straighten,
                            ),
                            StatTile(
                              label: 'Солнечные сутки',
                              value: object.day,
                              icon: Icons.schedule,
                            ),
                            StatTile(
                              label: 'Температура¹',
                              value: object.temperature,
                              icon: Icons.thermostat,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Знакомься ближе',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          object.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFCDD5DF),
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'А ты знал?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        for (final (index, fact) in object.facts.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '0${index + 1}',
                                  style: const TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    fact,
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        const Text(
                          '¹ Приближённые справочные значения. Для гигантов — температура верхних облаков; для Луны — диапазон на поверхности.',
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 140),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent, size: 19),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: muted, fontSize: 11)),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      children: [
        Icon(icon, color: accent, size: 44),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
        if (action != null) ...[const SizedBox(height: 18), action!],
      ],
    ),
  );
}
