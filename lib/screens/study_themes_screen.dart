import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/study_theme.dart';
import '../models/task.dart';
import '../services/study_theme_service.dart';
import '../services/task_service.dart';
import 'study_theme_edit_screen.dart';
import 'study_theme_detail_screen.dart';

class StudyThemesScreen extends StatefulWidget {
  const StudyThemesScreen({super.key});

  @override
  State<StudyThemesScreen> createState() => _StudyThemesScreenState();
}

class _StudyThemesScreenState extends State<StudyThemesScreen> {
  final StudyThemeService _themeService = StudyThemeService();
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();
  
  List<StudyTheme> _filteredThemes = [];
  String _searchQuery = '';
  StudyThemeStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadThemes();
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

  void _loadThemes() {
    setState(() {
      _applyFilters();
    });
  }

  void _applyFilters() {
    // 変更可能なリストとして取得
    List<StudyTheme> themes = List.from(_themeService.getAllThemes());

    // 検索フィルタを適用
    if (_searchQuery.isNotEmpty) {
      themes = _themeService.searchThemes(_searchQuery);
    }

    // ステータスフィルタを適用
    if (_statusFilter != null) {
      themes = themes.where((theme) => theme.status == _statusFilter).toList();
    }

    // 更新日時順にソート（新しいものから）
    themes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    _filteredThemes = themes;
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
          ...StudyThemeStatus.values.map((status) =>
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

  void _clearAllFilters() {
    setState(() {
      _statusFilter = null;
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _navigateToThemeEdit({StudyTheme? theme}) {
    showCupertinoModalPopup<StudyTheme>(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: CupertinoPageScaffold(
          child: StudyThemeEditScreen(theme: theme),
        ),
      ),
    ).then((result) {
      if (result != null) {
        if (theme == null) {
          _themeService.addTheme(result);
        } else {
          _themeService.updateTheme(result);
        }
        _loadThemes();
      }
    });
  }

  void _navigateToThemeDetail(StudyTheme theme) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => StudyThemeDetailScreen(theme: theme),
      ),
    );
    _loadThemes(); // テーマが更新された可能性があるためリロード
  }

  void _deleteTheme(StudyTheme theme) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('学習テーマを削除'),
        content: Text('「${theme.title}」を削除しますか？\n関連するタスクは残りますが、テーマとの関連付けが解除されます。'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _themeService.deleteTheme(theme.id);
              _loadThemes();
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
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

  Widget _buildFilterChips() {
    if (_statusFilter == null) return const SizedBox.shrink();

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: CupertinoColors.systemGrey5,
              minimumSize: Size.zero,
              onPressed: () => setState(() {
                _statusFilter = null;
                _applyFilters();
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ステータス: ${_statusFilter!.displayName}',
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('学習テーマ'),
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
              onPressed: () => _navigateToThemeEdit(),
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
                placeholder: '学習テーマを検索...',
              ),
            ),
            
            // フィルタチップ
            _buildFilterChips(),
            
            // 学習テーマ一覧
            Expanded(
              child: _filteredThemes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.book,
                            size: 64,
                            color: CupertinoColors.systemGrey3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '学習テーマがありません',
                            style: TextStyle(
                              fontSize: 18,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredThemes.length,
                      itemBuilder: (context, index) {
                        final theme = _filteredThemes[index];
                        return _buildThemeTile(theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(StudyTheme theme) {
    final relatedTasks = _taskService.getTasksByThemeId(theme.id);
    final completedTasks = relatedTasks.where((task) => task.status == TaskStatus.done).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        onPressed: () => _navigateToThemeDetail(theme),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー行
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ステータスインジケーター
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getStatusColor(theme.status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // メインコンテンツ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // タイトル
                        Text(
                          theme.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // 説明
                        if (theme.description.isNotEmpty)
                          Text(
                            theme.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // アクションボタン
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showThemeActions(theme),
                    child: const Icon(
                      CupertinoIcons.ellipsis,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // ステータスと統計情報
              Row(
                children: [
                  // ステータスバッジ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(theme.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      theme.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(theme.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 関連タスク数
                  if (relatedTasks.isNotEmpty) ...[
                    Icon(
                      CupertinoIcons.doc_text,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$completedTasks / ${relatedTasks.length} タスク',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // 最終更新日
                  Text(
                    '更新: ${DateFormat('M/d').format(theme.updatedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
              
              // プログレスバー（関連タスクがある場合）
              if (relatedTasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: relatedTasks.isEmpty ? 0 : completedTasks / relatedTasks.length,
                    backgroundColor: CupertinoColors.systemGrey5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(theme.status),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeActions(StudyTheme theme) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToThemeDetail(theme);
            },
            child: const Text('詳細を表示'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToThemeEdit(theme: theme);
            },
            child: const Text('編集'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              final updatedTheme = theme.copyWith(
                status: _getNextStatus(theme.status),
              );
              _themeService.updateTheme(updatedTheme);
              _loadThemes();
            },
            child: Text(_getStatusActionText(theme.status)),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteTheme(theme);
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

  StudyThemeStatus _getNextStatus(StudyThemeStatus currentStatus) {
    switch (currentStatus) {
      case StudyThemeStatus.notStarted:
        return StudyThemeStatus.studying;
      case StudyThemeStatus.studying:
        return StudyThemeStatus.done;
      case StudyThemeStatus.done:
        return StudyThemeStatus.notStarted;
    }
  }

  String _getStatusActionText(StudyThemeStatus currentStatus) {
    switch (currentStatus) {
      case StudyThemeStatus.notStarted:
        return '学習開始';
      case StudyThemeStatus.studying:
        return '完了にする';
      case StudyThemeStatus.done:
        return '未着手に戻す';
    }
  }
} 