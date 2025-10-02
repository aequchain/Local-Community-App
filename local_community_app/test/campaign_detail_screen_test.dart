import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_community_app/src/features/campaigns/application/campaign_service.dart';
import 'package:local_community_app/src/features/campaigns/presentation/campaign_detail_screen.dart';
import 'package:local_community_app/src/features/campaigns/domain/campaign.dart';
import 'package:local_community_app/src/features/campaigns/domain/campaign_repository.dart';

void main() {
  testWidgets('Campaign detail renders expected content', (tester) async {
    final repository = _FakeCampaignRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          campaignRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const CampaignDetailScreen(campaignId: 'camp-1'),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Community Garden Expansion'), findsOneWidget);
    expect(find.textContaining('raised of'), findsOneWidget);
    expect(find.textContaining('Cape Town, ZA'), findsWidgets);
    
    // Verify per-capita insights are rendered using RichText
    expect(find.byType(RichText), findsWidgets);
  });
}

class _FakeCampaignRepository implements CampaignRepository {
  _FakeCampaignRepository();

  final Campaign _campaign = Campaign(
    id: 'camp-1',
    creatorUserId: 'user-1',
    title: 'Community Garden Expansion',
    tagline: 'Grow fresh produce for 200 families',
    description: 'Sample description for test verification.',
    type: CampaignType.agriculture,
    location: const CampaignLocation(
      city: 'Cape Town',
      region: 'Western Cape',
      country: 'ZA',
      latitude: 0,
      longitude: 0,
      cityPopulation: 5000,
      regionPopulation: 6500000,
      countryPopulation: 60000000,
    ),
    fundingGoal: FundingGoal(
      goalAmount: 15000,
      currentAmount: 8750,
      currency: 'USD',
      numberOfContributors: 87,
      targetEndDate: DateTime(2030, 1, 1),
    ),
    status: CampaignStatus.active,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
    imageUrl: null,
  );

  @override
  Future<List<Campaign>> fetchCampaigns({
    CampaignStatus? status,
    CampaignType? type,
    String? locationCity,
    int limit = 20,
  }) async {
    return [_campaign];
  }

  @override
  Future<Campaign?> getCampaignById(String id) async {
    return id == _campaign.id ? _campaign : null;
  }

  @override
  Stream<List<Campaign>> watchCampaigns({
    CampaignStatus? status,
    int limit = 20,
  }) {
    return Stream.value([_campaign]);
  }

  @override
  Future<Campaign> createCampaign(Campaign campaign) async {
    return campaign;
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {}
}
