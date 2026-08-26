import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/data/repositories/tasks_repository.dart';

void main() {
  test('maps due date, metadata, and webViewLink', () {
    final task = taskItemFromGoogleJson(
      {
        'id': 't1',
        'title': 'Call',
        'notes': '[tasko]{"p":2,"l":["work"]}[/tasko]\nFollow up',
        'due': '2026-08-26T00:00:00.000Z',
        'status': 'needsAction',
        'position': '0001',
        'webViewLink': 'https://tasks.google.com/task/t1',
        'updated': '2026-08-26T10:00:00.000Z',
      },
      'list-1',
    );

    expect(task.id, 't1');
    expect(task.listId, 'list-1');
    expect(task.title, 'Call');
    expect(task.notes, 'Follow up');
    expect(task.priority, 2);
    expect(task.labelIds, ['work']);
    expect(task.dueDate, DateTime(2026, 8, 26));
    expect(task.webViewLink, 'https://tasks.google.com/task/t1');
  });

  test('treats missing or empty webViewLink as null', () {
    final missing = taskItemFromGoogleJson(
      {'id': 't1', 'title': 'A'},
      'list-1',
    );
    final empty = taskItemFromGoogleJson(
      {'id': 't1', 'title': 'A', 'webViewLink': ''},
      'list-1',
    );
    expect(missing.webViewLink, isNull);
    expect(empty.webViewLink, isNull);
  });
}
