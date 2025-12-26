import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../../../../shared/widgets/user/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../groups/presentation/providers/group_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        final groupProvider = context.read<GroupProvider>();

        // Charger les groupes d'abord si nécessaire
        if (groupProvider.groups.isEmpty) {
          await groupProvider.fetchGroups(userId);
        }

        final userGroupIds = groupProvider.groups.map((g) => g.id).toList();
        print(
          'EventsListScreen: Chargement des événements pour userId=$userId',
        );
        print('EventsListScreen: Groupes de l\'utilisateur: $userGroupIds');

        await context.read<EventProvider>().fetchEvents(
          userId: userId,
          userGroupIds: userGroupIds,
        );
      }
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
            Tab(text: 'Actifs'),
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
              onRetry: () {
                final userId = context.read<AuthProvider>().currentUser?.id;
                if (userId != null) {
                  final groupProvider = context.read<GroupProvider>();
                  final userGroupIds = groupProvider.groups
                      .map((g) => g.id)
                      .toList();
                  eventProvider.fetchEvents(
                    userId: userId,
                    userGroupIds: userGroupIds,
                  );
                }
              },
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
        heroTag: 'events_create_fab',
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
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    final upcomingEvents = eventProvider.getUpcomingEventsForUser(userId);

    if (upcomingEvents.isEmpty) {
      return EmptyState(
        icon: Icons.event_available,
        title: 'Aucun événement actif',
        subtitle: 'Créez votre premier événement pour commencer !',
        actionLabel: 'Créer un événement',
        onAction: () {
          Navigator.of(context).pushNamed(AppRoutes.createEvent);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        final userId = context.read<AuthProvider>().currentUser?.id;
        if (userId != null) {
          final groupProvider = context.read<GroupProvider>();
          final userGroupIds = groupProvider.groups.map((g) => g.id).toList();
          return eventProvider.fetchEvents(
            userId: userId,
            userGroupIds: userGroupIds,
          );
        }
        return Future.value();
      },
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
        subtitle: 'Vos événements terminés apparaîtront ici',
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
    final eventIcon = _getEventIcon();

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/bannière événement en haut
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPast
                          ? [
                              Colors.grey.withValues(alpha: 0.3),
                              Colors.grey.withValues(alpha: 0.2),
                            ]
                          : [
                              AppColors.primary.withValues(alpha: 0.3),
                              AppColors.secondary.withValues(alpha: 0.3),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      eventIcon,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
                // Badge statut
                Positioned(
                  top: 12,
                  right: 12,
                  child: isPast
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Terminé',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : _StatusBadge(status: _getEventDisplayStatus(event)),
                ),
              ],
            ),
            // Infos en dessous
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Créé par ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: UserName(
                          userId: event.creatorId,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
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
                        const Icon(
                          Icons.location_on,
                          size: 14,
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
          ],
        ),
      ),
    );
  }

  String _getEventIcon() {
    final title = event.title.toLowerCase();
    if (title.contains('montagne') || title.contains('ski')) return '⛷️';
    if (title.contains('jeu')) return '🎮';
    if (title.contains('resto') || title.contains('dîner')) return '🍽️';
    if (title.contains('sport')) return '⚽';
    if (title.contains('cinéma') || title.contains('film')) return '🎬';
    if (title.contains('soirée')) return '🎉';
    return '📅';
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
      case EventStatus.draft:
        color = Colors.grey;
        label = 'Brouillon';
        break;
      case EventStatus.planned:
        color = AppColors.primary;
        label = 'Planifié';
        break;
      case EventStatus.ongoing:
        color = AppColors.secondary;
        label = 'En cours';
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

/// Calculer le statut d'affichage d'un événement
EventStatus _getEventDisplayStatus(Event event) {
  final now = DateTime.now();
  final startDate = event.startDate ?? event.createdAt;
  final endDate = event.endDate;

  // Si annulé ou brouillon, garder le statut original
  if (event.status == EventStatus.cancelled ||
      event.status == EventStatus.draft) {
    return event.status;
  }

  // Si la date de fin existe
  if (endDate != null) {
    // Événement terminé
    if (endDate.isBefore(now)) {
      return EventStatus.completed;
    }
    // Événement en cours (a commencé mais pas fini)
    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      return EventStatus.ongoing;
    }
    // Événement à venir
    return EventStatus.planned;
  }

  // Si pas de date de fin, se baser sur la date de début
  if (startDate.isBefore(now)) {
    return EventStatus.completed;
  }

  return EventStatus.planned;
}
