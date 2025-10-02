import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/design_tokens.dart';
import '../../domain/campaign.dart';

/// Shared per-capita insights widget used by campaign card and detail screens.
class PerCapitaInsights extends StatelessWidget {
  const PerCapitaInsights.compact({
    required this.campaign,
    required this.fundingGoal,
    this.compact = true,
    super.key,
  });

  final Campaign campaign;
  final FundingGoal fundingGoal;
  final bool compact;

  NumberFormat _adaptiveFormatter(double amount, String currency) {
    final absAmount = amount.abs();
    final int decimals;
    if (absAmount >= 1.0) {
      decimals = 2;
    } else if (absAmount >= 0.01) {
      decimals = 2;
    } else if (absAmount >= 0.001) {
      decimals = 3;
    } else {
      decimals = 4;
    }

    return NumberFormat.simpleCurrency(name: currency, decimalDigits: decimals);
  }

  List<_PerCapitaEntry> _buildEntries() {
    return <_PerCapitaEntry>[
      if (campaign.location.regionPopulation != null)
        _PerCapitaEntry(
          label: campaign.location.region,
          population: campaign.location.regionPopulation!,
          scope: 'region',
        ),
      if (campaign.location.cityPopulation != null)
        _PerCapitaEntry(
          label: campaign.location.city,
          population: campaign.location.cityPopulation!,
          scope: 'community',
        ),
      if (campaign.location.countryPopulation != null)
        _PerCapitaEntry(
          label: campaign.location.country,
          population: campaign.location.countryPopulation!,
          scope: 'nation',
        ),
    ];
  }

  Color _colorForScope(ColorScheme cs, String scope) {
    return switch (scope) {
      'community' => cs.secondary,
      'region' => cs.tertiary,
      _ => cs.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (fundingGoal.remainingAmount <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final entries = _buildEntries();
    if (entries.isEmpty) return const SizedBox.shrink();

    final widgets = <Widget>[];

    for (final e in entries) {
      final amount = fundingGoal.perCapitaAmount(e.population);
      if (amount == null) continue;

      final formatter = _adaptiveFormatter(amount, fundingGoal.currency);
      final formatted = formatter.format(amount);
      final color = _colorForScope(theme.colorScheme, e.scope);

      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.equalizer_rounded,
            size: compact ? 16 : 18,
            color: color.withValues(alpha: 0.75),
          ),
          SizedBox(width: AequusDesignTokens.spacing.s8),
          Expanded(
            child: RichText(
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
                    ?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.9), height: 1.4),
                children: [
                  TextSpan(
                    text: formatted,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                  const TextSpan(text: ' from each '),
                  TextSpan(
                    text: e.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

      widgets.add(Padding(
        padding: EdgeInsets.only(bottom: compact ? AequusDesignTokens.spacing.s5 : AequusDesignTokens.spacing.s8),
        child: row,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _PerCapitaEntry {
  const _PerCapitaEntry({required this.label, required this.population, required this.scope});
  final String label;
  final int population;
  final String scope;
}
