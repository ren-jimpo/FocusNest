import 'package:uuid/uuid.dart';

// タスクの優先度
enum TaskPriority {
  high('high', '高'),
  medium('medium', '中'),
  low('low', '低');

  const TaskPriority(this.value, this.displayName);
  final String value;
  final String displayName;
}

// タスクのステータス
enum TaskStatus {
  notStarted('not_started', '未着手'),
  inProgress('in_progress', '進行中'),
  done('done', '完了');

  const TaskStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

// 繰り返し設定
enum TaskRepeat {
  none('none', 'なし'),
  daily('daily', '毎日'),
  weekly('weekly', '毎週'),
  monthly('monthly', '毎月');

  const TaskRepeat(this.value, this.displayName);
  final String value;
  final String displayName;
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final List<String> tags;
  final TaskRepeat repeat;
  final String? relatedThemeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.notStarted,
    List<String>? tags,
    this.repeat = TaskRepeat.none,
    this.relatedThemeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
    TaskRepeat? repeat,
    String? relatedThemeId,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      repeat: repeat ?? this.repeat,
      relatedThemeId: relatedThemeId ?? this.relatedThemeId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // フィルタリング用のヘルパーメソッド
  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowercaseQuery) ||
        description.toLowerCase().contains(lowercaseQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }

  bool hasDueToday() {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDate.isAtSameMomentAs(today);
  }

  bool hasDueThisWeek() {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dueDate!.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dueDate!.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool hasDueThisMonth() {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year && dueDate!.month == now.month;
  }
} 