import 'package:flutter/cupertino.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'category_edit_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categories = _categoryService.getAllCategories();
    });
  }

  void _navigateToCategoryEdit({Category? category}) {
    showCupertinoModalPopup<Category>(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: CupertinoPageScaffold(
          child: CategoryEditScreen(category: category),
        ),
      ),
    ).then((result) {
      if (result != null) {
        if (category == null) {
          _categoryService.addCategory(result);
        } else {
          _categoryService.updateCategory(result);
        }
        _loadCategories();
      }
    });
  }

  void _deleteCategory(Category category) {
    if (!_categoryService.canDeleteCategory(category.id)) {
      _showAlert('削除できません', 'デフォルトカテゴリーは削除できません。');
      return;
    }

    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('カテゴリーを削除'),
        content: Text('「${category.name}」を削除しますか？\nこのカテゴリーに関連するタスクは「未分類」になります。'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _categoryService.deleteCategory(category.id);
              _loadCategories();
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('カテゴリー管理'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _navigateToCategoryEdit(),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: _categories.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.folder,
                      size: 64,
                      color: CupertinoColors.systemGrey3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'カテゴリーがありません',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryTile(category);
                },
              ),
      ),
    );
  }

  Widget _buildCategoryTile(Category category) {
    final isDefault = !_categoryService.canDeleteCategory(category.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToCategoryEdit(category: category),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // カテゴリーカラー
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              
              // カテゴリー情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'デフォルト',
                              style: TextStyle(
                                fontSize: 10,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (category.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // アクションボタン
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showCategoryActions(category),
                child: const Icon(
                  CupertinoIcons.ellipsis,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryActions(Category category) {
    final canDelete = _categoryService.canDeleteCategory(category.id);
    
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCategoryEdit(category: category);
            },
            child: const Text('編集'),
          ),
          if (canDelete)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                _deleteCategory(category);
              },
              child: const Text('削除'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }
} 