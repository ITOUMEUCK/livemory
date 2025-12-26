import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/user/user_avatar.dart';
import '../../domain/entities/event.dart';
import '../providers/event_provider.dart';

/// Onglet d'informations générales d'un événement
class EventInfoTab extends StatelessWidget {
  final Event event;
  final String userId;
  final bool isCreator;

  const EventInfoTab({
    super.key,
    required this.event,
    required this.userId,
    required this.isCreator,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            value: _getStatusLabel(event.status.name),
          ),
          const SizedBox(height: 24),

          // Sondages
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sondages', style: AppTextStyles.titleMedium),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.polls, arguments: event.id);
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Voir tous'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.createPoll, arguments: event.id);
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un sondage'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 24),

          // Budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget', style: AppTextStyles.titleMedium),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.budget, arguments: event.id);
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Voir tous'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.createBudget, arguments: event.id);
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un budget'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
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

          // Liste détaillée des participants
          if (event.participantIds.isNotEmpty) ...[
            _ParticipantSection(
              title: 'Confirmés (${event.participantIds.length})',
              userIds: event.participantIds,
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
          ],

          if (event.maybeIds.isNotEmpty) ...[
            _ParticipantSection(
              title: 'Peut-être (${event.maybeIds.length})',
              userIds: event.maybeIds,
              icon: Icons.help_outline,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
          ],

          if (event.declinedIds.isNotEmpty) ...[
            _ParticipantSection(
              title: 'Ont refusé (${event.declinedIds.length})',
              userIds: event.declinedIds,
              icon: Icons.cancel,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 8),

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
    );
  }

  String _formatEventDate(Event event) {
    final dateFormat = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR');
    if (event.startDate != null) {
      return dateFormat.format(event.startDate!);
    }
    return 'Date non définie';
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'planned':
        return 'Planifié';
      case 'ongoing':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  void _showDeleteDialog(BuildContext context, Event event) {
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
              await context.read<EventProvider>().deleteEvent(event.id);
              if (context.mounted) {
                Navigator.pop(context); // Ferme le dialogue
                Navigator.pop(context); // Retour à la liste
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

// Widgets helpers (à garder dans ce fichier ou exporter depuis l'original)
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
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
    final isConfirmed = event.participantIds.contains(userId);
    final isMaybe = event.maybeIds.contains(userId);
    final isDeclined = event.declinedIds.contains(userId);

    return Row(
      children: [
        Expanded(
          child: _ParticipationButton(
            icon: Icons.check_circle,
            label: 'Je viens',
            isSelected: isConfirmed,
            color: AppColors.success,
            onTap: () async {
              await context.read<EventProvider>().respondToEvent(
                eventId: event.id,
                userId: userId,
                status: ParticipationStatus.participating,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Participation confirmée')),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ParticipationButton(
            icon: Icons.help_outline,
            label: 'Peut-être',
            isSelected: isMaybe,
            color: Colors.orange,
            onTap: () async {
              await context.read<EventProvider>().respondToEvent(
                eventId: event.id,
                userId: userId,
                status: ParticipationStatus.maybe,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🤔 Réponse "Peut-être" enregistrée'),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ParticipationButton(
            icon: Icons.cancel,
            label: 'Non',
            isSelected: isDeclined,
            color: AppColors.error,
            onTap: () async {
              await context.read<EventProvider>().respondToEvent(
                eventId: event.id,
                userId: userId,
                status: ParticipationStatus.declined,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Participation refusée')),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ParticipationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ParticipationButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withValues(alpha: 0.1),
        foregroundColor: isSelected ? Colors.white : color,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.titleSmall.copyWith(color: color),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

/// Section affichant une catégorie de participants
class _ParticipantSection extends StatelessWidget {
  final String title;
  final List<String> userIds;
  final IconData icon;
  final Color color;

  const _ParticipantSection({
    required this.title,
    required this.userIds,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleSmall.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: userIds.map((userId) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  UserName(
                    userId: userId,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
