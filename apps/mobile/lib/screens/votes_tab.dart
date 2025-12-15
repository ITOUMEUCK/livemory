import 'package:flutter/material.dart';
import '../models/vote.dart';
import '../services/vote_service.dart';

class VotesTab extends StatefulWidget {
  final String eventId;

  const VotesTab({super.key, required this.eventId});

  @override
  State<VotesTab> createState() => _VotesTabState();
}

class _VotesTabState extends State<VotesTab> {
  final VoteService _service = VoteService();
  List<Vote> _votes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVotes();
  }

  Future<void> _loadVotes() async {
    setState(() => _isLoading = true);
    try {
      final votes = await _service.getEventVotes(widget.eventId);
      setState(() {
        _votes = votes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showCreateVoteDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer un vote'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: _votes.isEmpty
              ? const Center(child: Text('Aucun vote'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _votes.length,
                  itemBuilder: (context, index) {
                    final vote = _votes[index];
                    return _VoteCard(
                      vote: vote,
                      onVote: (optionIds) => _castVote(vote.id, optionIds),
                      onClose: () => _closeVote(vote.id),
                      onDelete: () => _deleteVote(vote.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreateVoteDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un vote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Create vote
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _castVote(String voteId, List<String> optionIds) async {
    try {
      await _service.castVote(widget.eventId, voteId, optionIds);
      _loadVotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _closeVote(String voteId) async {
    try {
      await _service.closeVote(widget.eventId, voteId);
      _loadVotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _deleteVote(String voteId) async {
    try {
      await _service.deleteVote(widget.eventId, voteId);
      _loadVotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}

class _VoteCard extends StatelessWidget {
  final Vote vote;
  final Function(List<String>) onVote;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const _VoteCard({
    required this.vote,
    required this.onVote,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vote.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(status: vote.status),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    if (vote.status == VoteStatus.active)
                      const PopupMenuItem(
                        value: 'close',
                        child: Row(
                          children: [
                            Icon(Icons.close),
                            SizedBox(width: 8),
                            Text('Clôturer'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'close') {
                      onClose();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(vote.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.how_to_vote, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${vote.totalVotes} vote(s)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(
                  _getVoteTypeIcon(vote.type),
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getVoteTypeLabel(vote.type),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...vote.options.map(
              (option) => _VoteOptionCard(
                option: option,
                totalVotes: vote.totalVotes,
                isActive: vote.status == VoteStatus.active,
                allowMultiple: vote.allowMultipleChoices,
                onVote: () => onVote([option.id]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVoteTypeIcon(VoteType type) {
    switch (type) {
      case VoteType.location:
        return Icons.location_on;
      case VoteType.datetime:
        return Icons.calendar_today;
      case VoteType.activity:
        return Icons.local_activity;
      case VoteType.other:
        return Icons.more_horiz;
    }
  }

  String _getVoteTypeLabel(VoteType type) {
    switch (type) {
      case VoteType.location:
        return 'Lieu';
      case VoteType.datetime:
        return 'Date/Heure';
      case VoteType.activity:
        return 'Activité';
      case VoteType.other:
        return 'Autre';
    }
  }
}

class _VoteOptionCard extends StatelessWidget {
  final VoteOption option;
  final int totalVotes;
  final bool isActive;
  final bool allowMultiple;
  final VoidCallback onVote;

  const _VoteOptionCard({
    required this.option,
    required this.totalVotes,
    required this.isActive,
    required this.allowMultiple,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalVotes > 0
        ? (option.voteCount / totalVotes * 100)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isActive ? onVote : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      option.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${option.voteCount} vote(s)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (option.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  option.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final VoteStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == VoteStatus.active ? Colors.green : Colors.grey;
    final label = status == VoteStatus.active ? 'Actif' : 'Clôturé';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
