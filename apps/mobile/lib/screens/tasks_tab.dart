import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TasksTab extends StatefulWidget {
  final String eventId;

  const TasksTab({super.key, required this.eventId});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final TaskService _service = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _service.getEventTasks(widget.eventId);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final todoTasks = _tasks.where((t) => t.status == TaskStatus.todo).toList();
    final inProgressTasks = _tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .toList();
    final completedTasks = _tasks
        .where((t) => t.status == TaskStatus.completed)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add_task),
            label: const Text('Créer une tâche'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (todoTasks.isNotEmpty) ...[
                const _SectionHeader(title: 'À faire', color: Colors.orange),
                ...todoTasks.map(
                  (task) => _TaskCard(
                    task: task,
                    onStatusChange: (status) =>
                        _updateTaskStatus(task.id, status),
                    onDelete: () => _deleteTask(task.id),
                  ),
                ),
              ],
              if (inProgressTasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _SectionHeader(title: 'En cours', color: Colors.blue),
                ...inProgressTasks.map(
                  (task) => _TaskCard(
                    task: task,
                    onStatusChange: (status) =>
                        _updateTaskStatus(task.id, status),
                    onDelete: () => _deleteTask(task.id),
                  ),
                ),
              ],
              if (completedTasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _SectionHeader(title: 'Terminées', color: Colors.green),
                ...completedTasks.map(
                  (task) => _TaskCard(
                    task: task,
                    onStatusChange: (status) =>
                        _updateTaskStatus(task.id, status),
                    onDelete: () => _deleteTask(task.id),
                  ),
                ),
              ],
              if (_tasks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Aucune tâche'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une tâche'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                // TODO: Create task
                Navigator.pop(context);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _service.updateTaskStatus(widget.eventId, taskId, status);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _service.deleteTask(widget.eventId, taskId);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final Function(TaskStatus) onStatusChange;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.status == TaskStatus.completed,
          onChanged: (value) {
            onStatusChange(
              value == true ? TaskStatus.completed : TaskStatus.todo,
            );
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == TaskStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _PriorityBadge(priority: task.priority),
                if (task.assignedToName != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.person, size: 16),
                    label: Text(task.assignedToName!),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            if (task.status != TaskStatus.inProgress)
              const PopupMenuItem(
                value: 'in_progress',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('En cours'),
                  ],
                ),
              ),
            if (task.status != TaskStatus.completed)
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Terminer'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'in_progress') {
              onStatusChange(TaskStatus.inProgress);
            } else if (value == 'completed') {
              onStatusChange(TaskStatus.completed);
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        label = 'Basse';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = 'Moyenne';
        break;
      case TaskPriority.high:
        color = Colors.red;
        label = 'Haute';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
