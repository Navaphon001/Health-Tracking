import 'package:flutter/material.dart';

class ChartStyle {
  static Color seriesColor(BuildContext ctx) => Theme.of(ctx).colorScheme.primary;

  static LinearGradient areaGradient(BuildContext ctx) => LinearGradient(
        colors: [
          seriesColor(ctx).withValues(alpha: .28),
          seriesColor(ctx).withValues(alpha: .08),
          seriesColor(ctx).withValues(alpha: .00),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static TextStyle axisLabel(BuildContext ctx) =>
      Theme.of(ctx).textTheme.labelSmall!.copyWith(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: .65),
          );

  static TextStyle tooltipText(BuildContext ctx) =>
      Theme.of(ctx).textTheme.labelMedium!.copyWith(
            color: Theme.of(ctx).colorScheme.onPrimary,
          );

  // สีกริด
  static Color gridColor(BuildContext ctx) =>
      Theme.of(ctx).colorScheme.outlineVariant.withValues(alpha: .35);
}
