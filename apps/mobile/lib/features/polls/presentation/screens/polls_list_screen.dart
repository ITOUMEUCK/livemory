import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/common/common_widgets.dart';
import '../providers/poll_provider.dart';
import '../../domain/entities/poll.dart';

/// Écran liste des sondages
class PollsListScreen extends StatefulWidget {
  final String? eventId;

  const PollsListScreen({super.key, this.eventId});

  @override
  State<PollsListScreen> createState() => _PollsListScreenState();
}

class _PollsListScreenState extends State<PollsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PollProvider>().fetchPolls();
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
        title: Text(widget.eventId != null ? 'Sondages' : 'Tous les sondages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Actifs'),
            Tab(text: 'Fermés'),
          ],
        ),
      ),
      body: Consumer<PollProvider>(
        builder: (context, pollProvider, child) {
          if (pollProvider.isLoading && pollProvider.polls.isEmpty) {
            return const LoadingIndicator();
          }

          if (pollProvider.errorMessage != null) {
            return ErrorView(
              message: pollProvider.errorMessage!,
              onRetry: () => pollProvider.fetchPolls(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildActivePolls(pollProvider),
              _buildClosedPolls(pollProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.createPoll, arguments: widget.eventId);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau sondage'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildActivePolls(PollProvider pollProvider) {
    final polls = widget.eventId != null
        ? pollProvider
              .getPollsByEvent(widget.eventId!)
              .where((p) => !p.isClosed)
              .toList()
        : pollProvider.activePolls;

    if (polls.isEmpty) {
      return EmptyState(
        icon: Icons.poll,
        title: 'Aucun sondage actif',
        subtitle: widget.eventId != null
            ? 'Créez un sondage pour cet événement'
            : 'Les sondages actifs apparaîtront ici',
        actionLabel: widget.eventId != null ? 'Créer un sondage' : null,
        onAction: widget.eventId != null
            ? () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.createPoll, arguments: widget.eventId);
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => pollProvider.fetchPolls(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: polls.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final poll = polls[index];
          return _PollCard(
            poll: poll,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.pollDetailPath(poll.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildClosedPolls(PollProvider pollProvider) {
    final polls = widget.eventId != null
        ? pollProvider
              .getPollsByEvent(widget.eventId!)
              .where((p) => p.isClosed)
              .toList()
        : pollProvider.closedPolls;

    if (polls.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'Aucun sondage fermé',
        subtitle: 'Les sondages terminés apparaîtront ici',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: polls.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final poll = polls[index];
        return _PollCard(
          poll: poll,
          isClosed: true,
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.pollDetailPath(poll.id));
          },
        );
      },
    );
  }
}

class _PollCard extends StatelessWidget {
  final Poll poll;
  final bool isClosed;
  final VoidCallback onTap;

  const _PollCard({
    required this.poll,
    this.isClosed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final winningOption = poll.winningOption;

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
                  // Type icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        poll.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poll.question,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isClosed ? AppColors.textSecondary : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          poll.type.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _getTypeColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isClosed)
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
                        'Fermé',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Deadline
              if (poll.deadline != null && !isClosed) ...[
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ferme le ${DateFormat('d MMM à HH:mm', 'fr_FR').format(poll.deadline!)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Option gagnante
              if (winningOption != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: _getTypeColor(),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          winningOption.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${winningOption.voteCount} vote${winningOption.voteCount > 1 ? 's' : ''}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _getTypeColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Stats
              Row(
                children: [
                  Icon(
                    Icons.how_to_vote,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${poll.totalVotes} vote${poll.totalVotes > 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.list, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${poll.options.length} option${poll.options.length > 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (poll.allowMultipleChoices) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Multi',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (poll.type) {
      case PollType.date:
        return AppColors.primary;
      case PollType.location:
        return AppColors.secondary;
      case PollType.activity:
        return Colors.orange;
      case PollType.general:
        return Colors.purple;
    }
  }
}
