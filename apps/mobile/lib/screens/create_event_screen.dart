import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  EventType _selectedType = EventType.weekend;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<_StepData> _steps = [];
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _steps.add(
        _StepData(
          title: '',
          description: '',
          startDateTime: DateTime.now(),
          order: _steps.length,
        ),
      );
    });

    // Naviguer vers la page de la nouvelle étape
    Future.delayed(const Duration(milliseconds: 100), () {
      _pageController.animateToPage(
        _steps.length,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Réorganiser les ordres
      for (int i = 0; i < _steps.length; i++) {
        _steps[i].order = i;
      }
    });
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate steps
    bool stepsValid = true;
    for (var step in _steps) {
      if (step.title.trim().isEmpty || step.description.trim().isEmpty) {
        stepsValid = false;
        break;
      }
    }

    if (!stepsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir toutes les étapes')),
      );
      return;
    }

    final event = Event(
      id: '', // Will be set by backend
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType.toString().split('.').last,
      creatorId: 'current_user_id', // TODO: Get from auth
      startDate: _startDate,
      endDate: _endDate,
      steps: _steps
          .map(
            (stepData) => EventStep(
              id: '', // Will be set by backend
              eventId: '', // Will be set by backend
              title: stepData.title,
              description: stepData.description,
              startDateTime: stepData.startDateTime,
              endDateTime: stepData.endDateTime,
              location: stepData.location,
              order: stepData.order,
            ),
          )
          .toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<EventProvider>();
    final createdEvent = await provider.createEvent(event);

    if (createdEvent != null && mounted) {
      Navigator.pushReplacementNamed(context, '/event/${createdEvent.id}');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Erreur lors de la création')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un événement'),
        actions: [
          TextButton(
            onPressed: _createEvent,
            child: const Text('Créer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / (_steps.length + 1),
          ),

          // Page indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _currentPage == 0
                  ? 'Informations de base'
                  : 'Étape ${_currentPage} / ${_steps.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildBasicInfoPage(),
                ..._steps.asMap().entries.map((entry) {
                  return _buildStepPage(entry.key, entry.value);
                }),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                  )
                else
                  const SizedBox.shrink(),

                ElevatedButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une étape'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),

                if (_currentPage < _steps.length)
                  ElevatedButton.icon(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Suivant'),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de base',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'événement',
                prefixIcon: Icon(Icons.event),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<EventType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type d\'événement',
                prefixIcon: Icon(Icons.category),
              ),
              items: EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getEventTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date de début'),
              subtitle: Text(_formatDate(_startDate)),
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  currentTime: _startDate,
                  locale: LocaleType.fr,
                  onConfirm: (date) {
                    setState(() => _startDate = date);
                  },
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Date de fin (optionnel)'),
              subtitle: Text(
                _endDate != null ? _formatDate(_endDate!) : 'Non définie',
              ),
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  currentTime: _endDate ?? _startDate,
                  minTime: _startDate,
                  locale: LocaleType.fr,
                  onConfirm: (date) {
                    setState(() => _endDate = date);
                  },
                );
              },
              trailing: _endDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPage(int index, _StepData stepData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Étape ${index + 1}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeStep(index),
              ),
            ],
          ),
          const SizedBox(height: 24),

          TextFormField(
            initialValue: stepData.title,
            decoration: const InputDecoration(
              labelText: 'Titre de l\'étape',
              prefixIcon: Icon(Icons.label),
            ),
            onChanged: (value) => stepData.title = value,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: stepData.description,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 3,
            onChanged: (value) => stepData.description = value,
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Date et heure de début'),
            subtitle: Text(_formatDateTime(stepData.startDateTime)),
            onTap: () {
              DatePicker.showDateTimePicker(
                context,
                currentTime: stepData.startDateTime,
                minTime: _startDate,
                maxTime: _endDate,
                locale: LocaleType.fr,
                onConfirm: (date) {
                  setState(() => stepData.startDateTime = date);
                },
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.timer_off),
            title: const Text('Date et heure de fin (optionnel)'),
            subtitle: Text(
              stepData.endDateTime != null
                  ? _formatDateTime(stepData.endDateTime!)
                  : 'Non définie',
            ),
            onTap: () {
              DatePicker.showDateTimePicker(
                context,
                currentTime: stepData.endDateTime ?? stepData.startDateTime,
                minTime: stepData.startDateTime,
                maxTime: _endDate,
                locale: LocaleType.fr,
                onConfirm: (date) {
                  setState(() => stepData.endDateTime = date);
                },
              );
            },
            trailing: stepData.endDateTime != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () =>
                        setState(() => stepData.endDateTime = null),
                  )
                : null,
          ),

          const SizedBox(height: 16),
          TextFormField(
            initialValue: stepData.location,
            decoration: const InputDecoration(
              labelText: 'Lieu (optionnel)',
              prefixIcon: Icon(Icons.location_on),
            ),
            onChanged: (value) => stepData.location = value,
          ),
        ],
      ),
    );
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.weekend:
        return 'Week-end';
      case EventType.soiree:
        return 'Soirée';
      case EventType.citytrip:
        return 'City Trip';
      case EventType.vacation:
        return 'Vacances';
      case EventType.other:
        return 'Autre';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StepData {
  String title;
  String description;
  DateTime startDateTime;
  DateTime? endDateTime;
  String? location;
  int order;

  _StepData({
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.order,
  });
}
