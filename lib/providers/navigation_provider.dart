import 'package:flutter/foundation.dart';

/// Manages navigation state for the app's bottom navigation bar.
///
/// This provider is used to communicate navigation requests from nested screens
/// back to the AppShell to update the selected tab/destination.
class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  /// Navigate to the specified tab index
  void navigateToIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to the Goals tab (index 0)
  void navigateToGoals() => navigateToIndex(0);

  /// Navigate to the Generate tab (index 1)
  void navigateToGenerate() => navigateToIndex(1);

  /// Navigate to the Progress tab (index 2)
  void navigateToProgress() => navigateToIndex(2);

  /// Navigate to the More tab (index 3)
  void navigateToMore() => navigateToIndex(3);
}
