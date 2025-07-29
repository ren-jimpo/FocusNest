import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/study_theme.dart';
import '../models/task.dart';
import '../services/study_theme_service.dart';
import '../services/task_service.dart';
import 'study_theme_edit_screen.dart';
import 'task_edit_screen.dart';

class StudyThemeDetailScreen extends StatefulWidget {
  final StudyTheme theme;

  const StudyThemeDetailScreen({super.key, required this.theme});

  @override
  State<StudyThemeDetailScreen> createState() => _StudyThemeDetailScreenState();
}

class _StudyThemeDetailScreenState extends State<StudyThemeDetailScreen> {
  final StudyThemeService _themeService = StudyThemeService();
  final TaskService _taskService = TaskService();
  
  late StudyTheme _theme;
  List<Task> _relatedTasks = [];

  @override
  void initState() {
    super.initState();
    _theme = widget.theme;
    _loadRelatedTasks();
  }

  void _loadRelatedTasks() {
    setState(() {
      // 変更可能なリストとして取得
      _relatedTasks = List.from(_taskService.getTasksByThemeId(_theme.id));
      // 期限順でソート
      _relatedTasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    });
  }

  void _navigateToEdit() {
    showCupertinoModalPopup<StudyTheme>(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: CupertinoPageScaffold(
          child: StudyThemeEditScreen(theme: _theme),
        ),
      ),
    ).then((result) {
      if (result != null) {
        _themeService.updateTheme(result);
        setState(() {
          _theme = result;
        });
      }
    });
  }

  void _navigateToTaskEdit({Task? task}) {
    showCupertinoModalPopup<Task>(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: CupertinoPageScaffold(
          child: TaskEditScreen(task: task),
        ),
      ),
    ).then((result) {
      if (result != null) {
        if (task == null) {
          // 新規タスクの場合、このテーマに関連付け
          final updatedTask = result.copyWith(relatedThemeId: _theme.id);
          _taskService.addTask(updatedTask);
        } else {
          _taskService.updateTask(result);
        }
        _loadRelatedTasks();
      }
    });
  }

  void _updateThemeStatus(StudyThemeStatus newStatus) {
    final updatedTheme = _theme.copyWith(status: newStatus);
    _themeService.updateTheme(updatedTheme);
    setState(() {
      _theme = updatedTheme;
    });
  }

  Color _getStatusColor(StudyThemeStatus status) {
    switch (status) {
      case StudyThemeStatus.notStarted:
        return CupertinoColors.systemGrey;
      case StudyThemeStatus.studying:
        return CupertinoColors.systemBlue;
      case StudyThemeStatus.done:
        return CupertinoColors.systemGreen;
    }
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return CupertinoColors.systemGrey;
      case TaskStatus.inProgress:
        return CupertinoColors.systemBlue;
      case TaskStatus.done:
        return CupertinoColors.systemGreen;
    }
  }

  void _showStatusPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('ステータスを変更'),
        actions: StudyThemeStatus.values.map((status) =>
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _updateThemeStatus(status);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(status.displayName),
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

  @override
  Widget build(BuildContext context) {
    final completedTasks = _relatedTasks.where((task) => task.status == TaskStatus.done).length;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('学習テーマ'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _navigateToEdit,
          child: const Text('編集'),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ヘッダー情報
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      _theme.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // ステータス行
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showStatusPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_theme.status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(_theme.status).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(_theme.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _theme.status.displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getStatusColor(_theme.status),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  size: 12,
                                  color: _getStatusColor(_theme.status),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        Text(
                          '作成: ${DateFormat('yyyy/M/d').format(_theme.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 説明
                    if (_theme.description.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _theme.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 関連タスクの統計
                    if (_relatedTasks.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.doc_text,
                              size: 16,
                              color: CupertinoColors.systemBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '関連タスク: $completedTasks / ${_relatedTasks.length} 完了',
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${((_relatedTasks.isEmpty ? 0 : completedTasks / _relatedTasks.length) * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            
            // ノートセクション
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '学習ノート',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CupertinoColors.systemGrey5,
                          width: 1,
                        ),
                      ),
                      child: _theme.notes.isEmpty
                          ? const Text(
                              'ノートがありません\n「編集」からノートを追加できます',
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Text(
                              _theme.notes,
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.label,
                                height: 1.4,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // 関連タスクセクション
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '関連タスク',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _navigateToTaskEdit(),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // タスク一覧
            _relatedTasks.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            CupertinoIcons.doc_text_search,
                            size: 48,
                            color: CupertinoColors.systemGrey3,
                          ),
                          SizedBox(height: 12),
                          Text(
                            '関連タスクがありません',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '右上の + ボタンからタスクを追加できます',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = _relatedTasks[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CupertinoColors.systemGrey5,
                              width: 1,
                            ),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _navigateToTaskEdit(task: task),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // ステータスインジケーター
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getTaskStatusColor(task.status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // タスク情報
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: CupertinoColors.label,
                                            decoration: task.status == TaskStatus.done
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            task.description,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ],
                                        if (task.dueDate != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons.calendar,
                                                size: 10,
                                                color: task.hasDueToday()
                                                    ? CupertinoColors.systemRed
                                                    : CupertinoColors.systemGrey2,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                DateFormat('M/d HH:mm').format(task.dueDate!),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: task.hasDueToday()
                                                      ? CupertinoColors.systemRed
                                                      : CupertinoColors.systemGrey2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  
                                  // 優先度インジケーター
                                  if (task.priority != TaskPriority.medium)
                                    Container(
                                      width: 6,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: task.priority == TaskPriority.high
                                            ? CupertinoColors.systemRed
                                            : CupertinoColors.systemGreen,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _relatedTasks.length,
                    ),
                  ),
            
            // 下部の余白
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
} 