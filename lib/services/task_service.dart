import '../models/task.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  // モックデータ
  final List<Task> _tasks = [
    Task(
      title: 'Flutter開発の基礎を学ぶ',
      description: 'Flutterの基本的なウィジェットと状態管理について学習する',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      tags: ['Flutter', '開発', '学習'],
      relatedThemeId: 'theme_flutter',
      categoryId: 'default_study',
    ),
    Task(
      title: 'データベース設計の復習',
      description: 'PostgreSQLの基本とSupabaseの使い方を復習する',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      priority: TaskPriority.medium,
      status: TaskStatus.notStarted,
      tags: ['データベース', 'PostgreSQL', 'Supabase'],
      relatedThemeId: 'theme_backend',
      categoryId: 'default_study',
    ),
    Task(
      title: 'UIデザインガイドラインの確認',
      description: 'Apple Human Interface Guidelinesを読んで理解する',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
      status: TaskStatus.notStarted,
      tags: ['UI/UX', 'デザイン', 'Apple'],
      categoryId: 'default_work',
    ),
    Task(
      title: 'プロジェクト進捗報告書作成',
      description: '今週の開発進捗をまとめた報告書を作成する',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.medium,
      status: TaskStatus.notStarted,
      tags: ['報告書', 'ドキュメント'],
      categoryId: 'default_work',
    ),
    Task(
      title: 'コードレビューの実施',
      description: 'チームメンバーのコードをレビューし、フィードバックを提供する',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: TaskPriority.low,
      status: TaskStatus.done,
      tags: ['コードレビュー', 'チーム'],
      categoryId: 'default_work',
    ),
    Task(
      title: 'アプリのテスト計画策定',
      description: 'FocusNestアプリの包括的なテスト計画を策定する',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      priority: TaskPriority.medium,
      status: TaskStatus.notStarted,
      tags: ['テスト', '品質保証'],
      relatedThemeId: 'theme_testing',
      categoryId: 'default_study',
    ),
  ];

  // すべてのタスクを取得
  List<Task> getAllTasks() => List.unmodifiable(_tasks);

  // タスクを追加
  void addTask(Task task) {
    _tasks.add(task);
  }

  // タスクを更新
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  // タスクを削除
  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
  }

  // IDでタスクを取得
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // フィルタリング機能
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> getTasksByTag(String tag) {
    return _tasks.where((task) => task.tags.contains(tag)).toList();
  }

  List<Task> getTasksDueToday() {
    return _tasks.where((task) => task.hasDueToday()).toList();
  }

  List<Task> getTasksDueThisWeek() {
    return _tasks.where((task) => task.hasDueThisWeek()).toList();
  }

  List<Task> getTasksDueThisMonth() {
    return _tasks.where((task) => task.hasDueThisMonth()).toList();
  }

  List<Task> searchTasks(String query) {
    if (query.isEmpty) return List.from(_tasks);
    return _tasks.where((task) => task.matchesSearch(query)).toList();
  }

  // 学習テーマに関連するタスクを取得
  List<Task> getTasksByThemeId(String themeId) {
    return _tasks.where((task) => task.relatedThemeId == themeId).toList();
  }

  // カテゴリーに関連するタスクを取得
  List<Task> getTasksByCategoryId(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  // すべてのタグを取得
  Set<String> getAllTags() {
    final tags = <String>{};
    for (final task in _tasks) {
      tags.addAll(task.tags);
    }
    return tags;
  }
} 