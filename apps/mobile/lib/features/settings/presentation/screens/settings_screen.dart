import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_provider.dart' as app_theme;

/// Écran des paramètres
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          // Section Apparence
          _SectionHeader(title: 'Apparence'),
          _ThemeSetting(),
          const Divider(),

          // Section Notifications
          _SectionHeader(title: 'Notifications'),
          _NotificationSetting(
            title: 'Notifications push',
            subtitle: 'Recevoir des notifications sur votre appareil',
            value: true,
            onChanged: (value) {
              _showComingSoon(context, 'Notifications push');
            },
          ),
          _NotificationSetting(
            title: 'Invitations',
            subtitle: 'Être notifié des invitations aux groupes',
            value: true,
            onChanged: (value) {},
          ),
          _NotificationSetting(
            title: 'Événements',
            subtitle: 'Rappels des événements à venir',
            value: true,
            onChanged: (value) {},
          ),
          _NotificationSetting(
            title: 'Sondages',
            subtitle: 'Nouveaux sondages dans vos groupes',
            value: false,
            onChanged: (value) {},
          ),
          _NotificationSetting(
            title: 'Dépenses',
            subtitle: 'Nouvelles dépenses et demandes de remboursement',
            value: true,
            onChanged: (value) {},
          ),
          const Divider(),

          // Section Langue
          _SectionHeader(title: 'Langue'),
          _LanguageSetting(),
          const Divider(),

          // Section Confidentialité
          _SectionHeader(title: 'Confidentialité'),
          _SettingTile(
            icon: Icons.visibility_outlined,
            title: 'Profil visible',
            subtitle: 'Qui peut voir votre profil',
            trailing: const Text('Mes groupes'),
            onTap: () {
              _showComingSoon(context, 'Visibilité du profil');
            },
          ),
          _SettingTile(
            icon: Icons.block_outlined,
            title: 'Utilisateurs bloqués',
            subtitle: 'Gérer les utilisateurs bloqués',
            onTap: () {
              _showComingSoon(context, 'Utilisateurs bloqués');
            },
          ),
          const Divider(),

          // Section Données
          _SectionHeader(title: 'Données'),
          _SettingTile(
            icon: Icons.storage_outlined,
            title: 'Espace de stockage',
            subtitle: '125 MB utilisés',
            onTap: () {
              _showComingSoon(context, 'Espace de stockage');
            },
          ),
          _SettingTile(
            icon: Icons.download_outlined,
            title: 'Télécharger mes données',
            subtitle: 'Exporter toutes vos données',
            onTap: () {
              _showComingSoon(context, 'Export de données');
            },
          ),
          _SettingTile(
            icon: Icons.delete_outline,
            title: 'Supprimer le compte',
            subtitle: 'Supprimer définitivement votre compte',
            textColor: AppColors.error,
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
          const Divider(),

          // Section À propos
          _SectionHeader(title: 'À propos'),
          _SettingTile(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            onTap: () {
              _showComingSoon(context, 'Conditions d\'utilisation');
            },
          ),
          _SettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            onTap: () {
              _showComingSoon(context, 'Politique de confidentialité');
            },
          ),
          _SettingTile(
            icon: Icons.info_outline,
            title: 'Version',
            trailing: const Text('1.0.0'),
            onTap: () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature - Bientôt disponible !')));
  }

  static Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? '
          'Cette action est irréversible et toutes vos données seront supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _showComingSoon(context, 'Suppression du compte');
    }
  }
}

/// En-tête de section
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Widget pour le paramètre de thème
class _ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<app_theme.ThemeProvider>();

    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Thème'),
      subtitle: Text(_getThemeLabel(themeProvider.themeMode)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        _showThemeDialog(context, themeProvider);
      },
    );
  }

  String _getThemeLabel(app_theme.AppThemeMode mode) {
    switch (mode) {
      case app_theme.AppThemeMode.light:
        return 'Clair';
      case app_theme.AppThemeMode.dark:
        return 'Sombre';
      case app_theme.AppThemeMode.system:
        return 'Système';
    }
  }

  Future<void> _showThemeDialog(
    BuildContext context,
    app_theme.ThemeProvider themeProvider,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              title: 'Clair',
              icon: Icons.light_mode,
              isSelected:
                  themeProvider.themeMode == app_theme.AppThemeMode.light,
              onTap: () {
                themeProvider.setThemeMode(app_theme.AppThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              title: 'Sombre',
              icon: Icons.dark_mode,
              isSelected:
                  themeProvider.themeMode == app_theme.AppThemeMode.dark,
              onTap: () {
                themeProvider.setThemeMode(app_theme.AppThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              title: 'Système',
              icon: Icons.auto_awesome,
              isSelected:
                  themeProvider.themeMode == app_theme.AppThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(app_theme.AppThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Option de thème dans le dialog
class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

/// Widget pour le paramètre de langue
class _LanguageSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Langue'),
      subtitle: const Text('Français'),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        _showLanguageDialog(context);
      },
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              title: 'Français',
              flag: '🇫🇷',
              isSelected: true,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            _LanguageOption(
              title: 'English',
              flag: '🇬🇧',
              isSelected: false,
              onTap: () {
                Navigator.of(context).pop();
                SettingsScreen._showComingSoon(context, 'English');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Option de langue dans le dialog
class _LanguageOption extends StatelessWidget {
  final String title;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

/// Widget pour un paramètre avec switch
class _NotificationSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}

/// Widget générique pour un paramètre
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? textColor;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(color: textColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
