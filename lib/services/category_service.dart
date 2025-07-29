import '../models/category.dart';

class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal() {
    // デフォルトカテゴリーを初期化時に追加
    _categories.addAll(DefaultCategories.defaultCategories);
  }

  final List<Category> _categories = [];

  // すべてのカテゴリーを取得
  List<Category> getAllCategories() => List.unmodifiable(_categories);

  // カテゴリーを追加
  void addCategory(Category category) {
    _categories.add(category);
  }

  // カテゴリーを更新
  void updateCategory(Category updatedCategory) {
    final index = _categories.indexWhere((category) => category.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = updatedCategory;
    }
  }

  // カテゴリーを削除
  void deleteCategory(String categoryId) {
    // デフォルトカテゴリーは削除不可
    if (categoryId.startsWith('default_')) {
      return;
    }
    _categories.removeWhere((category) => category.id == categoryId);
  }

  // IDでカテゴリーを取得
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // 検索機能
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return List.from(_categories);
    return _categories.where((category) => category.matchesSearch(query)).toList();
  }

  // カテゴリーが削除可能かチェック
  bool canDeleteCategory(String categoryId) {
    return !categoryId.startsWith('default_');
  }

  // 使用されているカテゴリーのリストを取得（タスクサービスとの連携用）
  List<String> getUsedCategoryIds() {
    // この実装は後でTaskServiceとの連携で更新予定
    return [];
  }
} 