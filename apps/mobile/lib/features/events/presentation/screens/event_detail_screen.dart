import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../../domain/entities/event.dart';

/// Écran détail d'un événement
class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, eventProvider, authProvider, child) {
        final event = eventProvider.events.firstWhere(
          (e) => e.id == eventId,
          orElse: () => eventProvider.events.first,
        );

        final userId = authProvider.currentUser?.id ?? 'user_1';
        final isCreator = event.creatorId == userId;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, event, isCreator),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (event.description != null) ...[
                        Text('Description', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          event.description!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Informations
                      Text('Informations', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: _formatEventDate(event),
                      ),
                      if (event.location != null)
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Lieu',
                          value: event.location!,
                        ),
                      _InfoRow(
                        icon: Icons.event_available,
                        label: 'Statut',
                        value: _getStatusLabel(event.status),
                      ),
                      const SizedBox(height: 24),

                      // Participation
                      Text('Ma réponse', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                      _ParticipationButtons(event: event, userId: userId),
                      const SizedBox(height: 24),

                      // Statistiques de participation
                      Text('Participants', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle,
                              label: 'Confirmés',
                              value: '${event.confirmedCount}',
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.help_outline,
                              label: 'Peut-être',
                              value: '${event.maybeIds.length}',
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.cancel,
                              label: 'Refusés',
                              value: '${event.declinedIds.length}',
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Liste des participants confirmés
                      if (event.participantIds.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Confirmés (${event.confirmedCount})',
                              style: AppTextStyles.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: event.participantIds.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return _ParticipantAvatar(
                                userId: event.participantIds[index],
                                isCreator:
                                    event.participantIds[index] ==
                                    event.creatorId,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Actions
                      if (isCreator) ...[
                        Text('Actions', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),
                        _ActionButton(
                          icon: Icons.edit,
                          label: 'Modifier l\'événement',
                          color: AppColors.primary,
                          onTap: () {
                            // TODO: Implémenter modification
                          },
                        ),
                        const SizedBox(height: 8),
                        _ActionButton(
                          icon: Icons.delete,
                          label: 'Supprimer l\'événement',
                          color: AppColors.error,
                          onTap: () => _showDeleteDialog(context, event),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Event event, bool isCreator) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.event,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
      actions: [
        if (isCreator)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Menu contextuel
            },
          ),
      ],
    );
  }

  String _formatEventDate(Event event) {
    if (event.startDate == null) return 'Date à définir';

    final formatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final timeFormatter = DateFormat('HH:mm');

    if (event.endDate != null) {
      final isSameDay =
          event.startDate!.year == event.endDate!.year &&
          event.startDate!.month == event.endDate!.month &&
          event.startDate!.day == event.endDate!.day;

      if (isSameDay) {
        return '${formatter.format(event.startDate!)}\n${timeFormatter.format(event.startDate!)} - ${timeFormatter.format(event.endDate!)}';
      } else {
        return '${formatter.format(event.startDate!)}\nau ${formatter.format(event.endDate!)}';
      }
    }

    return '${formatter.format(event.startDate!)}\nà ${timeFormatter.format(event.startDate!)}';
  }

  String _getStatusLabel(EventStatus status) {
    switch (status) {
      case EventStatus.planned:
        return 'Planifié';
      case EventStatus.confirmed:
        return 'Confirmé';
      case EventStatus.cancelled:
        return 'Annulé';
      case EventStatus.completed:
        return 'Terminé';
    }
  }

  void _showDeleteDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'événement'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cet événement ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final eventProvider = context.read<EventProvider>();
              await eventProvider.deleteEvent(event.id);
              if (context.mounted) {
                Navigator.of(context).pop(); // Fermer dialog
                Navigator.of(context).pop(); // Retour à la liste
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipationButtons extends StatelessWidget {
  final Event event;
  final String userId;

  const _ParticipationButtons({required this.event, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isParticipating = event.participantIds.contains(userId);
    final isMaybe = event.maybeIds.contains(userId);
    final isDeclined = event.declinedIds.contains(userId);

    return Row(
      children: [
        Expanded(
          child: _ResponseButton(
            icon: Icons.check_circle,
            label: 'Je viens',
            isSelected: isParticipating,
            color: AppColors.secondary,
            onTap: () {
              context.read<EventProvider>().respondToEvent(
                eventId: event.id,
                userId: userId,
                status: ParticipationStatus.participating,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ResponseButton(
            icon: Icons.help_outline,
            label: 'Peut-être',
            isSelected: isMaybe,
            color: Colors.orange,
            onTap: () {
              context.read<EventProvider>().respondToEvent(
                eventId: event.id,
                userId: userId,
                status: ParticipationStatus.maybe,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ResponseButton(
            icon: Icons.cancel,
            label: 'Non',
            isSelected: isDeclined,
            color: AppColors.error,
            onTap: () {
              context.read<EventProvider>().respondToEvent(
                eventId: event.id,
                userId: userId,
                status: ParticipationStatus.declined,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResponseButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ResponseButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.titleLarge.copyWith(color: color)),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  final String userId;
  final bool isCreator;

  const _ParticipantAvatar({required this.userId, required this.isCreator});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                userId[0].toUpperCase(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            if (isCreator)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.star, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text('User ${userId.substring(5)}', style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
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
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
