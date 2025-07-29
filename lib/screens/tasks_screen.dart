import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

import '../services/task_service.dart';
import '../services/category_service.dart';
import 'task_edit_screen.dart';
import 'category_management_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Task> _filteredTasks = [];
  final Map<String, List<Task>> _groupedTasks = {};
  String _searchQuery = '';
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  String? _dueDateFilter; // 'today', 'week', 'month'
  String? _categoryFilter;

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

    // カテゴリーフィルタを適用
    if (_categoryFilter != null) {
      if (_categoryFilter == 'uncategorized') {
        tasks = tasks.where((task) => task.categoryId == null).toList();
      } else {
        tasks = tasks.where((task) => task.categoryId == _categoryFilter).toList();
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
    _groupTasksByCategory();
  }

  void _groupTasksByCategory() {
    _groupedTasks.clear();
    
    // まず利用可能なすべてのカテゴリーを取得
    final categories = _categoryService.getAllCategories();
    
    // カテゴリーごとにタスクをグループ化
    for (final category in categories) {
      final categoryTasks = _filteredTasks.where((task) => task.categoryId == category.id).toList();
      if (categoryTasks.isNotEmpty) {
        _groupedTasks[category.id] = categoryTasks;
      }
    }
    
    // 未分類のタスクも追加
    final uncategorizedTasks = _filteredTasks.where((task) => task.categoryId == null).toList();
    if (uncategorizedTasks.isNotEmpty) {
      _groupedTasks['uncategorized'] = uncategorizedTasks;
    }
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
              _showCategoryFilter();
            },
            child: const Text('カテゴリーでフィルタ'),
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

  void _showCategoryFilter() {
    final categories = _categoryService.getAllCategories();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('カテゴリーを選択'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _categoryFilter = 'uncategorized';
                _applyFilters();
              });
            },
            child: const Text('未分類'),
          ),
          ...categories.map((category) =>
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _categoryFilter = category.id;
                  _applyFilters();
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

  void _clearAllFilters() {
    setState(() {
      _statusFilter = null;
      _priorityFilter = null;
      _dueDateFilter = null;
      _categoryFilter = null;
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
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
          _taskService.addTask(result);
        } else {
          _taskService.updateTask(result);
        }
        _loadTasks();
      }
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

    if (_categoryFilter != null) {
      String categoryName = '';
      if (_categoryFilter == 'uncategorized') {
        categoryName = '未分類';
      } else {
        final category = _categoryService.getCategoryById(_categoryFilter!);
        categoryName = category?.name ?? 'カテゴリー';
      }
      chips.add(_buildFilterChip(
        'カテゴリー: $categoryName',
        () => setState(() {
          _categoryFilter = null;
          _applyFilters();
        }),
        showColor: _categoryFilter != 'uncategorized' 
            ? _categoryService.getCategoryById(_categoryFilter!)?.color 
            : null,
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

  Widget _buildFilterChip(String label, VoidCallback onRemove, {Color? showColor}) {
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
            if (showColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: showColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
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
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const CategoryManagementScreen(),
              ),
            );
          },
          child: const Icon(CupertinoIcons.folder),
        ),
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
              child: _groupedTasks.isEmpty
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _groupedTasks.keys.length,
                      itemBuilder: (context, index) {
                        final categoryId = _groupedTasks.keys.elementAt(index);
                        final tasks = _groupedTasks[categoryId]!;
                        return _buildCategorySection(categoryId, tasks);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildCategorySection(String categoryId, List<Task> tasks) {
    String categoryName;
    Color? categoryColor;
    
    if (categoryId == 'uncategorized') {
      categoryName = '未分類';
      categoryColor = null;
    } else {
      final category = _categoryService.getCategoryById(categoryId);
      categoryName = category?.name ?? 'カテゴリー';
      categoryColor = category?.color;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリーヘッダー
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                if (categoryColor != null) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // タスクグリッド (一行に3個)
          _buildTaskGrid(tasks),
        ],
      ),
    );
  }

  Widget _buildTaskGrid(List<Task> tasks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 4.5, // 高さを半分にしたので比率を調整
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildCompactTaskCard(task);
          },
        );
      },
    );
  }

  Widget _buildCompactTaskCard(Task task) {
    return Container(
      height: 40, // 高さを半分に（80px → 40px）
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(8), // 角丸も小さく
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey6.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToTaskEdit(task: task),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // よりコンパクトに
          child: Row(
            children: [
              // 優先度アイコン
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  shape: BoxShape.circle,
                ),
              ),
              
              const SizedBox(width: 6),
              
              // タスクタイトル
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16, // 学習テーマに合わせて大幅拡大
                        fontWeight: FontWeight.w600,
                        color: task.status == TaskStatus.done
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.label,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        height: 1.1,
                      ),
                      maxLines: 1, // 1行に制限
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        DateFormat('M/d').format(task.dueDate!),
                        style: TextStyle(
                          fontSize: 13, // 学習テーマの説明サイズに合わせて拡大
                          fontWeight: FontWeight.w500,
                          color: task.isOverdue()
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 4),
              
              // 完了ボタン
              GestureDetector(
                onTap: () => _toggleTaskStatus(task),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: task.status == TaskStatus.done
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemGrey6,
                    shape: BoxShape.circle,
                    border: task.status != TaskStatus.done
                        ? Border.all(
                            color: CupertinoColors.systemGrey3,
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: task.status == TaskStatus.done
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          size: 8,
                          color: CupertinoColors.white,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTaskStatus(Task task) {
    final newStatus = task.status == TaskStatus.done
        ? TaskStatus.notStarted
        : TaskStatus.done;
    
    final updatedTask = task.copyWith(status: newStatus);
    _taskService.updateTask(updatedTask);
    _applyFilters();
  }
} 