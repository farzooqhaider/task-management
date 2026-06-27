import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';

class TaskService {
  static const String _tasksKey = 'tasks';

  // Load all tasks from SharedPreferences
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_tasksKey);
    if (tasksJson == null) return [];

    final List<dynamic> taskList = jsonDecode(tasksJson);
    return taskList.map((item) => Task.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  // Save all tasks to SharedPreferences
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(tasks.map((t) => t.toMap()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }

  // Add a new task
  static Future<List<Task>> addTask(List<Task> tasks, Task newTask) async {
    final updated = [...tasks, newTask];
    await saveTasks(updated);
    return updated;
  }

  // Delete a task by id
  static Future<List<Task>> deleteTask(List<Task> tasks, String id) async {
    final updated = tasks.where((t) => t.id != id).toList();
    await saveTasks(updated);
    return updated;
  }

  // Toggle task completion
  static Future<List<Task>> toggleTask(List<Task> tasks, String id) async {
    final updated = tasks.map((t) {
      if (t.id == id) {
        return Task(
          id: t.id,
          title: t.title,
          description: t.description,
          isCompleted: !t.isCompleted,
          createdAt: t.createdAt,
        );
      }
      return t;
    }).toList();
    await saveTasks(updated);
    return updated;
  }
}
