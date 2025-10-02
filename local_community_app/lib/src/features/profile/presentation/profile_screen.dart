import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/design_tokens.dart';
import '../../auth/application/auth_service.dart';
import '../../campaigns/presentation/campaign_feed_screen.dart';
import '../../landing/presentation/landing_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routeName = 'profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 89,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: AequusDesignTokens.spacing.s21),
                  Text(
                    'Not signed in',
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: AequusDesignTokens.spacing.s13),
                  FilledButton(
                    onPressed: () => context.goNamed('sign-in'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: theme.colorScheme.primary
                            .withValues(alpha: 0.13),
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.displayName?[0].toUpperCase() ??
                                    user.email[0].toUpperCase(),
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s13),
                      Text(
                        user.displayName ?? 'Anonymous',
                        style: theme.textTheme.headlineMedium,
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s5),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AequusDesignTokens.spacing.s34),

                // Stats cards
                _buildStatsSection(theme),
                SizedBox(height: AequusDesignTokens.spacing.s34),

                // Account settings
                Text(
                  'Account',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: AequusDesignTokens.spacing.s13),
                _buildSettingCard(
                  theme,
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your profile information',
                  onTap: () {},
                ),
                SizedBox(height: AequusDesignTokens.spacing.s8),
                _buildSettingCard(
                  theme,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {},
                ),
                SizedBox(height: AequusDesignTokens.spacing.s8),
                _buildSettingCard(
                  theme,
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Control your privacy settings',
                  onTap: () {},
                ),
                SizedBox(height: AequusDesignTokens.spacing.s34),

                // Danger zone
                OutlinedButton.icon(
                  onPressed: () async {
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign out'),
                        content: const Text(
                          'Are you sure you want to sign out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sign out'),
                          ),
                        ],
                      ),
                    );

                    if (shouldSignOut == true && context.mounted) {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) {
                        context.goNamed(LandingScreen.routeName);
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.goNamed(CampaignFeedScreen.routeName);
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

  Widget _buildStatsSection(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            label: 'Campaigns',
            value: '5',
            icon: Icons.campaign_outlined,
          ),
        ),
        SizedBox(width: AequusDesignTokens.spacing.s13),
        Expanded(
          child: _buildStatCard(
            theme,
            label: 'Contributed',
            value: '\$250',
            icon: Icons.favorite_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(AequusDesignTokens.spacing.s21),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AequusDesignTokens.radii.s13,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: AequusDesignTokens.spacing.s8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
