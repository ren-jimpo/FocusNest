import 'package:flutter/cupertino.dart';
import '../models/category.dart';
import '../widgets/card_text_field.dart';

class CategoryEditScreen extends StatefulWidget {
  final Category? category;

  const CategoryEditScreen({super.key, this.category});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    
    if (widget.category != null) {
      _nameController = TextEditingController(text: widget.category!.name);
      _descriptionController = TextEditingController(text: widget.category!.description);
      _selectedColor = widget.category!.color;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedColor = DefaultCategories.presetColors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_nameController.text.trim().isEmpty) {
      _showAlert('エラー', 'カテゴリー名を入力してください。');
      return;
    }

    final category = Category(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
      createdAt: widget.category?.createdAt,
    );

    Navigator.pop(context, category);
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

  void _showColorPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  const Text(
                    'カラーを選択',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('完了'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: DefaultCategories.presetColors.length,
                  itemBuilder: (context, index) {
                    final color = DefaultCategories.presetColors[index];
                    final isSelected = color == _selectedColor;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: CupertinoColors.label,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: CupertinoColors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.category != null ? 'カテゴリーを編集' : '新しいカテゴリー'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveCategory,
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 基本情報
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoColors.systemGrey5,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey6.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '基本情報',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardTextField(
                    label: 'カテゴリー名',
                    placeholder: 'カテゴリー名を入力',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  CardTextField(
                    label: '説明',
                    placeholder: 'カテゴリーの説明（任意）',
                    controller: _descriptionController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            
            // カラー選択
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoColors.systemGrey5,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey6.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'カラー',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _showColorPicker,
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CupertinoColors.systemGrey4,
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'カラーを選択',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: CupertinoColors.label,
                                ),
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              color: CupertinoColors.systemGrey2,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // ヒント
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.folder,
                        size: 20,
                        color: CupertinoColors.systemBlue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'カテゴリーの活用法',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• プロジェクトや部門別に分類\n'
                    '• 個人・仕事・学習などの用途別\n'
                    '• 重要度や緊急度による分類\n'
                    '• 一目で分かるカラーを設定',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemBlue,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 