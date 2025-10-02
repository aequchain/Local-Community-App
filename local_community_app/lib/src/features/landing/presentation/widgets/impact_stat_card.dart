import 'package:flutter/material.dart';

import '../../../../theme/design_tokens.dart';

class ImpactStatCard extends StatelessWidget {
  const ImpactStatCard({
    required this.onStudyArchitecture,
    super.key,
  });

  final VoidCallback onStudyArchitecture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Per-capita funding snapshot',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: AequusDesignTokens.spacing.s21),
            _StatRow(
              label: 'Target city population',
              value: '1,300,000',
            ),
            SizedBox(height: AequusDesignTokens.spacing.s13),
            _StatRow(
              label: 'Goal amount (pilot campaign)',
              value: r'$24,550,000',
            ),
            SizedBox(height: AequusDesignTokens.spacing.s13),
            _StatRow(
              label: 'Were everyone to contribute',
              value: r'$2.10 each',
            ),
            SizedBox(height: AequusDesignTokens.spacing.s34),
            Text(
              'We will replace these placeholders with live telemetry once '
              'Firestore and Cloud Functions are wired to the wallet and '
              'campaign modules.',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: AequusDesignTokens.spacing.s34),
            FilledButton(
              onPressed: onStudyArchitecture,
              child: const Text('Study the technical architecture'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        SizedBox(width: AequusDesignTokens.spacing.s13),
        Text(
          value,
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
