import 'package:flutter/foundation.dart';

import 'data/catalog_repository.dart';
import 'models/space_object.dart';

class CatalogController extends ChangeNotifier {
  CatalogController(this.repository);

  final CatalogRepository repository;
  List<SpaceObject> objects = [];
  final Set<String> _favorites = {};
  bool isLoading = true;
  String? error;
  bool _disposed = false;

  int get favoriteCount => _favorites.length;
  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      objects = await repository.load();
    } on Object {
      error = 'Не удалось загрузить каталог. Попробуйте ещё раз.';
    }
    if (_disposed) return;
    isLoading = false;
    notifyListeners();
  }

  bool toggleFavorite(String id) {
    if (!_favorites.add(id)) _favorites.remove(id);
    notifyListeners();
    return isFavorite(id);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
