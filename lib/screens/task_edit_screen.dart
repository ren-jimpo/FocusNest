import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/study_theme.dart';
import '../services/study_theme_service.dart';

class TaskEditScreen extends StatefulWidget {
  final Task? task;

  const TaskEditScreen({super.key, this.task});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final StudyThemeService _themeService = StudyThemeService();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;
  
  late TaskPriority _priority;
  late TaskStatus _status;
  late TaskRepeat _repeat;
  DateTime? _dueDate;
  String? _relatedThemeId;
  List<String> _tags = [];
  List<StudyTheme> _availableThemes = [];

  @override
  void initState() {
    super.initState();
    _availableThemes = _themeService.getAllThemes();
    
    if (widget.task != null) {
      _titleController = TextEditingController(text: widget.task!.title);
      _descriptionController = TextEditingController(text: widget.task!.description);
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _repeat = widget.task!.repeat;
      _dueDate = widget.task!.dueDate;
      _relatedThemeId = widget.task!.relatedThemeId;
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
            // タイトル
            _buildSection(
              'タイトル',
              CupertinoTextFormFieldRow(
                controller: _titleController,
                placeholder: 'タスクのタイトルを入力',
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 説明
            _buildSection(
              '説明',
              CupertinoTextFormFieldRow(
                controller: _descriptionController,
                placeholder: 'タスクの詳細説明（任意）',
                maxLines: 3,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 期限
            _buildSection(
              '期限',
              GestureDetector(
                onTap: _showDatePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dueDate != null
                            ? DateFormat('yyyy年M月d日 HH:mm').format(_dueDate!)
                            : '期限を設定',
                        style: TextStyle(
                          color: _dueDate != null
                              ? CupertinoColors.label
                              : CupertinoColors.placeholderText,
                        ),
                      ),
                      Row(
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
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 優先度
            _buildSection(
              '優先度',
              GestureDetector(
                onTap: _showPriorityPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                          Text(_priority.displayName),
                        ],
                      ),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ステータス
            _buildSection(
              'ステータス',
              GestureDetector(
                onTap: _showStatusPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_status.displayName),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 繰り返し
            _buildSection(
              '繰り返し',
              GestureDetector(
                onTap: _showRepeatPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_repeat.displayName),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 関連学習テーマ
            _buildSection(
              '関連学習テーマ',
              GestureDetector(
                onTap: _showThemePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _relatedThemeId != null
                              ? _themeService.getThemeById(_relatedThemeId!)?.title ?? 'テーマが見つかりません'
                              : 'なし',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // タグ
            _buildSection(
              'タグ',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextFormFieldRow(
                          controller: _tagController,
                          placeholder: 'タグを追加',
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                          onFieldSubmitted: (_) => _addTag(),
                        ),
                      ),
                      CupertinoButton(
                        onPressed: _addTag,
                        child: const Icon(CupertinoIcons.add),
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
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
                                ),
                              ),
                              const SizedBox(width: 4),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }
} 