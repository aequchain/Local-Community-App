import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/design_tokens.dart';
import '../../profile/presentation/profile_screen.dart';
import '../application/campaign_service.dart';
import '../domain/campaign.dart';
import 'widgets/campaign_card.dart';
import 'widgets/campaign_filter_sheet.dart';
import 'widgets/campaign_search_delegate.dart';

class CampaignFeedScreen extends ConsumerStatefulWidget {
  const CampaignFeedScreen({super.key});

  static const routeName = 'campaign-feed';

  @override
  ConsumerState<CampaignFeedScreen> createState() =>
      _CampaignFeedScreenState();
}

class _CampaignFeedScreenState extends ConsumerState<CampaignFeedScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  
  CampaignType? _filterType;
  String? _filterLocation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AequusDesignTokens.durations.relaxed,
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CampaignFilterSheet(
        initialType: _filterType,
        initialLocation: _filterLocation,
        onApply: ({type, location}) {
          setState(() {
            _filterType = type;
            _filterLocation = location;
          });
        },
      ),
    );
  }

  void _openSearch(List<Campaign> campaigns) async {
    final selectedCampaign = await showSearch(
      context: context,
      delegate: CampaignSearchDelegate(campaigns),
    );

    if (selectedCampaign != null && mounted) {
      context.goNamed(
        'campaign-detail',
        pathParameters: {'id': selectedCampaign.id},
      );
    }
  }

  List<Campaign> _applyFilters(List<Campaign> campaigns) {
    var filtered = campaigns;

    if (_filterType != null) {
      filtered = filtered.where((c) => c.type == _filterType).toList();
    }

    if (_filterLocation != null && _filterLocation!.isNotEmpty) {
      final lowerLocation = _filterLocation!.toLowerCase();
      filtered = filtered.where((c) {
        return c.location.city.toLowerCase().contains(lowerLocation) ||
            c.location.region.toLowerCase().contains(lowerLocation) ||
            c.location.country.toLowerCase().contains(lowerLocation);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final campaignsAsync = ref.watch(activeCampaignsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover campaigns'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _filterType != null || _filterLocation != null
                  ? theme.colorScheme.primary
                  : null,
            ),
            onPressed: () {
              campaignsAsync.whenData((campaigns) => _openFilterSheet());
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              campaignsAsync.whenData((campaigns) => _openSearch(campaigns));
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeIn,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeIn.value,
            child: child,
          );
        },
        child: campaignsAsync.when(
          data: (allCampaigns) {
            final campaigns = _applyFilters(allCampaigns);
            
            if (campaigns.isEmpty) {
              final hasFilters = _filterType != null || _filterLocation != null;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasFilters ? Icons.filter_list_off_rounded : Icons.campaign_outlined,
                      size: 89,
                      color: theme.colorScheme.outline,
                    ),
                    SizedBox(height: AequusDesignTokens.spacing.s21),
                    Text(
                      hasFilters ? 'No matching campaigns' : 'No campaigns yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    SizedBox(height: AequusDesignTokens.spacing.s13),
                    Text(
                      hasFilters 
                          ? 'Try adjusting your filters'
                          : 'Check back soon for new opportunities',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (hasFilters) ...[
                      SizedBox(height: AequusDesignTokens.spacing.s21),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _filterType = null;
                            _filterLocation = null;
                          });
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear filters'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(activeCampaignsProvider);
                await Future.delayed(
                  const Duration(milliseconds: 377),
                ); // F14
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid: 1 column mobile, 2 tablet, 3 desktop
                  final crossAxisCount = constraints.maxWidth < 610
                      ? 1
                      : constraints.maxWidth < 987
                          ? 2
                          : 3;

                  return GridView.builder(
                    padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: AequusDesignTokens.spacing.s21,
                      mainAxisSpacing: AequusDesignTokens.spacing.s21,
                    ),
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(
                          milliseconds:
                              233 + (index * 34), // Stagger animation
                        ),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, (1 - value) * 34),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: CampaignCard(campaign: campaign),
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: AequusDesignTokens.spacing.s21),
                Text(
                  'Loading campaigns...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 89,
                  color: theme.colorScheme.error,
                ),
                SizedBox(height: AequusDesignTokens.spacing.s21),
                Text(
                  'Something went wrong',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: AequusDesignTokens.spacing.s13),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AequusDesignTokens.spacing.s21),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(activeCampaignsProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.goNamed(ProfileScreen.routeName);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
