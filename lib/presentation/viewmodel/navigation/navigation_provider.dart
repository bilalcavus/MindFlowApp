import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _lastIndex = 0;

  int get currentIndex => _currentIndex;
  int get lastIndex => _lastIndex;

  // Sayfa değiştir
  void changePage(int index) {
    if (index != _currentIndex) {
      _lastIndex = _currentIndex;
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Bir önceki sayfaya dön
  void goBack() {
    if (_lastIndex >= 0 && _lastIndex <= 4 && _lastIndex != _currentIndex) {
      _currentIndex = _lastIndex;
    } else {
      _currentIndex = 0;
    }
    notifyListeners();
  }
}
