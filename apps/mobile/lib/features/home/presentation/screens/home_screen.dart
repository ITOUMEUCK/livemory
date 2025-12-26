import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/network_service.dart';
import '../../../../shared/widgets/user/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../groups/presentation/providers/group_provider.dart';
import '../../../groups/presentation/screens/groups_list_screen.dart';
import '../../../events/presentation/screens/events_list_screen.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../polls/presentation/providers/poll_provider.dart';
import '../../../polls/domain/entities/poll.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

/// Écran d'accueil principal avec bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    _GroupsTab(),
    _EventsTab(),
    ProfileScreen(),
  ];

  /// Construit l'icône de profil personnalisée avec la photo de l'utilisateur
  Widget _buildProfileIcon(BuildContext context, {required bool isActive}) {
    final user = context.watch<AuthProvider>().currentUser;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          width: isActive ? 2 : 1.5,
        ),
      ),
      child: ClipOval(
        child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
            ? Image.network(
                user.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(user, isActive);
                },
              )
            : _buildDefaultAvatar(user, isActive),
      ),
    );
  }

  /// Avatar par défaut avec initiales si pas de photo
  Widget _buildDefaultAvatar(user, bool isActive) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          user?.initials ?? 'U',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const NetworkStatusBanner(),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'Groupes',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Événements',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileIcon(context, isActive: false),
              activeIcon: _buildProfileIcon(context, isActive: true),
              label: 'Profil',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton.extended(
              heroTag: 'home_create_event_fab',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.createEvent);
              },
              icon: const Icon(Icons.add),
              label: const Text('Événement'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}

