import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/tasks/v1.dart' as gtasks;
import 'package:http/http.dart' as http;

class _AuthClient extends http.BaseClient {
  _AuthClient(this._inner, this._token);
  final http.Client _inner;
  final String _token;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

class GoogleTasksListData {
  const GoogleTasksListData({
    required this.listId,
    required this.name,
    required this.tasks,
  });
  final String listId;
  final String name;
  final List<GoogleTaskData> tasks;
}

class GoogleTaskData {
  const GoogleTaskData({
    required this.id,
    required this.title,
    required this.completed,
  });
  final String id;
  final String title;
  final bool completed;
}

class ZainoGoogleTasksService {
  static const _tasksScope = 'https://www.googleapis.com/auth/tasks';

  Future<T?> _withApi<T>(Future<T> Function(gtasks.TasksApi) fn) async {
    final signIn = GoogleSignIn.instance;
    _AuthClient? client;
    try {
      final auth = await signIn.authorizationClient.authorizeScopes([
        _tasksScope,
      ]);
      client = _AuthClient(http.Client(), auth.accessToken);
      return await fn(gtasks.TasksApi(client));
    } catch (_) {
      return null;
    } finally {
      client?.close();
    }
  }

  /// Fetches all Google Tasks lists whose title starts with '#'.
  Future<List<GoogleTasksListData>> fetchZainoLists() async {
    final result = await _withApi((api) async {
      final lists = <GoogleTasksListData>[];
      final response = await api.tasklists.list(maxResults: 100);
      for (final list in response.items ?? []) {
        final id = list.id;
        final title = list.title ?? '';
        if (id == null || !title.startsWith('#')) continue;

        final tasksResponse = await api.tasks.list(
          id,
          showCompleted: true,
          showHidden: true,
        );

        final tasks = <GoogleTaskData>[];
        for (final task in tasksResponse.items ?? []) {
          final taskId = task.id;
          final taskTitle = task.title;
          if (taskId == null || taskTitle == null || taskTitle.isEmpty)
            continue;
          tasks.add(
            GoogleTaskData(
              id: taskId,
              title: taskTitle,
              completed: task.status == 'completed',
            ),
          );
        }

        lists.add(
          GoogleTasksListData(
            listId: id,
            name: title.substring(1),
            tasks: tasks,
          ),
        );
      }
      return lists;
    });
    return result ?? [];
  }

  /// Creates a new Google Tasks list with '#' prefix. Returns the list ID.
  Future<String?> createList(String name) async {
    return _withApi<String?>((api) async {
      final list = await api.tasklists.insert(gtasks.TaskList(title: '#$name'));
      return list.id;
    });
  }

  /// Creates a task in a Google Tasks list. Returns the task ID.
  Future<String?> createTask(String listId, String title) async {
    return _withApi<String?>((api) async {
      final task = await api.tasks.insert(
        gtasks.Task(title: title, status: 'needsAction'),
        listId,
      );
      return task.id;
    });
  }

  /// Marks a task as completed or not completed.
  Future<void> setTaskCompleted(
    String listId,
    String taskId,
    bool completed,
  ) async {
    await _withApi(
      (api) => api.tasks.patch(
        gtasks.Task(
          status: completed ? 'completed' : 'needsAction',
          completed: completed
              ? DateTime.now().toUtc().toIso8601String()
              : null,
        ),
        listId,
        taskId,
      ),
    );
  }

  /// Marks all tasks in a list as not completed (reset).
  Future<void> resetAllTasks(String listId, List<String> taskIds) async {
    await _withApi((api) async {
      for (final taskId in taskIds) {
        try {
          await api.tasks.patch(
            gtasks.Task(status: 'needsAction', completed: null),
            listId,
            taskId,
          );
        } catch (_) {}
      }
    });
  }

  /// Deletes a task from a Google Tasks list.
  Future<void> deleteTask(String listId, String taskId) async {
    await _withApi((api) => api.tasks.delete(listId, taskId));
  }

  /// Renames a Google Tasks list (keeps the '#' prefix).
  Future<void> renameList(String listId, String newName) async {
    await _withApi(
      (api) => api.tasklists.patch(gtasks.TaskList(title: '#$newName'), listId),
    );
  }

  /// Deletes a Google Tasks list.
  Future<void> deleteList(String listId) async {
    await _withApi((api) => api.tasklists.delete(listId));
  }
}
