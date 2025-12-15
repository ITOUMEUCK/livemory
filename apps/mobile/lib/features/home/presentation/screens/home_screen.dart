import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../groups/presentation/screens/groups_list_screen.dart';
import '../../../events/presentation/screens/events_list_screen.dart';
import '../../../polls/presentation/providers/poll_provider.dart';
import '../../../polls/domain/entities/poll.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

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
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'Groupes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Événements',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton.extended(
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
    // Charger les notifications au démarrage
    Future.microtask(
      () => context.read<NotificationProvider>().fetchNotifications(),
    );
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
              // Prochains événements
              _SectionHeader(title: 'Prochains événements', onSeeAll: () {}),
              const SizedBox(height: 12),
              _EventCard(
                title: 'Week-end à la montagne ⛷️',
                date: 'Sam 20 déc - Dim 21 déc',
                participants: 8,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _EventCard(
                title: 'Soirée jeux 🎮',
                date: 'Ven 26 déc à 20h',
                participants: 5,
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // Mes groupes
              _SectionHeader(title: 'Mes groupes', onSeeAll: () {}),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _GroupChip(name: 'Famille', members: 12),
                    const SizedBox(width: 12),
                    _GroupChip(name: 'Amis Promo', members: 25),
                    const SizedBox(width: 12),
                    _GroupChip(name: 'Sport', members: 8),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions rapides
              _SectionHeader(title: 'Actions rapides'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.event_available,
                      label: 'Créer un événement',
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.poll,
                      label: 'Créer un sondage',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.createPoll);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.list_alt,
                      label: 'Voir les sondages',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.polls);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.account_balance_wallet,
                      label: 'Créer un budget',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.createBudget);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.receipt_long,
                      label: 'Voir les budgets',
                      color: Colors.amber,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.budget);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sondages actifs
              _SectionHeader(
                title: 'Sondages actifs',
                onSeeAll: () {
                  Navigator.of(context).pushNamed(AppRoutes.polls);
                },
              ),
              const SizedBox(height: 12),
              Consumer<PollProvider>(
                builder: (context, pollProvider, child) {
                  if (pollProvider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final activePolls = pollProvider.activePolls.take(3).toList();

                  if (activePolls.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.poll,
                              size: 32,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun sondage actif',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: activePolls.map((poll) {
                      String typeIcon;
                      if (poll.type == PollType.date) {
                        typeIcon = '📅';
                      } else if (poll.type == PollType.location) {
                        typeIcon = '📍';
                      } else if (poll.type == PollType.activity) {
                        typeIcon = '🎯';
                      } else {
                        typeIcon = '📊';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PollCard(
                          question: poll.question,
                          totalVotes: poll.totalVotes,
                          optionsCount: poll.options.length,
                          typeIcon: typeIcon,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.pollDetailPath(poll.id));
                          },
                        ),
                      );
                    }).toList(),
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

/// Tab Profil
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar et infos
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: user?.photoUrl != null
                      ? ClipOval(child: Image.network(user!.photoUrl!))
                      : Text(
                          user?.initials ?? 'U',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Utilisateur',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCard(label: 'Événements', value: '12'),
              _StatCard(label: 'Groupes', value: '3'),
              _StatCard(label: 'Amis', value: '45'),
            ],
          ),
          const SizedBox(height: 32),

          // Menu
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Modifier le profil',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _ProfileMenuItem(icon: Icons.language, title: 'Langue', onTap: () {}),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Aide & Support',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Confidentialité',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _ProfileMenuItem(
            icon: Icons.logout,
            title: 'Déconnexion',
            textColor: AppColors.error,
            onTap: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
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
