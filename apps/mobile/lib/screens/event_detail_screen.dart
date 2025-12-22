import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import 'participants_tab.dart';
import 'tasks_tab.dart';
import 'budget_tab.dart';
import 'votes_tab.dart';
import 'media_tab.dart';
import '../features/events/presentation/screens/event_activities_tab.dart';
import '../features/events/presentation/screens/event_todos_tab.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild pour mettre à jour le FAB
    });
    Future.microtask(() {
      context.read<EventProvider>().loadEvent(widget.eventId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadEvent(widget.eventId),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final event = provider.currentEvent;
          if (event == null) {
            return const Center(child: Text('Événement non trouvé'));
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(event),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildEventInfo(event),
                    _buildSteps(event),
                    const Divider(),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      isScrollable: true,
                      tabs: const [
                        Tab(icon: Icon(Icons.people), text: 'Participants'),
                        Tab(
                          icon: Icon(Icons.event_available),
                          text: 'Activités',
                        ),
                        Tab(icon: Icon(Icons.checklist), text: 'TODO'),
                        Tab(icon: Icon(Icons.task_alt), text: 'Tâches'),
                        Tab(
                          icon: Icon(Icons.account_balance_wallet),
                          text: 'Budget',
                        ),
                        Tab(icon: Icon(Icons.how_to_vote), text: 'Votes'),
                        Tab(icon: Icon(Icons.photo_library), text: 'Médias'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ParticipantsTab(eventId: event.id),
                          EventActivitiesTab(eventId: event.id),
                          EventTodosTab(eventId: event.id),
                          TasksTab(eventId: event.id),
                          BudgetTab(eventId: event.id),
                          VotesTab(eventId: event.id),
                          MediaTab(eventId: event.id),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Event event) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3)],
          ),
        ),
        background: event.coverImageUrl != null
            ? Image.network(
                event.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.event, size: 64),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: const Icon(Icons.event, size: 64, color: Colors.white),
              ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share event
          },
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Modifier'),
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
            if (value == 'delete') {
              _showDeleteDialog(event.id);
            }
          },
        ),
      ],
    );
  }

  Widget _buildEventInfo(Event event) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.calendar_today,
                label: dateFormat.format(event.startDate),
              ),
              if (event.endDate != null)
                _InfoChip(
                  icon: Icons.event,
                  label: dateFormat.format(event.endDate!),
                ),
              _InfoChip(
                icon: Icons.people,
                label: '${event.participantIds.length} participants',
              ),
              _InfoChip(
                icon: Icons.category,
                label: _getEventTypeLabel(event.type),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSteps(Event event) {
    if (event.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Étapes',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: event.steps.length,
            itemBuilder: (context, index) {
              final step = event.steps[index];
              return _StepCard(step: step, index: index);
            },
          ),
        ),
      ],
    );
  }

  String _getEventTypeLabel(String type) {
    switch (type) {
      case 'weekend':
        return 'Week-end';
      case 'soiree':
        return 'Soirée';
      case 'citytrip':
        return 'City Trip';
      case 'vacation':
        return 'Vacances';
      default:
        return 'Autre';
    }
  }

  void _showDeleteDialog(String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'événement'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cet événement ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<EventProvider>().deleteEvent(eventId);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _StepCard extends StatelessWidget {
  final EventStep step;
  final int index;

  const _StepCard({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM HH:mm', 'fr_FR');

    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16, child: Text('${index + 1}')),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dateFormat.format(step.startDateTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (step.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      step.location!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
