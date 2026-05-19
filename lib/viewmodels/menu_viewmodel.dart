import 'package:flutter/foundation.dart';
import 'package:toriniku_geprek/models/menu_item.dart';
import 'package:toriniku_geprek/services/menu_service.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuService _service;

  MenuViewModel({MenuService? service})
      : _service = service ?? MenuService();

  // ─── State ────────────────────────────────────────────────────────────────
  List<MenuItem> _items = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<MenuItem> get items => List.unmodifiable(_items);
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Items filtered by [_selectedCategoryId] (client-side convenience).
  List<MenuItem> get filteredItems => _selectedCategoryId == null
      ? _items
      : _items
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();

  // ─── Filter ───────────────────────────────────────────────────────────────
  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────
  Future<void> loadMenuItems() async {
    _setLoading(true);
    try {
      _items = await _service.getAllMenuItems();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load menu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Add ──────────────────────────────────────────────────────────────────
  Future<bool> addMenuItem({
    required String name,
    String? description,
    required int categoryId,
    required double price,
  }) async {
    _setLoading(true);
    try {
      final item = await _service.addMenuItem(
        name: name,
        description: description,
        categoryId: categoryId,
        price: price,
      );
      _items = [..._items, item];
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────
  Future<bool> updateMenuItem(MenuItem item) async {
    _setLoading(true);
    try {
      await _service.updateMenuItem(item);
      _items = _items.map((m) => m.id == item.id ? item : m).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  Future<bool> deleteMenuItem(int id) async {
    _setLoading(true);
    try {
      await _service.deleteMenuItem(id);
      _items = _items.where((m) => m.id != id).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
