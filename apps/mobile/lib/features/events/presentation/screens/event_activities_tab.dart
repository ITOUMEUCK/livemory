import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/activity_provider.dart';
import '../../domain/entities/activity.dart';
import '../widgets/activity_card.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

/// Écran affichant les activités d'un événement
class EventActivitiesTab extends StatefulWidget {
  final String eventId;
  final VoidCallback? onAddActivity;

  const EventActivitiesTab({
    super.key,
    required this.eventId,
    this.onAddActivity,
  });

  @override
  State<EventActivitiesTab> createState() => EventActivitiesTabState();
}

class EventActivitiesTabState extends State<EventActivitiesTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ActivityProvider>().fetchActivities(widget.eventId),
    );
  }

  // Méthode publique pour afficher le dialogue depuis l'extérieur
  void showActivityDialog([Activity? activity]) {
    _showActivityDialog(activity);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final activities = activityProvider.getActivitiesByEvent(
          widget.eventId,
        );

        if (activityProvider.isLoading && activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 80,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune activité',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez des activités pour organiser votre événement',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ActivityCard(
              activity: activity,
              onTap: () => _showActivityDialog(activity),
              onDelete: () => _deleteActivity(activity.id),
            );
          },
        );
      },
    );
  }

  Future<void> _showActivityDialog([Activity? activity]) async {
    final titleController = TextEditingController(text: activity?.title);
    final descController = TextEditingController(text: activity?.description);
    final locationController = TextEditingController(text: activity?.location);
    DateTime selectedDate = activity?.dateTime ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            activity == null ? 'Nouvelle activité' : 'Modifier l\'activité',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Lieu',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                  ),
                  onTap: () {
                    picker.DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      onConfirm: (date) {
                        setState(() => selectedDate = date);
                      },
                      currentTime: selectedDate,
                      locale: picker.LocaleType.fr,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => _saveActivity(
                activity,
                titleController.text,
                descController.text,
                locationController.text,
                selectedDate,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveActivity(
    Activity? existingActivity,
    String title,
    String description,
    String location,
    DateTime dateTime,
  ) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le titre est requis')));
      return;
    }

    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    final now = DateTime.now();

    final activity = Activity(
      id: existingActivity?.id ?? const Uuid().v4(),
      eventId: widget.eventId,
      title: title.trim(),
      description: description.trim().isEmpty ? null : description.trim(),
      dateTime: dateTime,
      location: location.trim().isEmpty ? null : location.trim(),
      createdBy: existingActivity?.createdBy ?? userId,
      createdAt: existingActivity?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (existingActivity == null) {
        await context.read<ActivityProvider>().addActivity(activity);
      } else {
        await context.read<ActivityProvider>().updateActivity(activity);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _deleteActivity(String activityId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'activité'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette activité ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ActivityProvider>().deleteActivity(activityId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }
}
