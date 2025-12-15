import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../providers/group_provider.dart';
import '../../domain/entities/group.dart';

/// Écran détail d'un groupe
class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final group = groupProvider.groups.firstWhere(
          (g) => g.id == groupId,
          orElse: () => groupProvider.groups.first,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, group),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (group.description != null) ...[
                        Text('À propos', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          group.description!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Stats rapides
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people,
                              label: 'Membres',
                              value: '${group.memberCount}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.event,
                              label: 'Événements',
                              value: '0', // TODO: Compter les vrais événements
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.admin_panel_settings,
                              label: 'Admins',
                              value: '${group.adminIds.length}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Actions rapides
                      _ActionButton(
                        icon: Icons.event_available,
                        label: 'Créer un événement',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.createEvent,
                            arguments: groupId,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        icon: Icons.person_add,
                        label: 'Inviter des membres',
                        color: AppColors.secondary,
                        onTap: () {
                          // TODO: Implémenter invitation
                        },
                      ),
                      const SizedBox(height: 24),

                      // Liste des membres
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Membres (${group.memberCount})',
                            style: AppTextStyles.titleMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Afficher tous les membres
                            },
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: group.memberCount > 10
                              ? 10
                              : group.memberCount,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return _MemberAvatar(
                              userId: group.memberIds[index],
                              isAdmin: group.adminIds.contains(
                                group.memberIds[index],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Paramètres du groupe
                      Text('Paramètres', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      _SettingRow(
                        icon: Icons.lock,
                        label: 'Groupe privé',
                        value: group.settings.isPrivate
                            ? 'Activé'
                            : 'Désactivé',
                      ),
                      _SettingRow(
                        icon: Icons.person_add,
                        label: 'Invitations membres',
                        value: group.settings.allowMemberInvite
                            ? 'Autorisées'
                            : 'Interdites',
                      ),
                      _SettingRow(
                        icon: Icons.admin_panel_settings,
                        label: 'Approbation admin',
                        value: group.settings.requireAdminApproval
                            ? 'Requise'
                            : 'Non requise',
                      ),
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

  Widget _buildAppBar(BuildContext context, Group group) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          group.name,
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
          child: group.photoUrl != null
              ? Image.network(group.photoUrl!, fit: BoxFit.cover)
              : Center(
                  child: Icon(
                    Icons.groups,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
        ),
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
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
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Paramètres'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'leave',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Quitter le groupe',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            // TODO: Implémenter les actions
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
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

class _MemberAvatar extends StatelessWidget {
  final String userId;
  final bool isAdmin;

  const _MemberAvatar({required this.userId, required this.isAdmin});

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
            if (isAdmin)
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

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
