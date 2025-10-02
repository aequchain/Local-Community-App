import 'package:flutter/material.dart';

import '../../../../theme/design_tokens.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    required this.isWide,
    required this.onViewRoadmap,
    super.key,
  });

  final bool isWide;
  final VoidCallback onViewRoadmap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Mobilize funding. Unlock jobs. Grow local prosperity.',
          style: theme.textTheme.displayLarge,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
        SizedBox(height: AequusDesignTokens.spacing.s21),
        Text(
          'Phase one delivers a transparent funding and employment hub for '
          'communities worldwide—built entirely on free-tier tooling until '
          'the platform sustains itself.',
          style: theme.textTheme.bodyLarge,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
        SizedBox(height: AequusDesignTokens.spacing.s34),
        Wrap(
          spacing: AequusDesignTokens.spacing.s13,
          runSpacing: AequusDesignTokens.spacing.s13,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: const [
            _PlanChip(label: 'Firebase Spark-tier backend'),
            _PlanChip(label: 'Flutter multi-platform client'),
            _PlanChip(label: 'Geospatial campaign discovery'),
          ],
        ),
        SizedBox(height: AequusDesignTokens.spacing.s34),
        FilledButton.icon(
          onPressed: onViewRoadmap,
          icon: const Icon(Icons.rocket_launch_rounded),
          label: const Text('View build roadmap'),
        ),
      ],
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AequusDesignTokens.spacing.s13,
        vertical: AequusDesignTokens.spacing.s8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: AequusDesignTokens.radii.s13,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.34),
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
