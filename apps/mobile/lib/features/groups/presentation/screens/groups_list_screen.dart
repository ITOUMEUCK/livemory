import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../../../../shared/widgets/layouts/responsive_widgets.dart';
import '../providers/group_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
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
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<GroupProvider>().fetchGroups(userId);
      }
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
              onRetry: () {
                final userId = context.read<AuthProvider>().currentUser?.id;
                if (userId != null) {
                  groupProvider.fetchGroups(userId);
                }
              },
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
            onRefresh: () async {
              final userId = context.read<AuthProvider>().currentUser?.id;
              if (userId != null) {
                await groupProvider.fetchGroups(userId);
              }
            },
            child: ResponsiveLayout(
              // Mobile: ListView vertical
              mobile: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: groupProvider.groups.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
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
              // Tablette/Desktop: GridView
              tablet: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = AppBreakpoints.getGridColumns(
                    constraints.maxWidth,
                  );
                  final padding = AppBreakpoints.getHorizontalPadding(
                    constraints.maxWidth,
                  );

                  return GridView.builder(
                    padding: EdgeInsets.all(padding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.groups[index];
                      return _GroupCard(
                        group: group,
                        onTap: () {
                          groupProvider.selectGroup(group.id);
                          Navigator.of(context).pushNamed(
                            AppRoutes.groupDetail,
                            arguments: group.id,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'groups_create_fab',
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
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/bannière du groupe en haut
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.secondary.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: group.photoUrl != null
                      ? Image.network(
                          group.photoUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: _buildInitials());
                          },
                        )
                      : Center(child: _buildInitials()),
                ),
                // Badge privé
                if (group.settings.isPrivate)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Privé',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    group.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      const Icon(
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
          ],
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = group.name.isNotEmpty
        ? group.name
              .split(' ')
              .take(2)
              .map((word) => word.isNotEmpty ? word[0] : '')
              .join()
              .toUpperCase()
        : 'G';

    return Text(
      initials,
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
