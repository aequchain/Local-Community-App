import 'package:flutter/material.dart';

import '../../../../theme/design_tokens.dart';
import '../../domain/campaign.dart';

class CampaignFilterSheet extends StatefulWidget {
  const CampaignFilterSheet({
    required this.onApply,
    this.initialType,
    this.initialLocation,
    super.key,
  });

  final void Function({
    CampaignType? type,
    String? location,
  }) onApply;

  final CampaignType? initialType;
  final String? initialLocation;

  @override
  State<CampaignFilterSheet> createState() => _CampaignFilterSheetState();
}

class _CampaignFilterSheetState extends State<CampaignFilterSheet> {
  CampaignType? _selectedType;
  String? _locationFilter;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _locationFilter = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AequusDesignTokens.spacing.s21),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter campaigns',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: AequusDesignTokens.spacing.s21),

          // Campaign Type
          Text(
            'Campaign type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AequusDesignTokens.spacing.s13),
          Wrap(
            spacing: AequusDesignTokens.spacing.s8,
            runSpacing: AequusDesignTokens.spacing.s8,
            children: [
              FilterChip(
                label: const Text('All types'),
                selected: _selectedType == null,
                onSelected: (selected) {
                  setState(() => _selectedType = null);
                },
              ),
              ...CampaignType.values.map((type) {
                return FilterChip(
                  label: Text(_formatCampaignType(type)),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() => _selectedType = selected ? type : null);
                  },
                );
              }),
            ],
          ),
          SizedBox(height: AequusDesignTokens.spacing.s21),

          // Location Filter
          Text(
            'Location',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AequusDesignTokens.spacing.s13),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter city or region',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: AequusDesignTokens.radii.s13,
              ),
              suffixIcon: _locationFilter != null && _locationFilter!.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _locationFilter = null);
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() => _locationFilter = value.isEmpty ? null : value);
            },
            controller: TextEditingController(text: _locationFilter ?? ''),
          ),
          SizedBox(height: AequusDesignTokens.spacing.s21),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      _locationFilter = null;
                    });
                  },
                  child: const Text('Clear all'),
                ),
              ),
              SizedBox(width: AequusDesignTokens.spacing.s13),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(
                      type: _selectedType,
                      location: _locationFilter,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply filters'),
                ),
              ),
            ],
          ),
          SizedBox(height: AequusDesignTokens.spacing.s8),
        ],
      ),
    );
  }

  String _formatCampaignType(CampaignType type) {
    return switch (type) {
      CampaignType.businessStartup => 'Business',
      CampaignType.communityProject => 'Community',
      CampaignType.socialInitiative => 'Social',
      CampaignType.infrastructure => 'Infrastructure',
      CampaignType.education => 'Education',
      CampaignType.healthcare => 'Healthcare',
      CampaignType.agriculture => 'Agriculture',
      CampaignType.technology => 'Technology',
    };
  }
}
