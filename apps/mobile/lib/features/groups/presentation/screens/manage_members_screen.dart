import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/domain/entities/notification.dart'
    as app_notification;
import '../../domain/entities/group.dart';

/// Écran de gestion des membres d'un groupe
class ManageMembersScreen extends StatelessWidget {
  final String groupId;

  const ManageMembersScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final group = groupProvider.groups.firstWhere(
          (g) => g.id == groupId,
          orElse: () => throw Exception('Groupe non trouvé'),
        );

        final currentUserId = context.read<AuthProvider>().currentUser?.id;
        final isCurrentUserAdmin = group.adminIds.contains(currentUserId);

        return Scaffold(
          appBar: AppBar(title: const Text('Gestion des membres')),
          body: ListView.builder(
            itemCount: group.memberIds.length,
            itemBuilder: (context, index) {
              final memberId = group.memberIds[index];
              final isAdmin = group.adminIds.contains(memberId);
              final isCurrentUser = memberId == currentUserId;

              return _MemberTile(
                groupId: groupId,
                memberId: memberId,
                isAdmin: isAdmin,
                isCurrentUser: isCurrentUser,
                isCurrentUserAdmin: isCurrentUserAdmin,
                group: group,
              );
            },
          ),
        );
      },
    );
  }
}

/// Widget pour afficher un membre avec actions
class _MemberTile extends StatelessWidget {
  final String groupId;
  final String memberId;
  final bool isAdmin;
  final bool isCurrentUser;
  final bool isCurrentUserAdmin;
  final Group group;

  const _MemberTile({
    required this.groupId,
    required this.memberId,
    required this.isAdmin,
    required this.isCurrentUser,
    required this.isCurrentUserAdmin,
    required this.group,
  });

  Future<void> _removeMember(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer du groupe'),
        content: const Text(
          'Voulez-vous vraiment retirer ce membre du groupe ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final groupProvider = context.read<GroupProvider>();
      final success = await groupProvider.removeMember(
        groupId: groupId,
        userId: memberId,
      );

      if (success && context.mounted) {
        // Notifier le membre qu'il a été retiré
        final notificationProvider = context.read<NotificationProvider>();
        await notificationProvider.createNotification(
          userId: memberId,
          type: app_notification.NotificationType.memberLeft,
          title: 'Retiré d\'un groupe',
          message: 'Vous avez été retiré du groupe "${group.name}"',
          metadata: {'groupId': groupId, 'groupName': group.name},
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membre retiré avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _promoteToAdmin(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promouvoir admin'),
        content: const Text(
          'Voulez-vous promouvoir ce membre en administrateur ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Promouvoir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final groupProvider = context.read<GroupProvider>();
      final success = await groupProvider.promoteToAdmin(
        groupId: groupId,
        userId: memberId,
      );

      if (success && context.mounted) {
        // Notifier le membre qu'il est admin
        final notificationProvider = context.read<NotificationProvider>();
        await notificationProvider.createNotification(
          userId: memberId,
          type: app_notification.NotificationType.invitation,
          title: 'Nouveau rôle',
          message:
              'Vous êtes maintenant administrateur du groupe "${group.name}"',
          metadata: {
            'groupId': groupId,
            'groupName': group.name,
            'role': 'admin',
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membre promu administrateur'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _demoteAdmin(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer les droits admin'),
        content: const Text(
          'Voulez-vous retirer les droits d\'administrateur à ce membre ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final groupProvider = context.read<GroupProvider>();
      final success = await groupProvider.demoteAdmin(
        groupId: groupId,
        userId: memberId,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Droits admin retirés'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(),
            title: Text('Chargement...'),
          );
        }

        final userData = snapshot.data!;
        final name = userData['firstName'] ?? userData['name'] ?? 'Utilisateur';
        final email = userData['email'] ?? '';
        final photoUrl = userData['photoUrl'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? Text(name[0].toUpperCase()) : null,
          ),
          title: Row(
            children: [
              Text(name),
              if (isCurrentUser)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Vous',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isAdmin)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Admin',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(email),
          trailing: isCurrentUserAdmin && !isCurrentUser
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'promote':
                        _promoteToAdmin(context);
                        break;
                      case 'demote':
                        _demoteAdmin(context);
                        break;
                      case 'remove':
                        _removeMember(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isAdmin)
                      const PopupMenuItem(
                        value: 'promote',
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 20),
                            SizedBox(width: 12),
                            Text('Promouvoir admin'),
                          ],
                        ),
                      ),
                    if (isAdmin)
                      const PopupMenuItem(
                        value: 'demote',
                        child: Row(
                          children: [
                            Icon(Icons.remove_moderator, size: 20),
                            SizedBox(width: 12),
                            Text('Retirer droits admin'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_remove,
                            size: 20,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Retirer du groupe',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    try {
      final firestoreService = FirestoreService();
      final doc = await firestoreService.read('users', memberId);
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
