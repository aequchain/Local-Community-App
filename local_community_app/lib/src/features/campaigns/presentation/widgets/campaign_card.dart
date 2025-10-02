import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/design_tokens.dart';
import '../../domain/campaign.dart';
import '../campaign_detail_screen.dart';
import 'per_capita_insights.dart';

class CampaignCard extends StatefulWidget {
  const CampaignCard({
    required this.campaign,
    super.key,
  });

  final Campaign campaign;

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: AequusDesignTokens.durations.fast,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final campaign = widget.campaign;
    final currencyFormat = NumberFormat.simpleCurrency(
      name: campaign.fundingGoal.currency,
    );

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          final elevation = 2.0 + (_hoverController.value * 6);
          final scale = 1.0 + (_hoverController.value * 0.02);

          return Transform.scale(
            scale: scale,
            child: Card(
              elevation: elevation,
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          );
        },
        child: InkWell(
          onTap: () {
            context.goNamed(
              CampaignDetailScreen.routeName,
              pathParameters: {'id': campaign.id},
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campaign image
              AspectRatio(
                aspectRatio: 1.618, // Golden ratio
                child: campaign.imageUrl != null
                    ? Image.network(
                        campaign.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 55,
                              color: theme.colorScheme.outline,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.campaign_outlined,
                          size: 55,
                          color: theme.colorScheme.outline,
                        ),
                      ),
              ),

              // Campaign details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AequusDesignTokens.spacing.s13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AequusDesignTokens.spacing.s8,
                          vertical: AequusDesignTokens.spacing.s5,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(campaign.type, theme)
                              .withValues(alpha: 0.13),
                          borderRadius: AequusDesignTokens.radii.s8,
                        ),
                        child: Text(
                          _getCategoryLabel(campaign.type),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getCategoryColor(campaign.type, theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s8),

                      // Title
                      Text(
                        campaign.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s5),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: AequusDesignTokens.spacing.s3),
                          Expanded(
                            child: Text(
                              campaign.location.displayName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Progress bar
                      SizedBox(height: AequusDesignTokens.spacing.s8),
                      ClipRRect(
                        borderRadius: AequusDesignTokens.radii.s8,
                        child: LinearProgressIndicator(
                          value: campaign.fundingGoal.percentageFunded / 100,
                          minHeight: 5,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s8),

                      // Funding stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currencyFormat
                                    .format(campaign.fundingGoal.currentAmount),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                'of ${currencyFormat.format(campaign.fundingGoal.goalAmount)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${campaign.fundingGoal.daysRemaining}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'days left',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s13),
                      PerCapitaInsights.compact(
                        campaign: campaign,
                        fundingGoal: campaign.fundingGoal,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Per-capita insights are rendered by the shared `PerCapitaInsights` widget.

  String _getCategoryLabel(CampaignType type) {
    switch (type) {
      case CampaignType.businessStartup:
        return 'Business startup';
      case CampaignType.communityProject:
        return 'Community project';
      case CampaignType.socialInitiative:
        return 'Social initiative';
      case CampaignType.infrastructure:
        return 'Infrastructure';
      case CampaignType.education:
        return 'Education';
      case CampaignType.healthcare:
        return 'Healthcare';
      case CampaignType.agriculture:
        return 'Agriculture';
      case CampaignType.technology:
        return 'Technology';
    }
  }

  Color _getCategoryColor(CampaignType type, ThemeData theme) {
    switch (type) {
      case CampaignType.businessStartup:
        return AequusDesignTokens.ctaOrange;
      case CampaignType.communityProject:
        return theme.colorScheme.primary;
      case CampaignType.socialInitiative:
        return theme.colorScheme.tertiary;
      case CampaignType.infrastructure:
        return Colors.brown;
      case CampaignType.education:
        return Colors.indigo;
      case CampaignType.healthcare:
        return Colors.red;
      case CampaignType.agriculture:
        return AequusDesignTokens.successGreen;
      case CampaignType.technology:
        return Colors.purple;
    }
  }
}
 
