import 'package:flutter/foundation.dart';
import 'package:toriniku_geprek/models/category.dart';
import 'package:toriniku_geprek/services/category_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryService _service;

  CategoryViewModel({CategoryService? service})
      : _service = service ?? CategoryService();

  // ─── State ────────────────────────────────────────────────────────────────
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // ─── Load ─────────────────────────────────────────────────────────────────
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _service.getAllCategories();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Add ──────────────────────────────────────────────────────────────────
  Future<bool> addCategory(String name) async {
    _setLoading(true);
    try {
      final category = await _service.addCategory(name);
      _categories = [..._categories, category];
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
  Future<bool> updateCategory(Category category) async {
    _setLoading(true);
    try {
      await _service.updateCategory(category);
      _categories = _categories
          .map((c) => c.id == category.id ? category : c)
          .toList();
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
  Future<bool> deleteCategory(int id) async {
    _setLoading(true);
    try {
      await _service.deleteCategory(id);
      _categories = _categories.where((c) => c.id != id).toList();
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
