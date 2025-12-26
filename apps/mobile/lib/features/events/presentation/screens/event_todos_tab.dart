import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/user/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../groups/presentation/providers/group_provider.dart';
import '../providers/todo_list_provider.dart';
import '../providers/event_provider.dart';
import '../../domain/entities/todo_list.dart';
import '../../domain/entities/todo_task.dart';
import '../widgets/todo_list_card.dart';

/// Écran affichant les TODO lists d'un événement
class EventTodosTab extends StatefulWidget {
  final String eventId;
  final VoidCallback? onAddTodo;

  const EventTodosTab({super.key, required this.eventId, this.onAddTodo});

  @override
  State<EventTodosTab> createState() => EventTodosTabState();
}

class EventTodosTabState extends State<EventTodosTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TodoListProvider>().fetchTodoLists(widget.eventId),
    );
  }

  // Méthode publique pour afficher le dialogue depuis l'extérieur
  void showTodoDetailDialog([TodoList? todoList]) {
    _showTodoDetailDialog(todoList);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoListProvider>(
      builder: (context, todoProvider, _) {
        final todos = todoProvider.getTodoListsByEvent(widget.eventId);

        print('EventTodosTab: eventId=${widget.eventId}');
        print(
          'EventTodosTab: todoProvider.todoLists.length=${todoProvider.todoLists.length}',
        );
        print('EventTodosTab: todos.length=${todos.length}');
        print('EventTodosTab: isLoading=${todoProvider.isLoading}');
        print('EventTodosTab: error=${todoProvider.error}');

        if (todoProvider.isLoading && todos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.checklist_outlined,
                  size: 80,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune TODO',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seul le créateur peut ajouter une TODO',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Limiter à une seule TODO par événement
        if (todos.length > 1) {
          print(
            '⚠️ AVERTISSEMENT: ${todos.length} TODOs trouvées pour cet événement, seule la première sera affichée',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 1, // Afficher uniquement la première TODO
          itemBuilder: (context, index) {
            final todo = todos[index];
            return TodoListCard(
              todoList: todo,
              onTap: () => _showTodoDetailDialog(todo),
              onDelete: () => _deleteTodo(todo.id),
            );
          },
        );
      },
    );
  }

  Future<void> _showTodoDetailDialog([TodoList? todoList]) async {
    final titleController = TextEditingController(text: todoList?.title);
    final descController = TextEditingController(text: todoList?.description);
    List<TodoTask> tasks = todoList?.tasks.toList() ?? [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(todoList == null ? 'Nouvelle TODO' : 'Modifier la TODO'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre *',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tâches (${tasks.length})',
                        style: AppTextStyles.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final newTask = await _showTaskDialog(context);
                          if (newTask != null) {
                            setState(() => tasks.add(newTask));
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (tasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Aucune tâche',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...tasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            task.status == TaskStatus.completed
                                ? Icons.check_circle
                                : task.status == TaskStatus.inProgress
                                ? Icons.pending
                                : Icons.radio_button_unchecked,
                            color: task.status == TaskStatus.completed
                                ? AppColors.success
                                : task.status == TaskStatus.inProgress
                                ? AppColors.info
                                : AppColors.textSecondary,
                          ),
                          title: Text(task.title),
                          subtitle: task.assignedTo.isNotEmpty
                              ? Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Assigné(s) à : ',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    ...task.assignedTo.map(
                                      (userId) => UserName(
                                        userId: userId,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final updatedTask = await _showTaskDialog(
                                    context,
                                    task,
                                  );
                                  if (updatedTask != null) {
                                    setState(() => tasks[index] = updatedTask);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: AppColors.error,
                                onPressed: () {
                                  setState(() => tasks.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => _saveTodoList(
                todoList,
                titleController.text,
                descController.text,
                tasks,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<TodoTask?> _showTaskDialog(
    BuildContext context, [
    TodoTask? task,
  ]) async {
    final titleController = TextEditingController(text: task?.title);
    final descController = TextEditingController(text: task?.description);
    TaskStatus selectedStatus = task?.status ?? TaskStatus.notStarted;
    List<String> selectedMembers = task?.assignedTo.toList() ?? [];

    // Récupérer les membres du groupe de l'événement
    final event = context.read<EventProvider>().events.firstWhere(
      (e) => e.id == widget.eventId,
    );
    final group = context.read<GroupProvider>().groups.firstWhere(
      (g) => g.id == event.groupId,
    );

    return await showDialog<TodoTask>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(task == null ? 'Nouvelle tâche' : 'Modifier la tâche'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    prefixIcon: Icon(Icons.task),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    );
                  }).toList(),
                  onChanged: (status) {
                    if (status != null) {
                      setState(() => selectedStatus = status);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text('Assigner à:', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                ...group.memberIds.map((memberId) {
                  final isSelected = selectedMembers.contains(memberId);
                  return CheckboxListTile(
                    title: UserName(userId: memberId),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedMembers.add(memberId);
                        } else {
                          selectedMembers.remove(memberId);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le titre est requis')),
                  );
                  return;
                }

                final now = DateTime.now();
                final newTask = TodoTask(
                  id: task?.id ?? const Uuid().v4(),
                  title: titleController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  assignedTo: selectedMembers,
                  status: selectedStatus,
                  dueDate: null,
                  createdAt: task?.createdAt ?? now,
                  updatedAt: now,
                );

                Navigator.pop(context, newTask);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTodoList(
    TodoList? existingTodo,
    String title,
    String description,
    List<TodoTask> tasks,
  ) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le titre est requis')));
      return;
    }

    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    final now = DateTime.now();

    final todoList = TodoList(
      id: existingTodo?.id ?? const Uuid().v4(),
      eventId: widget.eventId,
      title: title.trim(),
      description: description.trim().isEmpty ? null : description.trim(),
      tasks: tasks,
      createdBy: existingTodo?.createdBy ?? userId,
      createdAt: existingTodo?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (existingTodo == null) {
        await context.read<TodoListProvider>().addTodoList(todoList);
      } else {
        await context.read<TodoListProvider>().updateTodoList(todoList);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _deleteTodo(String todoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la TODO'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette liste de tâches ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<TodoListProvider>().deleteTodoList(todoId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }
}
