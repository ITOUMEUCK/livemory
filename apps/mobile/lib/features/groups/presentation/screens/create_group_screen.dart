import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/buttons/buttons.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../../domain/entities/group.dart';

/// Écran de création d'un groupe
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isPrivate = false;
  bool _allowMemberInvite = true;
  bool _requireAdminApproval = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final groupProvider = context.read<GroupProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final settings = GroupSettings(
        isPrivate: _isPrivate,
        allowMemberInvite: _allowMemberInvite,
        requireAdminApproval: _requireAdminApproval,
      );

      final success = await groupProvider.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        creatorId: authProvider.currentUser!.id,
        settings: settings,
      );

      if (!mounted) return;

      if (success) {
        context.showSuccessSnackBar('Groupe créé avec succès ! 🎉');
        Navigator.of(context).pop();
      } else {
        context.showErrorSnackBar(
          groupProvider.errorMessage ?? 'Erreur lors de la création du groupe',
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau groupe')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo du groupe (placeholder)
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.groups,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nom du groupe
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              enabled: !_isLoading,
              validator: Validators.required,
              decoration: InputDecoration(
                labelText: 'Nom du groupe *',
                hintText: 'Ex: Famille, Amis Promo 2020...',
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              enabled: !_isLoading,
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'De quoi parlera ce groupe ?',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Paramètres
            Text('Paramètres', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),

            _SettingTile(
              icon: Icons.lock,
              title: 'Groupe privé',
              subtitle: 'Seuls les membres invités peuvent rejoindre',
              value: _isPrivate,
              enabled: !_isLoading,
              onChanged: (value) {
                setState(() => _isPrivate = value);
              },
            ),

            _SettingTile(
              icon: Icons.person_add,
              title: 'Autoriser les invitations',
              subtitle: 'Les membres peuvent inviter d\'autres personnes',
              value: _allowMemberInvite,
              enabled: !_isLoading,
              onChanged: (value) {
                setState(() => _allowMemberInvite = value);
              },
            ),

            _SettingTile(
              icon: Icons.admin_panel_settings,
              title: 'Approbation admin requise',
              subtitle: 'Les admins doivent approuver les nouveaux membres',
              value: _requireAdminApproval,
              enabled: !_isLoading && _isPrivate,
              onChanged: (value) {
                setState(() => _requireAdminApproval = value);
              },
            ),

            const SizedBox(height: 32),

            // Bouton créer
            PrimaryButton(
              text: 'Créer le groupe',
              onPressed: _handleCreateGroup,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile pour un paramètre avec switch
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
          ),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
