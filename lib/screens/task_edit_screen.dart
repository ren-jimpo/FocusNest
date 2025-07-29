import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/study_theme.dart';
import '../models/category.dart';
import '../services/study_theme_service.dart';
import '../services/category_service.dart';
import '../widgets/card_text_field.dart';

class TaskEditScreen extends StatefulWidget {
  final Task? task;

  const TaskEditScreen({super.key, this.task});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final StudyThemeService _themeService = StudyThemeService();
  final CategoryService _categoryService = CategoryService();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;
  
  late TaskPriority _priority;
  late TaskStatus _status;
  late TaskRepeat _repeat;
  DateTime? _dueDate;
  String? _relatedThemeId;
  String? _categoryId;
  List<String> _tags = [];
  List<StudyTheme> _availableThemes = [];
  List<Category> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _availableThemes = _themeService.getAllThemes();
    _availableCategories = _categoryService.getAllCategories();
    
    if (widget.task != null) {
      _titleController = TextEditingController(text: widget.task!.title);
      _descriptionController = TextEditingController(text: widget.task!.description);
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _repeat = widget.task!.repeat;
      _dueDate = widget.task!.dueDate;
      _relatedThemeId = widget.task!.relatedThemeId;
      _categoryId = widget.task!.categoryId;
      _tags = List.from(widget.task!.tags);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _priority = TaskPriority.medium;
      _status = TaskStatus.notStarted;
      _repeat = TaskRepeat.none;
    }
    
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      _showAlert('エラー', 'タイトルを入力してください。');
      return;
    }

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      status: _status,
      tags: _tags,
      repeat: _repeat,
      relatedThemeId: _relatedThemeId,
      categoryId: _categoryId,
      createdAt: widget.task?.createdAt,
    );

    Navigator.pop(context, task);
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

  void _showDatePicker() {
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
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('完了'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: _dueDate ?? DateTime.now(),
                minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _dueDate = newDate;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('優先度を選択'),
        actions: TaskPriority.values.map((priority) =>
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _priority = priority;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(priority.displayName),
              ],
            ),
          ),
        ).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showStatusPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('ステータスを選択'),
        actions: TaskStatus.values.map((status) =>
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _status = status;
              });
            },
            child: Text(status.displayName),
          ),
        ).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showRepeatPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('繰り返し設定'),
        actions: TaskRepeat.values.map((repeat) =>
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _repeat = repeat;
              });
            },
            child: Text(repeat.displayName),
          ),
        ).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showThemePicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('関連する学習テーマ'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _relatedThemeId = null;
              });
            },
            child: const Text('なし'),
          ),
          ..._availableThemes.map((theme) =>
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _relatedThemeId = theme.id;
                });
              },
              child: Text(theme.title),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('カテゴリーを選択'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _categoryId = null;
              });
            },
            child: const Text('未分類'),
          ),
          ..._availableCategories.map((category) =>
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _categoryId = category.id;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return CupertinoColors.systemRed;
      case TaskPriority.medium:
        return CupertinoColors.systemOrange;
      case TaskPriority.low:
        return CupertinoColors.systemGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.task != null ? 'タスクを編集' : '新しいタスク'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveTask,
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 基本情報
            CardSection(
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
                  label: 'タイトル',
                  placeholder: 'タスクのタイトルを入力',
                  controller: _titleController,
                ),
                const SizedBox(height: 16),
                CardTextField(
                  label: '説明',
                  placeholder: 'タスクの詳細説明（任意）',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
              ],
            ),
            
            // 期限と設定
            CardSection(
              children: [
                const Text(
                  '期限と設定',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                CardSelectField(
                  label: '期限',
                  value: _dueDate != null
                      ? DateFormat('yyyy年M月d日 HH:mm').format(_dueDate!)
                      : '期限を設定',
                  onTap: _showDatePicker,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_dueDate != null)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _dueDate = null;
                            });
                          },
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: CupertinoColors.systemGrey,
                            size: 20,
                          ),
                        ),
                      const Icon(
                        CupertinoIcons.calendar,
                        color: CupertinoColors.systemGrey2,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CardSelectField(
                  label: '優先度',
                  value: _priority.displayName,
                  onTap: _showPriorityPicker,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(_priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey2,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CardSelectField(
                  label: 'ステータス',
                  value: _status.displayName,
                  onTap: _showStatusPicker,
                ),
                const SizedBox(height: 16),
                CardSelectField(
                  label: '繰り返し',
                  value: _repeat.displayName,
                  onTap: _showRepeatPicker,
                ),
              ],
            ),
            
            // 関連情報
            CardSection(
              children: [
                const Text(
                  '関連情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                CardSelectField(
                  label: 'カテゴリー',
                  value: _categoryId != null
                      ? _categoryService.getCategoryById(_categoryId!)?.name ?? 'カテゴリーが見つかりません'
                      : '未分類',
                  onTap: _showCategoryPicker,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_categoryId != null) ...[
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _categoryService.getCategoryById(_categoryId!)?.color ?? CupertinoColors.systemGrey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey2,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CardSelectField(
                  label: '関連学習テーマ',
                  value: _relatedThemeId != null
                      ? _themeService.getThemeById(_relatedThemeId!)?.title ?? 'テーマが見つかりません'
                      : 'なし',
                  onTap: _showThemePicker,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'タグ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: _tagController,
                              placeholder: 'タグを追加',
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          CupertinoButton(
                            onPressed: _addTag,
                            child: const Icon(CupertinoIcons.add),
                          ),
                        ],
                      ),
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: CupertinoColors.systemBlue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _removeTag(tag),
                                  child: const Icon(
                                    CupertinoIcons.xmark,
                                    size: 14,
                                    color: CupertinoColors.systemBlue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 