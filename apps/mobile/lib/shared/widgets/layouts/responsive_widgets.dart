import 'package:flutter/material.dart';
import '../../../core/theme/app_breakpoints.dart';

/// Widget qui affiche différents layouts selon la taille d'écran
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (AppBreakpoints.isDesktop(width) && desktop != null) {
          return desktop!;
        }

        if (AppBreakpoints.isTablet(width) && tablet != null) {
          return tablet!;
        }

        return mobile;
      },
    );
  }
}

/// GridView avec colonnes adaptatives selon taille écran
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppBreakpoints.getGridColumns(constraints.maxWidth);

        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Container avec max width pour limiter la largeur du contenu
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = AppBreakpoints.getMaxContentWidth(
          constraints.maxWidth,
        );
        final horizontalPadding = AppBreakpoints.getHorizontalPadding(
          constraints.maxWidth,
        );

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding:
                padding ?? EdgeInsets.symmetric(horizontal: horizontalPadding),
            color: color,
            child: child,
          ),
        );
      },
    );
  }
}

/// Padding adaptatif selon taille écran
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final bool horizontal;
  final bool vertical;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.horizontal = true,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final paddingValue = AppBreakpoints.getHorizontalPadding(
          constraints.maxWidth,
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal ? paddingValue : 0,
            vertical: vertical ? paddingValue : 0,
          ),
          child: child,
        );
      },
    );
  }
}

/// Extension pour obtenir facilement les infos responsives
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => AppBreakpoints.isMobile(screenWidth);
  bool get isTablet => AppBreakpoints.isTablet(screenWidth);
  bool get isDesktop => AppBreakpoints.isDesktop(screenWidth);
  bool get isWide => AppBreakpoints.isWide(screenWidth);

  int get gridColumns => AppBreakpoints.getGridColumns(screenWidth);
  double get responsivePadding =>
      AppBreakpoints.getHorizontalPadding(screenWidth);
  double get maxContentWidth => AppBreakpoints.getMaxContentWidth(screenWidth);
}
