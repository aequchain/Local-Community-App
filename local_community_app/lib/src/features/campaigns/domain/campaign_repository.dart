import '../domain/campaign.dart';

/// Repository interface for campaign operations.
abstract class CampaignRepository {
  /// Fetch campaigns (with optional filters).
  Future<List<Campaign>> fetchCampaigns({
    CampaignStatus? status,
    CampaignType? type,
    String? locationCity,
    int limit = 20,
  });

  /// Fetch single campaign by ID.
  Future<Campaign?> getCampaignById(String id);

  /// Stream of campaign updates.
  Stream<List<Campaign>> watchCampaigns({
    CampaignStatus? status,
    int limit = 20,
  });

  /// Create new campaign.
  Future<Campaign> createCampaign(Campaign campaign);

  /// Update existing campaign.
  Future<void> updateCampaign(Campaign campaign);
}
