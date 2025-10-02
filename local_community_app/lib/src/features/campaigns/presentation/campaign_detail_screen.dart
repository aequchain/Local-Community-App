import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/design_tokens.dart';
import '../application/campaign_service.dart';
import '../domain/campaign.dart';
import 'widgets/per_capita_insights.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  const CampaignDetailScreen({
    required this.campaignId,
    super.key,
  });

  final String campaignId;
  static const routeName = 'campaign-detail';

  @override
  ConsumerState<CampaignDetailScreen> createState() =>
      _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AequusDesignTokens.durations.deliberate, // Aequus: P4 (610ms)
    );

    _scrollCtrl.addListener(() {
      setState(() {
        _scrollOffset = _scrollCtrl.offset;
      });
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final campaignAsync = ref.watch(campaignByIdProvider(widget.campaignId));

    return Scaffold(
      body: campaignAsync.when(
        data: (campaign) {
          if (campaign == null) {
            return _buildNotFound(theme);
          }
          return _buildContent(context, theme, campaign);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildNotFound(theme),
      ),
      floatingActionButton: campaignAsync.maybeWhen(
        data: (campaign) {
          if (campaign == null || campaign.status != CampaignStatus.active) {
            return null;
          }
          return FloatingActionButton.extended(
            onPressed: () {
              _showContributionSheet(context, theme, campaign);
            },
            icon: const Icon(Icons.favorite),
            label: const Text('Contribute'),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildNotFound(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AequusDesignTokens.spacing.s55,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: AequusDesignTokens.spacing.s21),
          Text(
            'Campaign not found',
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    Campaign campaign,
  ) {
    final imageHeight = 377.0; // Aequus: P5
    final scrollProgress = (_scrollOffset / imageHeight).clamp(0.0, 1.0);

    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        SliverAppBar(
          expandedHeight: imageHeight,
          pinned: true,
          backgroundColor: Color.lerp(
            Colors.transparent,
            theme.colorScheme.surface,
            scrollProgress,
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (campaign.imageUrl != null)
                  Image.network(
                    campaign.imageUrl!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.landscape_outlined,
                      size: AequusDesignTokens.spacing.s55,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.34),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.34),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme, campaign),
                _buildProgressSection(theme, campaign),
                _buildDescription(theme, campaign),
                _buildCreatorSection(theme, campaign),
                _buildLocationSection(theme, campaign),
                SizedBox(height: AequusDesignTokens.spacing.s89),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, Campaign campaign) {
    return Padding(
      padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AequusDesignTokens.spacing.s13,
              vertical: AequusDesignTokens.spacing.s5,
            ),
            decoration: BoxDecoration(
        color: _getCategoryColor(campaign.type)
          .withValues(alpha: 0.13),
              borderRadius: AequusDesignTokens.radii.s8,
            ),
            child: Text(
              campaign.type.name.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getCategoryColor(campaign.type),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: AequusDesignTokens.spacing.s13),
          Text(
            campaign.title,
            style: theme.textTheme.headlineLarge,
          ),
          SizedBox(height: AequusDesignTokens.spacing.s8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              SizedBox(width: AequusDesignTokens.spacing.s5),
              Text(
                '${campaign.location.city}, ${campaign.location.country}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme, Campaign campaign) {
    final fundingGoal = campaign.fundingGoal;
    final percentageFunded = fundingGoal.percentageFunded;
    final supporters = fundingGoal.numberOfContributors;
    final daysRemaining = fundingGoal.daysRemaining;
    final isUrgent = fundingGoal.isUrgent;
    final perCapitaInsights =
        _buildPerCapitaInsights(theme, campaign, fundingGoal);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AequusDesignTokens.spacing.s21,
      ),
      padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AequusDesignTokens.radii.s13,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${fundingGoal.currentAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'raised of \$${fundingGoal.goalAmount.toStringAsFixed(0)} goal',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${percentageFunded.toStringAsFixed(0)}%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'funded',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AequusDesignTokens.spacing.s13),
          ClipRRect(
            borderRadius: AequusDesignTokens.radii.s8,
            child: LinearProgressIndicator(
              value: percentageFunded / 100,
              minHeight: 8,
            ),
          ),
          SizedBox(height: AequusDesignTokens.spacing.s13),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              SizedBox(width: AequusDesignTokens.spacing.s5),
              Text(
                '$supporters supporters',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(width: AequusDesignTokens.spacing.s21),
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              SizedBox(width: AequusDesignTokens.spacing.s5),
              Text(
                '$daysRemaining days left',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUrgent
                      ? theme.colorScheme.error
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          if (perCapitaInsights.isNotEmpty) ...[
            SizedBox(height: AequusDesignTokens.spacing.s13),
            Divider(
              height: AequusDesignTokens.spacing.s13,
              color: theme.colorScheme.outlineVariant,
            ),
            SizedBox(height: AequusDesignTokens.spacing.s13),
            Text(
              'Shared contribution snapshot',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AequusDesignTokens.spacing.s8),
            PerCapitaInsights.compact(
              campaign: campaign,
              fundingGoal: fundingGoal,
              compact: false,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildPerCapitaInsights(
    ThemeData theme,
    Campaign campaign,
    FundingGoal fundingGoal,
  ) {
    if (fundingGoal.remainingAmount <= 0) {
      return [];
    }

    final formatter = NumberFormat.simpleCurrency(
      name: fundingGoal.currency,
      decimalDigits: 2,
    );

    final colorScheme = theme.colorScheme;

    final entries = <_PerCapitaInsight>[
      if (campaign.location.regionPopulation != null)
        _PerCapitaInsight(
          label: campaign.location.region,
          population: campaign.location.regionPopulation!,
          scope: 'region',
        ),
      if (campaign.location.cityPopulation != null)
        _PerCapitaInsight(
          label: campaign.location.city,
          population: campaign.location.cityPopulation!,
          scope: 'community',
        ),
      if (campaign.location.countryPopulation != null)
        _PerCapitaInsight(
          label: campaign.location.country,
          population: campaign.location.countryPopulation!,
          scope: 'nation',
        ),
    ];

    final widgets = <Widget>[];

    for (final entry in entries) {
      final amount = fundingGoal.perCapitaAmount(entry.population);
      if (amount == null || amount < 0.01) {
        continue;
      }

      final formatted = formatter.format(amount);
      final iconColor = _getCategoryColorForScope(colorScheme, entry.scope);

      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: AequusDesignTokens.spacing.s8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.equalizer_rounded,
                size: 18,
                color: iconColor.withValues(alpha: 0.7),
              ),
              SizedBox(width: AequusDesignTokens.spacing.s8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.87),
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: formatted,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                      const TextSpan(text: ' from each '),
                      TextSpan(
                        text: entry.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Color _getCategoryColorForScope(ColorScheme colorScheme, String scope) {
    return switch (scope) {
      'community' => colorScheme.secondary,
      'region' => colorScheme.tertiary,
      _ => colorScheme.primary,
    };
  }

  Widget _buildDescription(ThemeData theme, Campaign campaign) {
    return Padding(
      padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this campaign',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: AequusDesignTokens.spacing.s13),
          Text(
            campaign.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.618, // Aequus: Golden ratio
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorSection(ThemeData theme, Campaign campaign) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AequusDesignTokens.spacing.s21,
      ),
      padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AequusDesignTokens.radii.s13,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AequusDesignTokens.spacing.s34,
      backgroundColor:
        theme.colorScheme.primary.withValues(alpha: 0.13),
            child: Text(
              (campaign.creatorUserId.isNotEmpty
                      ? campaign.creatorUserId[0]
                      : '?')
                  .toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: AequusDesignTokens.spacing.s13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creator ${campaign.creatorUserId}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AequusDesignTokens.spacing.s3),
                Text(
                  'Campaign creator',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.message_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ThemeData theme, Campaign campaign) {
    return Padding(
      padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: AequusDesignTokens.spacing.s13),
          Container(
            height: 233, // Aequus: P3
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AequusDesignTokens.radii.s13,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 55,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: AequusDesignTokens.spacing.s8),
                  Text(
                    '${campaign.location.city}, ${campaign.location.country}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Lat: ${campaign.location.latitude.toStringAsFixed(4)}, '
                    'Lng: ${campaign.location.longitude.toStringAsFixed(4)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(CampaignType type) {
    return switch (type) {
      CampaignType.agriculture => const Color(0xFF4CAF50),
      CampaignType.education => const Color(0xFF2196F3),
      CampaignType.healthcare => const Color(0xFFE91E63),
      CampaignType.infrastructure => const Color(0xFF9C27B0),
      CampaignType.businessStartup => const Color(0xFFFF9800),
      CampaignType.communityProject => const Color(0xFF009688),
      CampaignType.socialInitiative => const Color(0xFF607D8B),
      CampaignType.technology => const Color(0xFF00BCD4),
    };
  }

  void _showContributionSheet(
    BuildContext context,
    ThemeData theme,
    Campaign campaign,
  ) {
    final amountController = TextEditingController();
    final quickAmounts = [5.0, 10.0, 25.0, 50.0, 100.0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AequusDesignTokens.spacing.s21,
          right: AequusDesignTokens.spacing.s21,
          top: AequusDesignTokens.spacing.s21,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contribute to Campaign',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: AequusDesignTokens.spacing.s21),
            Text(
              'Quick amounts',
              style: theme.textTheme.titleSmall,
            ),
            SizedBox(height: AequusDesignTokens.spacing.s13),
            Wrap(
              spacing: AequusDesignTokens.spacing.s8,
              runSpacing: AequusDesignTokens.spacing.s8,
              children: quickAmounts.map((amount) {
                return ActionChip(
                  label: Text('\$${amount.toStringAsFixed(0)}'),
                  onPressed: () {
                    amountController.text = amount.toStringAsFixed(0);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AequusDesignTokens.spacing.s21),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Custom amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: AequusDesignTokens.radii.s13,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AequusDesignTokens.spacing.s21),
            FilledButton(
              onPressed: () {
                // TODO: Process contribution
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Thank you for contributing \$${amountController.text}!',
                    ),
                    duration: AequusDesignTokens.durations.relaxed,
                  ),
                );
              },
              child: const Text('Confirm Contribution'),
            ),
            SizedBox(height: AequusDesignTokens.spacing.s21),
          ],
        ),
      ),
    );
  }
}

class _PerCapitaInsight {
  const _PerCapitaInsight({
    required this.label,
    required this.population,
    required this.scope,
  });

  final String label;
  final int population;
  final String scope;
}
