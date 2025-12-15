import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/buttons.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/poll_provider.dart';
import '../../domain/entities/poll.dart';

/// Écran de création de sondage
class CreatePollScreen extends StatefulWidget {
  final String? eventId;

  const CreatePollScreen({super.key, this.eventId});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  PollType _selectedType = PollType.general;
  DateTime? _deadline;
  bool _allowMultipleChoices = false;
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un sondage')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Question
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Quelle date vous convient ?',
                prefixIcon: Icon(Icons.help_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La question est requise';
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
                hintText: 'Détails du sondage...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              maxLength: 200,
            ),
            const SizedBox(height: 16),

            // Type de sondage
            Text('Type de sondage', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PollType.values.map((type) {
                final isSelected = _selectedType == type;
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
                        _selectedType = type;
                      });
                    }
                  },
                  selectedColor: _getTypeColor(type).withValues(alpha: 0.2),
                  checkmarkColor: _getTypeColor(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Options', style: AppTextStyles.titleSmall),
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._buildOptionFields(),
            const SizedBox(height: 24),

            // Date limite
            Text('Date limite (optionnel)', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.event),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _deadline != null
                      ? 'Ferme le ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                      : 'Aucune date limite',
                  style: _deadline != null
                      ? AppTextStyles.bodyMedium
                      : AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options avancées
            Text('Options avancées', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Votes multiples'),
              subtitle: const Text('Permettre de voter pour plusieurs options'),
              value: _allowMultipleChoices,
              onChanged: (value) {
                setState(() {
                  _allowMultipleChoices = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Vote anonyme'),
              subtitle: const Text('Masquer qui a voté pour quoi'),
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            // Bouton créer
            PrimaryButton(
              text: 'Créer le sondage',
              onPressed: _isLoading ? null : _handleCreatePoll,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionFields() {
    return _optionControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Option ${index + 1}',
                  hintText: 'Entrez une option',
                  prefixIcon: const Icon(Icons.radio_button_unchecked),
                ),
                validator: (value) {
                  if (index < 2 && (value == null || value.trim().isEmpty)) {
                    return 'Les 2 premières options sont requises';
                  }
                  return null;
                },
              ),
            ),
            if (index >= 2) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                onPressed: () => _removeOption(index),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  void _addOption() {
    if (_optionControllers.length < 10) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 options'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _deadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleCreatePoll() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier qu'il y a au moins 2 options non vides
    final validOptions = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (validOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Au moins 2 options sont requises'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final pollProvider = context.read<PollProvider>();

    final userId = authProvider.currentUser?.id ?? 'user_1';
    final eventId = widget.eventId ?? 'event_1';

    final poll = await pollProvider.createPoll(
      question: _questionController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      eventId: eventId,
      creatorId: userId,
      type: _selectedType,
      optionTexts: validOptions,
      deadline: _deadline,
      allowMultipleChoices: _allowMultipleChoices,
      isAnonymous: _isAnonymous,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted && poll != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sondage créé avec succès !'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.of(context).pop();
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
