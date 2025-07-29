import 'package:flutter/cupertino.dart';
import '../models/study_theme.dart';

class StudyThemeEditScreen extends StatefulWidget {
  final StudyTheme? theme;

  const StudyThemeEditScreen({super.key, this.theme});

  @override
  State<StudyThemeEditScreen> createState() => _StudyThemeEditScreenState();
}

class _StudyThemeEditScreenState extends State<StudyThemeEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  
  late StudyThemeStatus _status;

  @override
  void initState() {
    super.initState();
    
    if (widget.theme != null) {
      _titleController = TextEditingController(text: widget.theme!.title);
      _descriptionController = TextEditingController(text: widget.theme!.description);
      _notesController = TextEditingController(text: widget.theme!.notes);
      _status = widget.theme!.status;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _notesController = TextEditingController();
      _status = StudyThemeStatus.notStarted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveTheme() {
    if (_titleController.text.trim().isEmpty) {
      _showAlert('エラー', 'タイトルを入力してください。');
      return;
    }

    final theme = StudyTheme(
      id: widget.theme?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      notes: _notesController.text.trim(),
      createdAt: widget.theme?.createdAt,
    );

    Navigator.pop(context, theme);
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

  void _showStatusPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('ステータスを選択'),
        actions: StudyThemeStatus.values.map((status) =>
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _status = status;
              });
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.theme != null ? '学習テーマを編集' : '新しい学習テーマ'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveTheme,
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
                placeholder: '学習テーマのタイトルを入力',
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 説明
            _buildSection(
              '概要・説明',
              CupertinoTextFormFieldRow(
                controller: _descriptionController,
                placeholder: '学習テーマの概要や目標を入力（任意）',
                maxLines: 3,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getStatusColor(_status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_status.displayName),
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
            
            // 学習ノート
            _buildSection(
              '学習ノート',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Markdown記法をサポート予定',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(minHeight: 150),
                    child: CupertinoTextFormFieldRow(
                      controller: _notesController,
                      placeholder: '学習内容、メモ、進捗などを自由に記録してください...\n\n例：\n# 今日の学習\n- 基本概念の理解\n- 実装練習\n\n## 次回予定\n- 応用問題に挑戦',
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ヒント
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.lightbulb,
                        size: 16,
                        color: CupertinoColors.systemBlue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '学習ノートの活用法',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 学習目標と進捗を記録\n'
                    '• 重要なポイントやメモを整理\n'
                    '• 疑問点や調べたいことをリスト化\n'
                    '• 参考資料のリンクを保存\n'
                    '• 学習時間や成果を振り返り',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemBlue,
                      height: 1.4,
                    ),
                  ),
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