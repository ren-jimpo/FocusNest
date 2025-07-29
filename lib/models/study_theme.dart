import 'package:uuid/uuid.dart';

// 学習テーマのステータス
enum StudyThemeStatus {
  notStarted('not_started', '未着手'),
  studying('studying', '学習中'),
  done('done', '完了');

  const StudyThemeStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

class StudyTheme {
  final String id;
  final String title;
  final String description;
  final StudyThemeStatus status;
  final String notes; // Markdown形式のノート
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyTheme({
    String? id,
    required this.title,
    this.description = '',
    this.status = StudyThemeStatus.notStarted,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  StudyTheme copyWith({
    String? title,
    String? description,
    StudyThemeStatus? status,
    String? notes,
  }) {
    return StudyTheme(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // フィルタリング用のヘルパーメソッド
  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowercaseQuery) ||
        description.toLowerCase().contains(lowercaseQuery) ||
        notes.toLowerCase().contains(lowercaseQuery);
  }
} 