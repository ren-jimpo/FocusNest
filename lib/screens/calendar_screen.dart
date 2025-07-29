import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'task_edit_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Task>> _selectedTasks;
  final TaskService _taskService = TaskService();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Task>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedTasks = ValueNotifier(_getTasksForDay(_selectedDay));
    _loadTasks();
  }

  @override
  void dispose() {
    _selectedTasks.dispose();
    super.dispose();
  }

  void _loadTasks() {
    final allTasks = _taskService.getAllTasks();
    final Map<DateTime, List<Task>> tasksByDate = {};
    
    for (final task in allTasks) {
      if (task.dueDate != null) {
        final date = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if (tasksByDate[date] == null) {
          tasksByDate[date] = [];
        }
        tasksByDate[date]!.add(task);
      }
    }
    
    setState(() {
      _tasksByDate = tasksByDate;
    });
  }

  List<Task> _getTasksForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _tasksByDate[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedTasks.value = _getTasksForDay(selectedDay);
    }
  }

  void _navigateToTaskEdit({Task? task}) {
    showCupertinoModalPopup<Task>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 60, 16, 40),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemGroupedBackground,
            child: TaskEditScreen(task: task),
          ),
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
        _selectedTasks.value = _getTasksForDay(_selectedDay);
      }
    });
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return CupertinoColors.systemGrey;
      case TaskStatus.inProgress:
        return CupertinoColors.systemBlue;
      case TaskStatus.done:
        return CupertinoColors.systemGreen;
    }
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('カレンダー'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _navigateToTaskEdit(),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // カレンダー部分
            Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              padding: const EdgeInsets.all(20),
              height: 450, // 高さを確保
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoColors.systemGrey5,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey6.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getTasksForDay,
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: const CalendarStyle(
                  // Apple風のスタイル設定
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(
                    color: CupertinoColors.systemRed,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: CupertinoColors.systemOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(
                    CupertinoIcons.chevron_left,
                    color: CupertinoColors.systemBlue,
                  ),
                  rightChevronIcon: Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ),
            ),
            
            // 選択された日のタスク一覧
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        DateFormat('M月d日(E)', 'ja_JP').format(_selectedDay),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<List<Task>>(
                        valueListenable: _selectedTasks,
                        builder: (context, tasks, _) {
                          if (tasks.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar_badge_plus,
                                    size: 64,
                                    color: CupertinoColors.systemGrey3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'この日にタスクはありません',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
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
                                        
                                        // タスク情報
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: CupertinoColors.label,
                                                  decoration: task.status == TaskStatus.done
                                                      ? TextDecoration.lineThrough
                                                      : null,
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
                                                  // ステータス
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getTaskStatusColor(task.status)
                                                          .withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      task.status.displayName,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: _getTaskStatusColor(task.status),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // 時間
                                                  if (task.dueDate != null) ...[
                                                    Icon(
                                                      CupertinoIcons.time,
                                                      size: 12,
                                                      color: CupertinoColors.systemGrey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      DateFormat('HH:mm').format(task.dueDate!),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: CupertinoColors.systemGrey,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 