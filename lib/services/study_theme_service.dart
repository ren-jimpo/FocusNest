import '../models/study_theme.dart';

class StudyThemeService {
  static final StudyThemeService _instance = StudyThemeService._internal();
  factory StudyThemeService() => _instance;
  StudyThemeService._internal();

  // モックデータ
  final List<StudyTheme> _themes = [
    StudyTheme(
      id: 'theme_flutter',
      title: 'Flutter開発マスター',
      description: 'Flutterを使ったモバイル・デスクトップアプリ開発の習得',
      status: StudyThemeStatus.studying,
      notes: '''# Flutter開発学習ノート

## 基本概念
- **Widget**: UIの構成要素
- **State**: ウィジェットの状態管理
- **BuildContext**: ウィジェットツリーでの位置情報

## 学習済み項目
✓ Dart言語の基礎
✓ StatelessWidget vs StatefulWidget
✓ 基本的なレイアウトウィジェット

## 今後の学習予定
- [ ] 状態管理（Provider, Riverpod）
- [ ] ナビゲーション
- [ ] アニメーション
- [ ] ネイティブ機能との連携

## 参考資料
- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Dart公式サイト](https://dart.dev)
''',
    ),
    StudyTheme(
      id: 'theme_backend',
      title: 'バックエンド開発とSupabase',
      description: 'Supabaseを使ったバックエンド開発とデータベース設計',
      status: StudyThemeStatus.notStarted,
      notes: '''# バックエンド開発学習ノート

## 学習目標
- PostgreSQLデータベースの設計
- Supabaseの認証機能
- リアルタイム同期の実装
- RESTful APIの理解

## 準備
- [ ] Supabaseアカウント作成
- [ ] プロジェクトセットアップ
- [ ] データベーススキーマ設計

## 学習スケジュール
1. PostgreSQL基礎（1週間）
2. Supabase Auth（3日）
3. Database & Storage（1週間）
4. Realtime機能（3日）
''',
    ),
    StudyTheme(
      id: 'theme_testing',
      title: 'アプリケーションテスト戦略',
      description: 'Flutterアプリの包括的なテスト手法の学習',
      status: StudyThemeStatus.notStarted,
      notes: '''# テスト戦略学習ノート

## テストの種類
- **Unit Test**: 個別の関数やクラスのテスト
- **Widget Test**: UIコンポーネントのテスト
- **Integration Test**: アプリ全体の動作テスト

## 学習計画
- [ ] Flutterテストフレームワークの理解
- [ ] mockitoを使ったモックテスト
- [ ] テストケースの設計
- [ ] CI/CDでの自動テスト

## ツール
- flutter_test
- mockito
- integration_test
''',
    ),
    StudyTheme(
      id: 'theme_ai',
      title: 'AI・機械学習の基礎',
      description: 'AIとML技術の基本概念とアプリケーションへの応用',
      status: StudyThemeStatus.studying,
      notes: '''# AI・機械学習学習ノート

## 基本概念
- **機械学習**: データからパターンを学習するアルゴリズム
- **深層学習**: ニューラルネットワークを使った学習手法
- **自然言語処理**: テキストデータの処理技術

## 学習済み項目
✓ Python基礎
✓ NumPy, Pandas
✓ 基本的な機械学習アルゴリズム

## 現在学習中
- TensorFlow/Keras
- ChatGPT APIの活用
- 画像認識の基礎

## アプリへの応用案
- 学習ノートの自動要約
- タスクの自動分類
- 学習進捗の予測
''',
    ),
    StudyTheme(
      title: 'UI/UXデザインの原則',
      description: 'ユーザビリティとアクセシビリティを考慮したデザイン手法',
      status: StudyThemeStatus.studying,
      notes: '''# UI/UXデザイン学習ノート

## Apple Human Interface Guidelines
- **明確性**: ユーザーが理解しやすいデザイン
- **一貫性**: 予測可能なインターフェース
- **深度**: 階層的な情報構造

## Material Design
- **マテリアルメタファー**: 物理的な世界の概念を活用
- **大胆、グラフィカル、意図的**: 視覚的階層の重視
- **動きによる意味**: アニメーションで文脈を提供

## 学習中のトピック
- カラーパレットの選択
- タイポグラフィ
- アイコンデザイン
- レスポンシブデザイン
''',
    ),
  ];

  // すべての学習テーマを取得
  List<StudyTheme> getAllThemes() => List.unmodifiable(_themes);

  // 学習テーマを追加
  void addTheme(StudyTheme theme) {
    _themes.add(theme);
  }

  // 学習テーマを更新
  void updateTheme(StudyTheme updatedTheme) {
    final index = _themes.indexWhere((theme) => theme.id == updatedTheme.id);
    if (index != -1) {
      _themes[index] = updatedTheme;
    }
  }

  // 学習テーマを削除
  void deleteTheme(String themeId) {
    _themes.removeWhere((theme) => theme.id == themeId);
  }

  // IDで学習テーマを取得
  StudyTheme? getThemeById(String id) {
    try {
      return _themes.firstWhere((theme) => theme.id == id);
    } catch (e) {
      return null;
    }
  }

  // ステータスでフィルタリング
  List<StudyTheme> getThemesByStatus(StudyThemeStatus status) {
    return _themes.where((theme) => theme.status == status).toList();
  }

  // 検索機能
  List<StudyTheme> searchThemes(String query) {
    if (query.isEmpty) return List.from(_themes);
    return _themes.where((theme) => theme.matchesSearch(query)).toList();
  }
} 