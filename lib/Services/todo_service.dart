import 'dart:convert';
import '/controller/app_constants.dart';
import '/models/todo_task.dart';
import 'api_service.dart';

class ToDoService {
  final ApiService _apiService = ApiService();

  Future<List<ToDoTask>> fetchTasks() async {
    try {
      final response = await _apiService.authenticatedGet(
        AppConstants.getAttendanceEndpoint,
        queryParams: {'model': 'todo.task'},
        sessionId: '',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => ToDoTask.fromJson(e)).toList();
        }
        throw Exception('Invalid response format: Expected a list');
      }
      throw Exception(
        'Failed to load tasks: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<ToDoTask> createTask(String title) async {
    try {
      final response = await _apiService.authenticatedPost(
        AppConstants.todoEndpoint,
        {'model': 'todo.task', 'name': title, 'is_done': false},
        sessionId: '',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ToDoTask.fromJson(data);
      }
      throw Exception(
        'Failed to create task: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final response = await _apiService.authenticatedPost(
        AppConstants.todoEndpoint, // Using existing endpoint
        {
          'model': 'todo.task', // Specify the model
          'method': 'unlink',
          'ids': [taskId],
        },
        sessionId: '',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete task: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<ToDoTask> toggleTaskCompletion(ToDoTask task) async {
    try {
      final response = await _apiService.authenticatedPost(
        AppConstants.todoEndpoint, // Using existing endpoint
        {
          'model': 'todo.task', // Specify the model
          'method': 'write',
          'ids': [task.id!],
          'is_done': !task.isCompleted, // Using 'is_done' as per Python model
        },
        sessionId: '',
      );

      if (response.statusCode == 200) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      throw Exception(
        'Failed to update task: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
