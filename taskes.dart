class Task {

  static const String tableName = 'tasks';
  static const String idColumn = 'id';
  static const String contentColumn = 'content';
  static const String statusColumn = 'status';

  final int id;
  final String content;
  final int status;

  Task({
    required this.id,
    required this.status,
    required this.content,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(

      id: map[idColumn],
      content: map[contentColumn],
      status: map[statusColumn],
    );
  }
}