import 'package:flutter/cupertino.dart';
import 'screens/tasks_screen.dart';
import 'screens/study_themes_screen.dart';

void main() {
  runApp(const FocusNestApp());
}

class FocusNestApp extends StatelessWidget {
  const FocusNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'FocusNest',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: MainTabView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.checkmark_square),
            activeIcon: Icon(CupertinoIcons.checkmark_square_fill),
            label: 'タスク',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            activeIcon: Icon(CupertinoIcons.book_fill),
            label: '学習テーマ',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const TasksScreen();
          case 1:
            return const StudyThemesScreen();
          default:
            return const TasksScreen();
        }
      },
    );
  }
}
