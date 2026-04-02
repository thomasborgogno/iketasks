import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/tasks/v1.dart' as gtasks;
import 'package:http/http.dart' as http;

import '../domain/google_task_item.dart';

/// Simple [http.BaseClient] that injects a Bearer access token.
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

class GoogleTasksRepository {
  static const tasksScope = 'https://www.googleapis.com/auth/tasks.readonly';

  /// Requests [tasksScope] via the v7 incremental authorization API, then
  /// fetches all incomplete tasks across all Google Task lists.
  Future<List<GoogleTaskItem>> fetchIncompleteTasks() async {
    final signIn = GoogleSignIn.instance;

    // authorizeScopes prompts the user if the scope is not yet granted.
    final auth = await signIn.authorizationClient.authorizeScopes([tasksScope]);
    final accessToken = auth.accessToken;

    final client = _AuthClient(http.Client(), accessToken);
    final api = gtasks.TasksApi(client);
    final result = <GoogleTaskItem>[];

    try {
      final taskLists = await api.tasklists.list();
      final lists = taskLists.items ?? [];

      for (final list in lists) {
        final listId = list.id;
        final listTitle = list.title ?? '';
        if (listId == null || listTitle.startsWith('#')) continue;

        final tasks = await api.tasks.list(
          listId,
          showCompleted: false,
          showHidden: false,
        );

        for (final task in tasks.items ?? []) {
          final id = task.id;
          final title = task.title;
          if (id == null || title == null || title.isEmpty) continue;

          DateTime? due;
          if (task.due != null) due = DateTime.tryParse(task.due!);

          result.add(
            GoogleTaskItem(
              id: id,
              title: title,
              taskListId: listId,
              taskListTitle: listTitle,
              notes: task.notes,
              due: due,
            ),
          );
        }
      }
    } finally {
      client.close();
    }

    return result;
  }
}
