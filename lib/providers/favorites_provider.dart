import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  List<String> _favorites = [];

  List<String> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavorites();
  }

  bool isFavorite(String countryName) {
    return _favorites.contains(countryName);
  }

  void toggleFavorite(String countryName) {
    if (_favorites.contains(countryName)) {
      _favorites.remove(countryName);
    } else {
      _favorites.add(countryName);
    }
    _saveFavorites();
    notifyListeners();
  }

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList('favorites') ?? [];
    notifyListeners();
  }

  void _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', _favorites);
  }
}