/// Tab Dashboard (Accueil)
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    // Charger les notifications, groupes et événements au démarrage
    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        context.read<NotificationProvider>().fetchNotifications(userId);

        // D'abord charger les groupes
        final groupProvider = context.read<GroupProvider>();
        await groupProvider.fetchGroups(userId);

        // Puis charger les événements avec les groupes
        final userGroupIds = groupProvider.groups.map((g) => g.id).toList();
        context.read<EventProvider>().fetchEvents(
          userId: userId,
          userGroupIds: userGroupIds,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: AppColors.background,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salut ${user?.firstName ?? 'Utilisateur'} 👋',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 2),
              Text(
                'Prêt à organiser un moment ?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            // Badge de notification
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, _) {
                final unreadCount = notificationProvider.unreadCount;

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.notifications);
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Événements actifs (remplace Comptes, assurances)
              _SectionHeader(
                title: 'Événements actifs',
                onSeeAll: () {
                  Navigator.of(context).pushNamed(AppRoutes.events);
                },
              ),
              const SizedBox(height: 12),
              Consumer<EventProvider>(
                builder: (context, eventProvider, _) {
                  // Filtrer uniquement les événements actifs (en cours ou à venir)
                  final now = DateTime.now();
                  final activeEvents = eventProvider.events.where((event) {
                    final startDate = event.startDate ?? event.createdAt;
                    final endDate = event.endDate;

                    // Événement actif si :
                    // 1. La date de fin est dans le futur (en cours ou futur)
                    if (endDate != null && endDate.isAfter(now)) {
                      return true;
                    }

                    // 2. OU la date de début est dans le futur
                    if (startDate.isAfter(now)) {
                      return true;
                    }

                    // Sinon, l'événement est passé
                    return false;
                  }).toList();

                  // Trier par date de début
                  activeEvents.sort((a, b) {
                    final aDate = a.startDate ?? a.createdAt;
                    final bDate = b.startDate ?? b.createdAt;
                    return aDate.compareTo(bDate);
                  });

                  if (activeEvents.isEmpty) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun événement actif',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 280,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: activeEvents.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final event = activeEvents[index];
                        final startDate = event.startDate ?? event.createdAt;
                        final endDate = event.endDate;

                        String dateText;
                        if (endDate != null &&
                            !_isSameDay(startDate, endDate)) {
                          dateText =
                              '${_formatDate(startDate)} - ${_formatDate(endDate)}';
                        } else {
                          dateText = _formatDate(startDate);
                          if (event.startDate != null) {
                            dateText +=
                                ' à ${DateFormat('HH:mm').format(startDate)}';
                          }
                        }

                        return SizedBox(
                          width: 280,
                          child: _EventCardHorizontal(
                            title: event.title,
                            description: event.description,
                            icon: _getEventIcon(event.title),
                            date: dateText,
                            creatorId: event.creatorId,
                            confirmedCount: event.participantIds.length,
                            maybeCount: event.maybeIds.length,
                            declinedCount: event.declinedIds.length,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.eventDetail,
                                arguments: event.id,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Actions rapides (Créer événement + Nouveau groupe)
              _SectionHeader(title: 'Actions rapides'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.event_available,
                      label: 'Créer événement',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.createEvent);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.group_add,
                      label: 'Nouveau groupe',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.createGroup);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sélectionnés pour vous (Offres partenaires)
              _SectionHeader(title: 'Sélectionnés pour vous', onSeeAll: () {}),
              const SizedBox(height: 12),
              Consumer<PollProvider>(
                builder: (context, pollProvider, child) {
                  // Données mock des offres partenaires
                  return Column(
                    children: [
                      _PartnerOfferCard(
                        icon: '🏠',
                        title: 'Location de gîte',
                        subtitle: 'Réservez votre week-end en groupe',
                        description:
                            'Profitez de -15% sur les réservations de groupe pour vos prochains événements !',
                        discount: '-15%',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _PartnerOfferCard(
                        icon: '🎿',
                        title: 'Activités outdoor',
                        subtitle: 'Ski, randonnée et aventure',
                        description:
                            'Forfaits de groupe pour vos sorties à la montagne. Économisez jusqu\'à 20% !',
                        discount: '-20%',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _PartnerOfferCard(
                        icon: '🍕',
                        title: 'Restaurants partenaires',
                        subtitle: 'Réservations de groupe simplifiées',
                        description:
                            'Menus spéciaux et réductions pour les groupes de 8 personnes et plus.',
                        discount: '-10%',
                        onTap: () {},
                      ),
                    ],
                  );
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Tab Groupes
class _GroupsTab extends StatelessWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context) {
    return const GroupsListScreen();
  }
}

/// Tab Événements
class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    return const EventsListScreen();
  }
}

// Widgets utilitaires

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('Voir tout')),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String date;
  final int participants;
  final VoidCallback onTap;

  const _EventCard({
    required this.title,
    required this.date,
    required this.participants,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$participants',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String name;
  final int members;

  const _GroupChip({required this.name, required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            '$members membres',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
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
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Widget pour afficher un sondage dans le dashboard
class _PollCard extends StatelessWidget {
  final String question;
  final int totalVotes;
  final int optionsCount;
  final String typeIcon;
  final VoidCallback onTap;

  const _PollCard({
    required this.question,
    required this.totalVotes,
    required this.optionsCount,
    required this.typeIcon,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(typeIcon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalVotes vote${totalVotes > 1 ? 's' : ''} • $optionsCount option${optionsCount > 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour les offres partenaires
class _PartnerOfferCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final String discount;
  final VoidCallback onTap;

  const _PartnerOfferCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.discount,
    required this.onTap,
  });

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
            // Image/bannière en haut
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.4),
                        Colors.orange.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 80)),
                  ),
                ),
                // Badge réduction
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Icône favoris
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.black87,
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
                  Text(title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour les cartes d'événements horizontales
class _EventCardHorizontal extends StatelessWidget {
  final String title;
  final String? description;
  final String icon;
  final String date;
  final String creatorId;
  final int confirmedCount;
  final int maybeCount;
  final int declinedCount;
  final VoidCallback onTap;

  const _EventCardHorizontal({
    required this.title,
    this.description,
    required this.icon,
    required this.date,
    required this.creatorId,
    required this.confirmedCount,
    required this.maybeCount,
    required this.declinedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image en haut avec icône (même style que la liste)
              Container(
                height: 140,
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
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 56)),
                ),
              ),
              // Infos en dessous
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null &&
                        description!.isNotEmpty &&
                        description != title) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Créé par ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Flexible(
                          child: UserName(
                            userId: creatorId,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            date,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _ParticipationBadge(
                          icon: Icons.check_circle,
                          count: confirmedCount,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        _ParticipationBadge(
                          icon: Icons.help_outline,
                          count: maybeCount,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        _ParticipationBadge(
                          icon: Icons.cancel,
                          count: declinedCount,
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
      ),
    );
  }
}

// Helper functions
bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = date.difference(now).inDays;

  if (diff == 0) return 'Aujourd\'hui';
  if (diff == 1) return 'Demain';

  final weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final months = [
    'jan',
    'fév',
    'mar',
    'avr',
    'mai',
    'juin',
    'juil',
    'août',
    'sep',
    'oct',
    'nov',
    'déc',
  ];

  return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
}

String _getEventIcon(String title) {
  final lowerTitle = title.toLowerCase();

  if (lowerTitle.contains('anniversaire') || lowerTitle.contains('birthday'))
    return '🎂';
  if (lowerTitle.contains('montagne') || lowerTitle.contains('ski'))
    return '⛷️';
  if (lowerTitle.contains('jeux') || lowerTitle.contains('game')) return '🎮';
  if (lowerTitle.contains('resto') ||
      lowerTitle.contains('dîner') ||
      lowerTitle.contains('déjeuner'))
    return '🍽️';
  if (lowerTitle.contains('voyage') || lowerTitle.contains('trip')) return '✈️';
  if (lowerTitle.contains('sport') ||
      lowerTitle.contains('foot') ||
      lowerTitle.contains('match'))
    return '⚽';
  if (lowerTitle.contains('concert') || lowerTitle.contains('musique'))
    return '🎵';
  if (lowerTitle.contains('film') || lowerTitle.contains('cinéma')) return '🎬';
  if (lowerTitle.contains('fête') || lowerTitle.contains('party')) return '🎉';
  if (lowerTitle.contains('bbq') || lowerTitle.contains('barbecue'))
    return '🍖';
  if (lowerTitle.contains('plage') || lowerTitle.contains('beach'))
    return '🏖️';
  if (lowerTitle.contains('randonnée') || lowerTitle.contains('hiking'))
    return '🥾';

  return '📅'; // Icône par défaut
}

/// Widget pour afficher un badge de participation
class _ParticipationBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _ParticipationBadge({
    required this.icon,
    required this.count,
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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
