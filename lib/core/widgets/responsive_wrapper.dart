import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Responsive wrapper that adapts layout based on screen size
class ResponsiveWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppDimensions.maxDesktopWidth) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= AppDimensions.maxTabletWidth) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Adaptive padding that adjusts based on screen size
class AdaptivePadding extends StatelessWidget {
  final Widget child;

  const AdaptivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        double horizontalPadding;

        if (screenWidth >= AppDimensions.maxDesktopWidth) {
          horizontalPadding = AppDimensions.paddingXXL.toDouble();
        } else if (screenWidth >= AppDimensions.maxTabletWidth) {
          horizontalPadding = AppDimensions.paddingXL.toDouble();
        } else {
          horizontalPadding = AppDimensions.paddingMD.toDouble();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        );
      },
    );
  }
}

/// Responsive grid that adjusts column count based on screen width
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = AppDimensions.gridSpacing,
    this.runSpacing = AppDimensions.gridSpacing,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= AppDimensions.maxDesktopWidth) {
          crossAxisCount = desktopColumns!;
        } else if (constraints.maxWidth >= AppDimensions.maxTabletWidth) {
          crossAxisCount = tabletColumns!;
        } else {
          crossAxisCount = mobileColumns!;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
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

