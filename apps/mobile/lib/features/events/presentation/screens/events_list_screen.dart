import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../providers/event_provider.dart';
import '../../domain/entities/event.dart';

/// Écran liste des événements
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
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
      appBar: AppBar(
        title: const Text('Événements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
          ],
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading && eventProvider.events.isEmpty) {
            return const LoadingIndicator();
          }

          if (eventProvider.errorMessage != null) {
            return ErrorView(
              message: eventProvider.errorMessage!,
              onRetry: () => eventProvider.fetchEvents(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingEvents(eventProvider),
              _buildPastEvents(eventProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.createEvent);
        },
        icon: const Icon(Icons.add),
        label: const Text('Événement'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildUpcomingEvents(EventProvider eventProvider) {
    final upcomingEvents = eventProvider.upcomingEvents;

    if (upcomingEvents.isEmpty) {
      return EmptyState(
        icon: Icons.event_available,
        title: 'Aucun événement à venir',
        message: 'Créez votre premier événement pour commencer !',
        actionLabel: 'Créer un événement',
        onAction: () {
          Navigator.of(context).pushNamed(AppRoutes.createEvent);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => eventProvider.fetchEvents(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: upcomingEvents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = upcomingEvents[index];
          return _EventCard(
            event: event,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.eventDetailPath(event.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildPastEvents(EventProvider eventProvider) {
    final pastEvents = eventProvider.pastEvents;

    if (pastEvents.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        title: 'Aucun événement passé',
        message: 'Vos événements terminés apparaîtront ici',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pastEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = pastEvents[index];
        return _EventCard(
          event: event,
          isPast: true,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.eventDetailPath(event.id));
          },
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isPast;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    this.isPast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isPast ? AppColors.textSecondary : null,
                      ),
                    ),
                  ),
                  if (isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Terminé',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    _StatusBadge(status: event.status),
                ],
              ),
              if (event.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  event.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatEventDate(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (event.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _ParticipationChip(
                    icon: Icons.check_circle,
                    label: '${event.confirmedCount}',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  _ParticipationChip(
                    icon: Icons.help_outline,
                    label: '${event.maybeIds.length}',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _ParticipationChip(
                    icon: Icons.cancel,
                    label: '${event.declinedIds.length}',
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatEventDate() {
    if (event.startDate == null) return 'Date à définir';

    final formatter = DateFormat('EEE d MMM', 'fr_FR');
    final timeFormatter = DateFormat('HH:mm');

    if (event.endDate != null) {
      final isSameDay =
          event.startDate!.year == event.endDate!.year &&
          event.startDate!.month == event.endDate!.month &&
          event.startDate!.day == event.endDate!.day;

      if (isSameDay) {
        return '${formatter.format(event.startDate!)} · ${timeFormatter.format(event.startDate!)} - ${timeFormatter.format(event.endDate!)}';
      } else {
        return '${formatter.format(event.startDate!)} - ${formatter.format(event.endDate!)}';
      }
    }

    return '${formatter.format(event.startDate!)} à ${timeFormatter.format(event.startDate!)}';
  }
}

class _StatusBadge extends StatelessWidget {
  final EventStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case EventStatus.planned:
        color = AppColors.primary;
        label = 'Planifié';
        break;
      case EventStatus.confirmed:
        color = AppColors.secondary;
        label = 'Confirmé';
        break;
      case EventStatus.cancelled:
        color = AppColors.error;
        label = 'Annulé';
        break;
      case EventStatus.completed:
        color = AppColors.textSecondary;
        label = 'Terminé';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _ParticipationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ParticipationChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
