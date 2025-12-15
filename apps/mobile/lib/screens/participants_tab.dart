import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../services/participant_service.dart';

class ParticipantsTab extends StatefulWidget {
  final String eventId;

  const ParticipantsTab({super.key, required this.eventId});

  @override
  State<ParticipantsTab> createState() => _ParticipantsTabState();
}

class _ParticipantsTabState extends State<ParticipantsTab> {
  final ParticipantService _service = ParticipantService();
  List<Participant> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() => _isLoading = true);
    try {
      final participants = await _service.getEventParticipants(widget.eventId);
      setState(() {
        _participants = participants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
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
            onPressed: _showAddParticipantDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Ajouter un participant'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: _participants.isEmpty
              ? const Center(child: Text('Aucun participant'))
              : ListView.builder(
                  itemCount: _participants.length,
                  itemBuilder: (context, index) {
                    final participant = _participants[index];
                    return _ParticipantCard(
                      participant: participant,
                      onRemove: () => _removeParticipant(participant.id),
                      onRoleChange: (role) => _updateRole(participant.id, role),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddParticipantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un participant'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Email ou nom d\'utilisateur',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add participant logic
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeParticipant(String participantId) async {
    try {
      await _service.removeParticipant(widget.eventId, participantId);
      _loadParticipants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _updateRole(String participantId, ParticipantRole role) async {
    try {
      await _service.updateParticipant(
        widget.eventId,
        participantId,
        role: role,
      );
      _loadParticipants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}

class _ParticipantCard extends StatelessWidget {
  final Participant participant;
  final VoidCallback onRemove;
  final Function(ParticipantRole) onRoleChange;

  const _ParticipantCard({
    required this.participant,
    required this.onRemove,
    required this.onRoleChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: participant.avatarUrl != null
              ? NetworkImage(participant.avatarUrl!)
              : null,
          child: participant.avatarUrl == null
              ? Text(participant.name[0].toUpperCase())
              : null,
        ),
        title: Text(participant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (participant.email != null) Text(participant.email!),
            const SizedBox(height: 4),
            Row(
              children: [
                _RoleBadge(role: participant.role),
                const SizedBox(width: 8),
                if (!participant.hasAccepted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'En attente',
                      style: TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'change_role',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Changer le rôle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Retirer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'remove') {
              onRemove();
            } else if (value == 'change_role') {
              _showRoleDialog(context);
            }
          },
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le rôle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ParticipantRole.values.map((role) {
            return RadioListTile<ParticipantRole>(
              title: Text(_getRoleLabel(role)),
              value: role,
              groupValue: participant.role,
              onChanged: (value) {
                if (value != null) {
                  onRoleChange(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getRoleLabel(ParticipantRole role) {
    switch (role) {
      case ParticipantRole.organizer:
        return 'Organisateur';
      case ParticipantRole.admin:
        return 'Administrateur';
      case ParticipantRole.member:
        return 'Membre';
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final ParticipantRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (role) {
      case ParticipantRole.organizer:
        color = Colors.purple;
        label = 'Organisateur';
        break;
      case ParticipantRole.admin:
        color = Colors.blue;
        label = 'Admin';
        break;
      case ParticipantRole.member:
        color = Colors.grey;
        label = 'Membre';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
