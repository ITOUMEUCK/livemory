import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Widget pour afficher l'avatar et le nom d'un utilisateur
class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;
  final bool showName;
  final Widget? badge;

  const UserAvatar({
    super.key,
    required this.userId,
    this.radius = 24,
    this.showName = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildFallback(userId.substring(0, 1));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        // Essayer d'abord 'name', puis 'firstName' + 'lastName' pour compatibilité
        String name = userData['name'] as String? ?? '';
        if (name.isEmpty) {
          final firstName = userData['firstName'] as String? ?? '';
          final lastName = userData['lastName'] as String? ?? '';
          name = '$firstName $lastName'.trim();
        }

        final photoUrl = userData['photoUrl'] as String?;
        final initial = name.isNotEmpty
            ? name[0].toUpperCase()
            : userId[0].toUpperCase();

        if (!showName) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: radius,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: photoUrl == null
                    ? Text(
                        initial,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: radius * 0.6,
                        ),
                      )
                    : null,
              ),
              if (badge != null) Positioned(bottom: 0, right: 0, child: badge!),
            ],
          );
        }

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: radius,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: photoUrl == null
                      ? Text(
                          initial,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: radius * 0.6,
                          ),
                        )
                      : null,
                ),
                if (badge != null)
                  Positioned(bottom: 0, right: 0, child: badge!),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name.isNotEmpty ? name : 'Utilisateur',
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallback(String initial) {
    if (!showName) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          initial.toUpperCase(),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontSize: radius * 0.6,
          ),
        ),
      );
    }

    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            initial.toUpperCase(),
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontSize: radius * 0.6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Utilisateur',
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Widget pour afficher juste le nom d'un utilisateur
class UserName extends StatelessWidget {
  final String userId;
  final TextStyle? style;

  const UserName({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('Utilisateur', style: style);
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        // Essayer d'abord 'name', puis 'firstName' + 'lastName' pour compatibilité
        String name = userData['name'] as String? ?? '';
        if (name.isEmpty) {
          final firstName = userData['firstName'] as String? ?? '';
          final lastName = userData['lastName'] as String? ?? '';
          name = '$firstName $lastName'.trim();
        }

        return Text(name.isNotEmpty ? name : 'Utilisateur', style: style);
      },
    );
  }
}
