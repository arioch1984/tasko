import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/data/providers.dart';
import 'package:tasko/domain/models.dart';

TaskItem _task(String id, DateTime? due) {
  return TaskItem(id: id, listId: 'list', title: id, dueDate: due);
}

void main() {
  final now = DateTime(2026, 8, 19, 15, 30);
  final tasks = [
    _task('overdue', DateTime(2026, 8, 18)),
    _task('today', DateTime(2026, 8, 19)),
    _task('tomorrow', DateTime(2026, 8, 20)),
    _task('week', DateTime(2026, 8, 26)),
    _task('later', DateTime(2026, 8, 27)),
    _task('undated', null),
  ];

  test('combined Today includes overdue and today only', () {
    final visible = tasksForToday(tasks, now, includeOverdue: true);
    expect(visible.map((t) => t.id), ['overdue', 'today']);
  });

  test('split Today is due today only', () {
    final visible = tasksForToday(tasks, now, includeOverdue: false);
    expect(visible.map((t) => t.id), ['today']);
  });

  test('overdue list is strictly before today', () {
    expect(tasksOverdue(tasks, now).map((t) => t.id), ['overdue']);
  });

  test('upcoming is the next 7 days excluding today', () {
    expect(
      tasksUpcoming(tasks, now).map((t) => t.id),
      ['tomorrow', 'week'],
    );
  });
}
