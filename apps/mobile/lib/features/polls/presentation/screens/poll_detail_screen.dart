import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/buttons.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/poll_provider.dart';
import '../../domain/entities/poll.dart';

/// Écran de détail d'un sondage avec interface de vote
class PollDetailScreen extends StatefulWidget {
  final String pollId;

  const PollDetailScreen({super.key, required this.pollId});

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  Set<String> _selectedOptions = {};
  bool _isVoting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<PollProvider, AuthProvider>(
      builder: (context, pollProvider, authProvider, child) {
        final poll = pollProvider.polls.firstWhere(
          (p) => p.id == widget.pollId,
          orElse: () => throw Exception('Poll not found'),
        );

        final userId = authProvider.currentUser?.id ?? 'user_1';
        final hasVoted = poll.hasVoted(userId);
        final userVotes = poll.getUserVotes(userId);
        final isClosed = poll.isClosed;

        // Initialiser la sélection avec les votes existants
        if (_selectedOptions.isEmpty && hasVoted) {
          _selectedOptions = userVotes.toSet();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Détail du sondage'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  pollProvider.fetchPolls();
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // En-tête avec type et statut
              _buildHeader(poll, isClosed),
              const SizedBox(height: 16),

              // Question
              Text(poll.question, style: AppTextStyles.headlineSmall),
              if (poll.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  poll.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Informations sur le sondage
              _buildInfoSection(poll),
              const SizedBox(height: 24),

              // Options de vote
              Text(
                isClosed ? 'Résultats' : 'Votez',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 12),
              ..._buildOptions(poll, userId, hasVoted, isClosed),
              const SizedBox(height: 24),

              // Boutons d'action
              if (!isClosed) ...[
                if (hasVoted)
                  OutlinedButton(
                    onPressed: _isVoting
                        ? null
                        : () => _handleRemoveVote(pollProvider, userId),
                    child: const Text('Retirer mon vote'),
                  )
                else
                  PrimaryButton(
                    text: 'Voter',
                    onPressed: _selectedOptions.isEmpty || _isVoting
                        ? null
                        : () => _handleVote(poll, pollProvider, userId),
                    isLoading: _isVoting,
                  ),
              ],
              const SizedBox(height: 16),

              // Statistiques
              _buildStatistics(poll),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Poll poll, bool isClosed) {
    final typeColor = _getTypeColor(poll.type);

    return Row(
      children: [
        // Badge de type
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(poll.type.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                poll.type.displayName,
                style: AppTextStyles.labelMedium.copyWith(color: typeColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Badge de statut
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isClosed
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isClosed ? 'Fermé' : 'Ouvert',
            style: AppTextStyles.labelMedium.copyWith(
              color: isClosed ? AppColors.error : AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Poll poll) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date de création
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(
                'Créé le ${dateFormat.format(poll.createdAt)}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),

          // Date limite
          if (poll.deadline != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: poll.isClosed ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  poll.isClosed
                      ? 'Fermé le ${dateFormat.format(poll.deadline!)}'
                      : 'Ferme le ${dateFormat.format(poll.deadline!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: poll.isClosed ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ],

          // Total des votes
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.how_to_vote, size: 16),
              const SizedBox(width: 8),
              Text(
                '${poll.totalVotes} vote${poll.totalVotes > 1 ? 's' : ''}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),

          // Options spéciales
          if (poll.allowMultipleChoices || poll.isAnonymous) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            if (poll.allowMultipleChoices)
              Row(
                children: [
                  const Icon(Icons.checklist, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Votes multiples autorisés',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            if (poll.isAnonymous) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.visibility_off, size: 16),
                  const SizedBox(width: 8),
                  Text('Vote anonyme', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  List<Widget> _buildOptions(
    Poll poll,
    String userId,
    bool hasVoted,
    bool isClosed,
  ) {
    return poll.options.map((option) {
      final isSelected = _selectedOptions.contains(option.id);
      final percentage = option.getPercentage(poll.totalVotes);
      final isWinning = poll.winningOption?.id == option.id;
      final hasUserVoted = option.voterIds.contains(userId);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildOptionCard(
          option: option,
          poll: poll,
          isSelected: isSelected,
          percentage: percentage,
          isWinning: isWinning,
          hasUserVoted: hasUserVoted,
          hasVoted: hasVoted,
          isClosed: isClosed,
        ),
      );
    }).toList();
  }

  Widget _buildOptionCard({
    required PollOption option,
    required Poll poll,
    required bool isSelected,
    required double percentage,
    required bool isWinning,
    required bool hasUserVoted,
    required bool hasVoted,
    required bool isClosed,
  }) {
    final showResults = hasVoted || isClosed;

    return InkWell(
      onTap: isClosed
          ? null
          : () {
              setState(() {
                if (poll.allowMultipleChoices) {
                  if (isSelected) {
                    _selectedOptions.remove(option.id);
                  } else {
                    _selectedOptions.add(option.id);
                  }
                } else {
                  _selectedOptions = {option.id};
                }
              });
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isWinning && showResults
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && !isClosed
                ? AppColors.primary
                : isWinning && showResults
                ? AppColors.secondary
                : AppColors.divider,
            width: isSelected || isWinning ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texte de l'option avec icône
            Row(
              children: [
                if (!isClosed)
                  Icon(
                    poll.allowMultipleChoices
                        ? (isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank)
                        : (isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked),
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                if (!isClosed) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.text,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isWinning && showResults
                          ? FontWeight.bold
                          : null,
                    ),
                  ),
                ),
                if (isWinning && showResults)
                  const Icon(
                    Icons.emoji_events,
                    color: AppColors.secondary,
                    size: 20,
                  ),
              ],
            ),

            // Barre de progression et stats
            if (showResults) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation(
                    isWinning ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${option.voteCount} vote${option.voteCount > 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isWinning ? AppColors.secondary : null,
                    ),
                  ),
                ],
              ),
              if (hasUserVoted && !poll.isAnonymous)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Vous avez voté pour cette option',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(Poll poll) {
    if (poll.totalVotes == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistiques', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.how_to_vote,
                label: 'Total votes',
                value: poll.totalVotes.toString(),
              ),
              _buildStatItem(
                icon: Icons.list,
                label: 'Options',
                value: poll.options.length.toString(),
              ),
              if (poll.winningOption != null)
                _buildStatItem(
                  icon: Icons.emoji_events,
                  label: 'En tête',
                  value:
                      '${poll.winningOption!.getPercentage(poll.totalVotes).toStringAsFixed(0)}%',
                  color: AppColors.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Future<void> _handleVote(
    Poll poll,
    PollProvider pollProvider,
    String userId,
  ) async {
    setState(() {
      _isVoting = true;
    });

    await pollProvider.vote(poll.id, userId, _selectedOptions.toList());

    setState(() {
      _isVoting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vote enregistré !'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  Future<void> _handleRemoveVote(
    PollProvider pollProvider,
    String userId,
  ) async {
    setState(() {
      _isVoting = true;
    });

    await pollProvider.removeVote(widget.pollId, userId);

    setState(() {
      _isVoting = false;
      _selectedOptions.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vote retiré')));
    }
  }

  Color _getTypeColor(PollType type) {
    switch (type) {
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
