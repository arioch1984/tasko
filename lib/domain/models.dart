import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TaskStatus { needsAction, completed }

enum SortMode { manual, dueDate, priority, title }

class TaskList extends Equatable {
  const TaskList({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  bool get isMeta => title == '__Tasko';

  @override
  List<Object?> get props => [id, title];
}

class TaskLabel extends Equatable {
  const TaskLabel({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int colorValue;

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': colorValue,
      };

  factory TaskLabel.fromJson(Map<String, dynamic> json) {
    return TaskLabel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['color'] as int,
    );
  }

  @override
  List<Object?> get props => [id, name, colorValue];
}

class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.listId,
    required this.title,
    this.notes = '',
    this.dueDate,
    this.status = TaskStatus.needsAction,
    this.parentId,
    this.position = '',
    this.priority = 4,
    this.labelIds = const [],
    this.updated,
  });

  final String id;
  final String listId;
  final String title;
  final String notes;
  final DateTime? dueDate;
  final TaskStatus status;
  final String? parentId;
  final String position;
  final int priority;
  final List<String> labelIds;
  final DateTime? updated;

  bool get isCompleted => status == TaskStatus.completed;
  bool get isSubtask => parentId != null;

  TaskItem copyWith({
    String? id,
    String? listId,
    String? title,
    String? notes,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskStatus? status,
    String? parentId,
    String? position,
    int? priority,
    List<String>? labelIds,
    DateTime? updated,
  }) {
    return TaskItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      status: status ?? this.status,
      parentId: parentId ?? this.parentId,
      position: position ?? this.position,
      priority: priority ?? this.priority,
      labelIds: labelIds ?? this.labelIds,
      updated: updated ?? this.updated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        listId,
        title,
        notes,
        dueDate,
        status,
        parentId,
        position,
        priority,
        labelIds,
        updated,
      ];
}
