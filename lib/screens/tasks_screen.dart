import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'task_edit_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  String? _dueDateFilter; // 'today', 'week', 'month'

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _loadTasks() {
    setState(() {
      _applyFilters();
    });
  }

  void _applyFilters() {
    // 変更可能なリストとして取得
    List<Task> tasks = List.from(_taskService.getAllTasks());

    // 検索フィルタを適用
    if (_searchQuery.isNotEmpty) {
      tasks = _taskService.searchTasks(_searchQuery);
    }

    // ステータスフィルタを適用
    if (_statusFilter != null) {
      tasks = tasks.where((task) => task.status == _statusFilter).toList();
    }

    // 優先度フィルタを適用
    if (_priorityFilter != null) {
      tasks = tasks.where((task) => task.priority == _priorityFilter).toList();
    }

    // 期限フィルタを適用
    if (_dueDateFilter != null) {
      switch (_dueDateFilter) {
        case 'today':
          tasks = tasks.where((task) => task.hasDueToday()).toList();
          break;
        case 'week':
          tasks = tasks.where((task) => task.hasDueThisWeek()).toList();
          break;
        case 'month':
          tasks = tasks.where((task) => task.hasDueThisMonth()).toList();
          break;
      }
    }

    // 期限が近い順にソート（期限なしは最後）
    tasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    _filteredTasks = tasks;
  }

  void _showFilterOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('フィルタオプション'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showStatusFilter();
            },
            child: const Text('ステータスでフィルタ'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showPriorityFilter();
            },
            child: const Text('優先度でフィルタ'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showDueDateFilter();
            },
            child: const Text('期限でフィルタ'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _clearAllFilters();
            },
            child: const Text('フィルタをクリア'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showStatusFilter() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('ステータスを選択'),
        actions: <CupertinoActionSheetAction>[
          ...TaskStatus.values.map((status) =>
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _statusFilter = status;
                  _applyFilters();
                });
              },
              child: Text(status.displayName),
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

  void _showPriorityFilter() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('優先度を選択'),
        actions: <CupertinoActionSheetAction>[
          ...TaskPriority.values.map((priority) =>
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _priorityFilter = priority;
                  _applyFilters();
                });
              },
              child: Text(priority.displayName),
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

  void _showDueDateFilter() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('期限を選択'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _dueDateFilter = 'today';
                _applyFilters();
              });
            },
            child: const Text('今日'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _dueDateFilter = 'week';
                _applyFilters();
              });
            },
            child: const Text('今週'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _dueDateFilter = 'month';
                _applyFilters();
              });
            },
            child: const Text('今月'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _statusFilter = null;
      _priorityFilter = null;
      _dueDateFilter = null;
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _navigateToTaskEdit({Task? task}) async {
    final result = await Navigator.of(context).push<Task>(
      CupertinoPageRoute(
        builder: (context) => TaskEditScreen(task: task),
      ),
    );

    if (result != null) {
      if (task == null) {
        _taskService.addTask(result);
      } else {
        _taskService.updateTask(result);
      }
      _loadTasks();
    }
  }

  void _deleteTask(Task task) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('タスクを削除'),
        content: Text('「${task.title}」を削除しますか？'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _taskService.deleteTask(task.id);
              _loadTasks();
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
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

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return CupertinoColors.systemGrey;
      case TaskStatus.inProgress:
        return CupertinoColors.systemBlue;
      case TaskStatus.done:
        return CupertinoColors.systemGreen;
    }
  }

  Widget _buildFilterChips() {
    final List<Widget> chips = [];
    
    if (_statusFilter != null) {
      chips.add(_buildFilterChip(
        'ステータス: ${_statusFilter!.displayName}',
        () => setState(() {
          _statusFilter = null;
          _applyFilters();
        }),
      ));
    }
    
    if (_priorityFilter != null) {
      chips.add(_buildFilterChip(
        '優先度: ${_priorityFilter!.displayName}',
        () => setState(() {
          _priorityFilter = null;
          _applyFilters();
        }),
      ));
    }
    
    if (_dueDateFilter != null) {
      String filterText = '';
      switch (_dueDateFilter) {
        case 'today':
          filterText = '期限: 今日';
          break;
        case 'week':
          filterText = '期限: 今週';
          break;
        case 'month':
          filterText = '期限: 今月';
          break;
      }
      chips.add(_buildFilterChip(
        filterText,
        () => setState(() {
          _dueDateFilter = null;
          _applyFilters();
        }),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: chips,
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: CupertinoColors.systemGrey5,
        minimumSize: Size.zero,
        onPressed: onRemove,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              CupertinoIcons.xmark,
              size: 14,
              color: CupertinoColors.label,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('タスク'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showFilterOptions,
              child: const Icon(CupertinoIcons.slider_horizontal_3),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _navigateToTaskEdit(),
              child: const Icon(CupertinoIcons.add),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 検索バー
            Container(
              padding: const EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'タスクを検索...',
              ),
            ),
            
            // フィルタチップ
            _buildFilterChips(),
            
            // タスク一覧
            Expanded(
              child: _filteredTasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.doc_text,
                            size: 64,
                            color: CupertinoColors.systemGrey3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'タスクがありません',
                            style: TextStyle(
                              fontSize: 18,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return _buildTaskTile(task);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        onPressed: () => _navigateToTaskEdit(task: task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 優先度インジケーター
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // メインコンテンツ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.done
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.label,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.status.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(task.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.calendar,
                            size: 12,
                            color: task.hasDueToday()
                                ? CupertinoColors.systemRed
                                : CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('M/d').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: task.hasDueToday()
                                  ? CupertinoColors.systemRed
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: task.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 10,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              // アクションボタン
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showTaskActions(task),
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

  void _showTaskActions(Task task) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToTaskEdit(task: task);
            },
            child: const Text('編集'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              final updatedTask = task.copyWith(
                status: task.status == TaskStatus.done
                    ? TaskStatus.notStarted
                    : TaskStatus.done,
              );
              _taskService.updateTask(updatedTask);
              _loadTasks();
            },
            child: Text(
              task.status == TaskStatus.done ? '未完了にする' : '完了にする',
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(task);
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