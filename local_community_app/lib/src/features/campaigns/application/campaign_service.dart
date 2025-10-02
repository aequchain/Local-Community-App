import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_campaign_repository.dart';
import '../domain/campaign.dart';
import '../domain/campaign_repository.dart';

/// Provider for campaign repository.
final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return MockCampaignRepository();
});

/// Provider for active campaigns stream.
final activeCampaignsProvider = StreamProvider<List<Campaign>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.watchCampaigns(status: CampaignStatus.active);
});

/// Provider for fetching campaigns (for manual refresh).
final fetchCampaignsProvider = FutureProvider.autoDispose
    .family<List<Campaign>, CampaignStatus?>((ref, status) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.fetchCampaigns(status: status);
});

/// Provider for single campaign.
final campaignByIdProvider =
    FutureProvider.autoDispose.family<Campaign?, String>((ref, id) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getCampaignById(id);
});
