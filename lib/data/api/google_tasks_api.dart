import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tasko/core/constants.dart';

class GoogleTasksApiException implements Exception {
  GoogleTasksApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'GoogleTasksApiException($statusCode): $body';
}

/// Thin REST client for Google Tasks API v1.
class GoogleTasksApi {
  GoogleTasksApi({
    required this.getAccessToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final Future<String?> Function() getAccessToken;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${AppConstants.tasksBaseUrl}$path').replace(
      queryParameters: query,
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final response = await _client.get(
      _uri(path, query),
      headers: await _headers(),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final response = await _client.post(
      _uri(path, query),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _patch(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.patch(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<void> _delete(String path) async {
    final response = await _client.delete(
      _uri(path),
      headers: await _headers(),
    );
    if (response.statusCode >= 400) {
      throw GoogleTasksApiException(response.statusCode, response.body);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode >= 400) {
      throw GoogleTasksApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listTaskLists() async {
    final items = <Map<String, dynamic>>[];
    String? pageToken;
    do {
      final json = await _get('/users/@me/lists', {
        'maxResults': '100',
        if (pageToken != null) 'pageToken': pageToken,
      });
      final page = (json['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      items.addAll(page);
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null);
    return items;
  }

  Future<Map<String, dynamic>> insertTaskList(String title) {
    return _post('/users/@me/lists', body: {'title': title});
  }

  Future<void> deleteTaskList(String taskListId) {
    return _delete('/users/@me/lists/$taskListId');
  }

  Future<List<Map<String, dynamic>>> listTasks(
    String taskListId, {
    bool showCompleted = true,
    bool showHidden = false,
  }) async {
    final items = <Map<String, dynamic>>[];
    String? pageToken;
    do {
      final json = await _get('/lists/$taskListId/tasks', {
        'maxResults': '100',
        'showCompleted': '$showCompleted',
        'showHidden': '$showHidden',
        if (pageToken != null) 'pageToken': pageToken,
      });
      final page = (json['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      items.addAll(page);
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null);
    return items;
  }

  Future<Map<String, dynamic>> insertTask(
    String taskListId,
    Map<String, dynamic> body, {
    String? parent,
    String? previous,
  }) {
    return _post(
      '/lists/$taskListId/tasks',
      body: body,
      query: {
        if (parent != null) 'parent': parent,
        if (previous != null) 'previous': previous,
      },
    );
  }

  Future<Map<String, dynamic>> patchTask(
    String taskListId,
    String taskId,
    Map<String, dynamic> body,
  ) {
    return _patch('/lists/$taskListId/tasks/$taskId', body: body);
  }

  Future<void> deleteTask(String taskListId, String taskId) {
    return _delete('/lists/$taskListId/tasks/$taskId');
  }

  Future<Map<String, dynamic>> moveTask(
    String taskListId,
    String taskId, {
    String? parent,
    String? previous,
    String? destinationTasklist,
  }) {
    return _post(
      '/lists/$taskListId/tasks/$taskId/move',
      query: {
        if (parent != null) 'parent': parent,
        if (previous != null) 'previous': previous,
        if (destinationTasklist != null)
          'destinationTasklist': destinationTasklist,
      },
    );
  }

  void close() => _client.close();
}
