import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Card de base avec style Livemory
class BaseCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;

  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          margin ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingS / 2,
          ),
      elevation: elevation ?? 0,
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppConstants.spacingL),
          child: child,
        ),
      ),
    );
  }
}

/// Card avec image en haut
class ImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double imageHeight;

  const ImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.imageHeight = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingS / 2,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Image.network(
              imageUrl,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: imageHeight,
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                );
              },
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: AppConstants.spacingS),
                        trailing!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
