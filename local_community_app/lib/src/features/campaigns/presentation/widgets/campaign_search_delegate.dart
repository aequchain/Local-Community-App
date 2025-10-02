import 'package:flutter/material.dart';

import '../../domain/campaign.dart';

class CampaignSearchDelegate extends SearchDelegate<Campaign?> {
  CampaignSearchDelegate(this.campaigns);

  final List<Campaign> campaigns;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = _filterCampaigns();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 55,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 21),
            Text(
              'No campaigns found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(13),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final campaign = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: InkWell(
            onTap: () {
              close(context, campaign);
            },
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  child: Icon(
                    Icons.campaign_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  campaign.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  campaign.location.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${campaign.fundingGoal.percentageFunded.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Campaign> _filterCampaigns() {
    if (query.isEmpty) {
      return campaigns;
    }

    final lowerQuery = query.toLowerCase();
    return campaigns.where((campaign) {
      return campaign.title.toLowerCase().contains(lowerQuery) ||
          campaign.description.toLowerCase().contains(lowerQuery) ||
          campaign.location.city.toLowerCase().contains(lowerQuery) ||
          campaign.location.region.toLowerCase().contains(lowerQuery) ||
          campaign.location.country.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
