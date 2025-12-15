import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/buttons.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../providers/budget_provider.dart';
import '../../domain/entities/budget.dart';

/// Écran de création de budget
class CreateBudgetScreen extends StatefulWidget {
  final String? eventId;

  const CreateBudgetScreen({super.key, this.eventId});

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  SplitType _selectedSplitType = SplitType.equal;
  List<String> _selectedParticipants = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si lié à un événement, pré-remplir avec les participants
    if (widget.eventId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final eventProvider = context.read<EventProvider>();
        final event = eventProvider.events
            .where((e) => e.id == widget.eventId)
            .firstOrNull;
        if (event != null) {
          setState(() {
            _selectedParticipants = List.from(event.participantIds);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nom du budget
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du budget',
                hintText: 'Budget Week-end',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Détails du budget...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              maxLength: 200,
            ),
            const SizedBox(height: 16),

            // Montant total
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Montant total',
                hintText: '1000',
                prefixIcon: Icon(Icons.euro),
                suffixText: '€',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le montant est requis';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Montant invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Type de répartition
            Text('Type de répartition', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SplitType.values.map((type) {
                final isSelected = _selectedSplitType == type;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 4),
                      Text(type.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSplitType = type;
                      });
                    }
                  },
                  selectedColor: _getSplitTypeColor(
                    type,
                  ).withValues(alpha: 0.2),
                  checkmarkColor: _getSplitTypeColor(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getSplitTypeDescription(_selectedSplitType),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Participants
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Participants', style: AppTextStyles.titleSmall),
                TextButton.icon(
                  onPressed: _showParticipantSelector,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_selectedParticipants.isEmpty)
              Container(
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
                        Icons.people,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun participant',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ajoutez au moins 2 participants',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedParticipants.map((userId) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        userId.substring(userId.length - 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    label: Text('Utilisateur $userId'),
                    onDeleted: () {
                      setState(() {
                        _selectedParticipants.remove(userId);
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),

            // Bouton créer
            PrimaryButton(
              text: 'Créer le budget',
              onPressed: _isLoading ? null : _handleCreateBudget,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _showParticipantSelector() {
    // Simuler une liste d'utilisateurs disponibles
    final availableUsers = ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Sélectionner participants'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: availableUsers.map((userId) {
                    final isSelected = _selectedParticipants.contains(userId);
                    return CheckboxListTile(
                      title: Text('Utilisateur $userId'),
                      value: isSelected,
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            if (!_selectedParticipants.contains(userId)) {
                              _selectedParticipants.add(userId);
                            }
                          } else {
                            _selectedParticipants.remove(userId);
                          }
                        });
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleCreateBudget() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedParticipants.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Au moins 2 participants sont requis'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final budgetProvider = context.read<BudgetProvider>();
    final eventId = widget.eventId ?? 'event_1';

    final budget = await budgetProvider.createBudget(
      eventId: eventId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      totalAmount: double.parse(_amountController.text),
      splitType: _selectedSplitType,
      participantIds: _selectedParticipants,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted && budget != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget créé avec succès !'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Color _getSplitTypeColor(SplitType type) {
    if (type == SplitType.equal) {
      return AppColors.primary;
    } else if (type == SplitType.percentage) {
      return AppColors.secondary;
    } else {
      return Colors.orange;
    }
  }

  String _getSplitTypeDescription(SplitType type) {
    if (type == SplitType.equal) {
      return 'Le montant sera divisé équitablement entre tous les participants';
    } else if (type == SplitType.percentage) {
      return 'Vous pourrez définir un pourcentage pour chaque participant';
    } else {
      return 'Vous pourrez définir un montant personnalisé pour chaque dépense';
    }
  }
}
