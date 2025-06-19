import 'package:flutter/material.dart';

import '../model/taskes.dart';
import '../services/data_base.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataBaseService _databaseService = DataBaseService.instance;
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahmed app'),
        centerTitle: true,
      ),
      floatingActionButton: _addTaskButton(context),
      body: _tasksList(),
    );
  }

  Widget _addTaskButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final taskContent = _taskController.text.trim();
                  if (taskContent.isEmpty) return;

                  // FIX 2: Pop the dialog FIRST, before the async gap.
                  Navigator.pop(context);

                  // Now perform the database operation.
                  await _databaseService.addTask(taskContent);

                  // Then update the UI.
                  setState(() {
                    _taskController.clear();
                  });
                },
                child: const Text("Done"),
              ),
            ],
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _tasksList() {
    return FutureBuilder<List<Task>>(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<Task> tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: task.status == 1,
                    onChanged: (value) async {
                      await _databaseService.updateTaskStatus(task.id, value! ? 1 : 0);
                      setState(() {});
                    },
                  ),
                  title: Text(
                    task.content,
                    style: TextStyle(
                      decoration: task.status == 1
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    // FIX 3: Added a tooltip for better accessibility.
                    tooltip: 'Delete Task',
                    onPressed: () async {
                      await _databaseService.deleteTask(task.id);
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          );
        }
        return const Center(
          child: Text('No tasks yet. Add one!'),
        );
      },
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}