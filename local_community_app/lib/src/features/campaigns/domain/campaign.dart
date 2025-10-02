import 'package:flutter/foundation.dart';

/// Campaign funding status.
enum CampaignStatus {
  draft,
  active,
  funded,
  completed,
  cancelled,
}

/// Campaign type/category.
enum CampaignType {
  businessStartup,
  communityProject,
  socialInitiative,
  infrastructure,
  education,
  healthcare,
  agriculture,
  technology,
}

/// Location data for campaigns with population demographics.
@immutable
class CampaignLocation {
  const CampaignLocation({
    required this.city,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.cityPopulation,
    this.regionPopulation,
    this.countryPopulation,
  });

  final String city;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  
  /// Population of the city/municipality
  final int? cityPopulation;
  
  /// Population of the region/province/state
  final int? regionPopulation;
  
  /// Population of the country
  final int? countryPopulation;

  String get displayName => '$city, $region';
}

/// Funding goal and progress.
@immutable
class FundingGoal {
  const FundingGoal({
    required this.goalAmount,
    required this.currentAmount,
    required this.currency,
    required this.numberOfContributors,
    required this.targetEndDate,
  });

  final double goalAmount;
  final double currentAmount;
  final String currency;
  final int numberOfContributors;
  final DateTime targetEndDate;

  double get percentageFunded => (currentAmount / goalAmount) * 100;
  double get remainingAmount => (goalAmount - currentAmount).clamp(0, goalAmount);
  bool get isFullyFunded => percentageFunded >= 100;
  
  int get daysRemaining {
    final now = DateTime.now();
    return targetEndDate.difference(now).inDays;
  }
  
  bool get isUrgent => daysRemaining <= 7 && !isFullyFunded;
  
  /// Calculate per-capita contribution needed from a population
  double? perCapitaAmount(int? population) {
    if (population == null || population <= 0) return null;
    return remainingAmount / population;
  }
}

/// Campaign domain model.
@immutable
class Campaign {
  const Campaign({
    required this.id,
    required this.creatorUserId,
    required this.title,
    required this.tagline,
    required this.description,
    required this.type,
    required this.location,
    required this.fundingGoal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.videoUrl,
  });

  final String id;
  final String creatorUserId;
  final String title;
  final String tagline;
  final String description;
  final CampaignType type;
  final CampaignLocation location;
  final FundingGoal fundingGoal;
  final CampaignStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String? videoUrl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Campaign && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
