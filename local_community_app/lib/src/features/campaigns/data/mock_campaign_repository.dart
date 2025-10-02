import 'dart:async';

import '../domain/campaign.dart';
import '../domain/campaign_repository.dart';

/// Mock campaign repository with sample data.
class MockCampaignRepository implements CampaignRepository {
  MockCampaignRepository() {
    _campaigns = _generateMockCampaigns();
    _campaignsController = StreamController<List<Campaign>>.broadcast(
      onListen: () => _campaignsController.add(_campaigns),
    );
  }

  late final List<Campaign> _campaigns;
  late final StreamController<List<Campaign>> _campaignsController;

  @override
  Future<List<Campaign>> fetchCampaigns({
    CampaignStatus? status,
    CampaignType? type,
    String? locationCity,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 377)); // F14 delay

    var filtered = _campaigns;

    if (status != null) {
      filtered = filtered.where((c) => c.status == status).toList();
    }
    if (type != null) {
      filtered = filtered.where((c) => c.type == type).toList();
    }
    if (locationCity != null) {
      filtered = filtered
          .where((c) =>
              c.location.city.toLowerCase().contains(locationCity.toLowerCase()))
          .toList();
    }

    return filtered.take(limit).toList();
  }

  @override
  Future<Campaign?> getCampaignById(String id) async {
    await Future.delayed(const Duration(milliseconds: 233)); // F13 delay
    try {
      return _campaigns.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<Campaign>> watchCampaigns({
    CampaignStatus? status,
    int limit = 20,
  }) {
    return _campaignsController.stream.map((campaigns) {
      var filtered = campaigns;
      if (status != null) {
        filtered = filtered.where((c) => c.status == status).toList();
      }
      return filtered.take(limit).toList();
    });
  }

  @override
  Future<Campaign> createCampaign(Campaign campaign) async {
    await Future.delayed(const Duration(milliseconds: 610)); // F15 delay
    _campaigns.add(campaign);
    _campaignsController.add(_campaigns);
    return campaign;
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    await Future.delayed(const Duration(milliseconds: 377));
    final index = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (index != -1) {
      _campaigns[index] = campaign;
      _campaignsController.add(_campaigns);
    }
  }

  void dispose() {
    _campaignsController.close();
  }

  List<Campaign> _generateMockCampaigns() {
    final now = DateTime.now();
    return [
      Campaign(
        id: 'camp-1',
        creatorUserId: 'user-1',
        title: 'Community Garden Expansion',
        tagline: 'Grow fresh produce for 200 families',
        description:
            'We are expanding our urban garden to provide fresh, organic vegetables to local families. The funds will purchase equipment, seeds, and irrigation systems.',
        type: CampaignType.agriculture,
        location: const CampaignLocation(
          city: 'Cape Town',
          region: 'Western Cape',
          country: 'ZA',
          latitude: -33.9249,
          longitude: 18.4241,
          cityPopulation: 4720000,
          regionPopulation: 7200000,
          countryPopulation: 60410000,
        ),
        fundingGoal: FundingGoal(
          goalAmount: 15000,
          currentAmount: 8750,
          currency: 'USD',
          numberOfContributors: 87,
          targetEndDate: now.add(const Duration(days: 21)),
        ),
        status: CampaignStatus.active,
        createdAt: now.subtract(const Duration(days: 13)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
      ),
      Campaign(
        id: 'camp-2',
        creatorUserId: 'user-2',
        title: 'Tech Training Hub',
        tagline: 'Teach coding to 100 youth per year',
        description:
            'A community tech center offering free coding bootcamps for underserved youth. Funds will cover instructor salaries, equipment, and scholarships.',
        type: CampaignType.education,
        location: const CampaignLocation(
          city: 'Nairobi',
          region: 'Nairobi County',
          country: 'KE',
          latitude: -1.2864,
          longitude: 36.8172,
          cityPopulation: 4548000,
          regionPopulation: 5450000,
          countryPopulation: 53770000,
        ),
        fundingGoal: FundingGoal(
          goalAmount: 32000,
          currentAmount: 19500,
          currency: 'USD',
          numberOfContributors: 143,
          targetEndDate: now.add(const Duration(days: 34)),
        ),
        status: CampaignStatus.active,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
      ),
      Campaign(
        id: 'camp-3',
        creatorUserId: 'user-3',
        title: 'Mobile Health Clinic',
        tagline: 'Serve 500 rural patients monthly',
        description:
            'Retrofitting a van into a mobile clinic to deliver primary healthcare to remote villages. Includes medical supplies and staffing for the first year.',
        type: CampaignType.healthcare,
        location: const CampaignLocation(
          city: 'Accra',
          region: 'Greater Accra',
          country: 'GH',
          latitude: 5.6037,
          longitude: -0.1870,
          cityPopulation: 2346000,
          regionPopulation: 5380000,
          countryPopulation: 33330000,
        ),
        fundingGoal: FundingGoal(
          goalAmount: 48000,
          currentAmount: 12300,
          currency: 'USD',
          numberOfContributors: 92,
          targetEndDate: now.add(const Duration(days: 55)),
        ),
        status: CampaignStatus.active,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 8)),
        imageUrl: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=800',
      ),
      Campaign(
        id: 'camp-4',
        creatorUserId: 'user-4',
        title: 'Solar-Powered Workshop',
        tagline: 'Off-grid manufacturing for local artisans',
        description:
            'Building a shared workshop powered by solar panels for local craftspeople and small manufacturers. Provides tools, training, and energy independence.',
        type: CampaignType.infrastructure,
        location: const CampaignLocation(
          city: 'Lagos',
          region: 'Lagos State',
          country: 'NG',
          latitude: 6.5244,
          longitude: 3.3792,
          cityPopulation: 15400000,
          regionPopulation: 22600000,
          countryPopulation: 223800000,
        ),
        fundingGoal: FundingGoal(
          goalAmount: 27500,
          currentAmount: 22100,
          currency: 'USD',
          numberOfContributors: 178,
          targetEndDate: now.add(const Duration(days: 13)),
        ),
        status: CampaignStatus.active,
        createdAt: now.subtract(const Duration(days: 21)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        imageUrl: 'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800',
      ),
      Campaign(
        id: 'camp-5',
        creatorUserId: 'user-5',
        title: 'Women-Led Food Cooperative',
        tagline: 'Economic empowerment for 50 women farmers',
        description:
            'Establishing a cooperative to help women farmers collectively market their produce, access training, and negotiate better prices. Includes equipment and micro-loans.',
        type: CampaignType.businessStartup,
        location: const CampaignLocation(
          city: 'Kampala',
          region: 'Central Region',
          country: 'UG',
          latitude: 0.3476,
          longitude: 32.5825,
          cityPopulation: 1680000,
          regionPopulation: 10100000,
          countryPopulation: 48590000,
        ),
        fundingGoal: FundingGoal(
          goalAmount: 18000,
          currentAmount: 4200,
          currency: 'USD',
          numberOfContributors: 38,
          targetEndDate: now.add(const Duration(days: 42)),
        ),
        status: CampaignStatus.active,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
      ),
    ];
  }
}
