import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../providers/group_provider.dart';
import '../../domain/entities/group.dart';

/// Écran liste des groupes
class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Groupes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading && groupProvider.groups.isEmpty) {
            return const LoadingIndicator(message: 'Chargement des groupes...');
          }

          if (groupProvider.errorMessage != null) {
            return ErrorView(
              message: groupProvider.errorMessage!,
              onRetry: () => groupProvider.fetchGroups(),
            );
          }

          if (groupProvider.groups.isEmpty) {
            return EmptyState(
              icon: Icons.groups,
              title: 'Aucun groupe',
              subtitle:
                  'Créez votre premier groupe pour commencer à organiser vos événements',
              actionLabel: 'Créer un groupe',
              onAction: () {
                Navigator.of(context).pushNamed(AppRoutes.createGroup);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => groupProvider.fetchGroups(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: groupProvider.groups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final group = groupProvider.groups[index];
                return _GroupCard(
                  group: group,
                  onTap: () {
                    groupProvider.selectGroup(group.id);
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.groupDetail, arguments: group.id);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.createGroup);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau groupe'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// Card pour afficher un groupe
class _GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar du groupe
              _GroupAvatar(photoUrl: group.photoUrl, name: group.name),
              const SizedBox(width: 16),

              // Infos du groupe
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (group.settings.isPrivate)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiary.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Privé',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (group.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.description!,
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
                        Icon(
                          Icons.people,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount} membre${group.memberCount > 1 ? 's' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Icône chevron
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar d'un groupe
class _GroupAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;

  const _GroupAvatar({this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: photoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials();
                },
              ),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((word) => word.isNotEmpty ? word[0] : '')
              .join()
              .toUpperCase()
        : 'G';

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
      ),
    );
  }
}
