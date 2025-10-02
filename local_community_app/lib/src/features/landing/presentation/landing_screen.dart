import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routing/app_router.dart';
import '../../../theme/design_tokens.dart';
import 'widgets/hero_header.dart';
import 'widgets/impact_stat_card.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  static const routeName = 'landing';

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AequusDesignTokens.durations.standard,
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.89, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        final padding = EdgeInsets.symmetric(
          horizontal: isPortrait
              ? AequusDesignTokens.spacing.s21
              : AequusDesignTokens.spacing.s55,
          vertical: isPortrait
              ? AequusDesignTokens.spacing.s34
              : AequusDesignTokens.spacing.s21,
        );

        return Scaffold(
          body: AnimatedBuilder(
            animation: _fadeIn,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeIn.value,
                child: Transform.translate(
                  offset: Offset(0, (1 - _fadeIn.value) * 34),
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.21),
                    theme.colorScheme.secondary.withValues(alpha: 0.34),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: padding,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: AequusDesignTokens.spacing.s21,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 987),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 610;

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 55,
                                  child: HeroHeader(
                                    isWide: true,
                                    onViewRoadmap: _handleRoadmapTap,
                                  ),
                                ),
                                SizedBox(width: AequusDesignTokens.spacing.s34),
                                Expanded(
                                  flex: 34,
                                  child: ImpactStatCard(
                                    onStudyArchitecture:
                                        _handleArchitectureTap,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              HeroHeader(
                                isWide: false,
                                onViewRoadmap: _handleRoadmapTap,
                              ),
                              SizedBox(
                                height: AequusDesignTokens.spacing.s55,
                              ),
                              ImpactStatCard(
                                onStudyArchitecture: _handleArchitectureTap,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRoadmapTap() async {
    final theme = Theme.of(context);
    final emphasis = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    final shouldNavigate = await _showInfoSheet(
      title: 'Build roadmap snapshot',
      showGetStartedButton: true,
      content: [
        Text(
          'What we are sequencing next to reach a community-ready MVP.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: AequusDesignTokens.spacing.s21),
        Text('Foundation phase', style: emphasis),
        SizedBox(height: AequusDesignTokens.spacing.s13),
        _buildBullet(
          'Instrument Firebase Auth and seed a sample cohort for onboarding.',
        ),
        _buildBullet(
          'Wire the landing analytics widgets to real wallet telemetry.',
        ),
        _buildBullet(
          'Publish contributor onboarding guides and translation notes.',
        ),
        SizedBox(height: AequusDesignTokens.spacing.s21),
        Text('Momentum phase', style: emphasis),
        SizedBox(height: AequusDesignTokens.spacing.s13),
        _buildBullet(
          'Launch milestone-based funding flows with moderation hooks.',
        ),
        _buildBullet(
          'Expose job-matching beta to the first city partner.',
        ),
        _buildBullet(
          'Activate push notifications for community impact updates.',
        ),
        SizedBox(height: AequusDesignTokens.spacing.s21),
        Text('Scale phase', style: emphasis),
        SizedBox(height: AequusDesignTokens.spacing.s13),
        _buildBullet(
          'Expand multilingual support and add per-region campaign feeds.',
        ),
        _buildBullet(
          'Transition infrastructure from free tier once sustainability hits.',
        ),
      ],
    );

    if (shouldNavigate == true && mounted) {
      ref.read(goRouterProvider).pushNamed('sign-in');
    }
  }

  Future<void> _handleArchitectureTap() async {
    final theme = Theme.of(context);
    final emphasis = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    await _showInfoSheet(
      title: 'Technical architecture preview',
      content: [
        Text(
          'Key building blocks that power the Local Community App.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: AequusDesignTokens.spacing.s21),
        Text('Core services', style: emphasis),
        SizedBox(height: AequusDesignTokens.spacing.s13),
        _buildBullet(
          'Flutter multi-platform client (web, desktop, mobile).',
        ),
        _buildBullet(
          'Firebase Auth + Firestore for real-time collaboration.',
        ),
        _buildBullet(
          'Cloud Functions orchestrating payments and fraud checks.',
        ),
        SizedBox(height: AequusDesignTokens.spacing.s21),
        Text('Data & insight layer', style: emphasis),
        SizedBox(height: AequusDesignTokens.spacing.s13),
        _buildBullet(
          'Supabase/PostgreSQL warehouses financial events safely.',
        ),
        _buildBullet(
          'Algolia search unlocks geospatial campaign discovery.',
        ),
        _buildBullet(
          'Analytics pipeline funnels anonymized telemetry into impact dashboards.',
        ),
        SizedBox(height: AequusDesignTokens.spacing.s21),
        Text('Safety & compliance', style: emphasis),
        SizedBox(height: AequusDesignTokens.spacing.s13),
        _buildBullet(
          'Multi-factor verification for large disbursements.',
        ),
        _buildBullet(
          'Audit trails, AML checks, and localized policy bundles.',
        ),
        _buildBullet(
          'Community reporting channels with human-in-the-loop review.',
        ),
      ],
    );
  }

  Future<bool?> _showInfoSheet({
    required String title,
    required List<Widget> content,
    bool showGetStartedButton = false,
  }) {
    final theme = Theme.of(context);
    final spacing = AequusDesignTokens.spacing.s21;
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: AequusDesignTokens.radii.s21.topLeft,
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: spacing,
              right: spacing,
              top: spacing,
              bottom: spacing +
                  MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: theme.textTheme.headlineSmall),
                  SizedBox(height: spacing),
                  ...content,
                  SizedBox(height: spacing),
                  Row(
                    mainAxisAlignment: showGetStartedButton
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                    children: [
                      if (showGetStartedButton)
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(true),
                          icon: const Icon(Icons.rocket_launch_rounded),
                          label: const Text('Get started'),
                        ),
                      FilledButton.tonal(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBullet(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AequusDesignTokens.spacing.s13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•'),
          SizedBox(width: AequusDesignTokens.spacing.s8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
