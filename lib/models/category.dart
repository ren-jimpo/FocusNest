import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    String? id,
    required this.name,
    this.description = '',
    required this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Category copyWith({
    String? name,
    String? description,
    Color? color,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // カテゴリー名での検索
  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowercaseQuery) ||
        description.toLowerCase().contains(lowercaseQuery);
  }

  // JSON変換用（将来的なデータベース連携用）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      color: Color(json['color']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

// デフォルトカテゴリーの定義
class DefaultCategories {
  static final List<Category> defaultCategories = [
    Category(
      id: 'default_work',
      name: '仕事',
      description: '業務関連のタスク',
      color: CupertinoColors.systemBlue,
    ),
    Category(
      id: 'default_personal',
      name: '個人',
      description: '個人的なタスク',
      color: CupertinoColors.systemGreen,
    ),
    Category(
      id: 'default_study',
      name: '学習',
      description: '学習・勉強関連のタスク',
      color: CupertinoColors.systemOrange,
    ),
  ];

  // プリセットカラー
  static final List<Color> presetColors = [
    CupertinoColors.systemRed,
    CupertinoColors.systemOrange,
    CupertinoColors.systemYellow,
    CupertinoColors.systemGreen,
    CupertinoColors.systemBlue,
    CupertinoColors.systemIndigo,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPink,
    CupertinoColors.systemGrey,
    CupertinoColors.systemBrown,
  ];
} 