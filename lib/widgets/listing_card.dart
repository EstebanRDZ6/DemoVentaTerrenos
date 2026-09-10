import 'package:flutter/material.dart';

import '../models/property_listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    required this.listing,
    required this.onViewDetail,
    super.key,
  });

  final PropertyListing listing;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Image.network(
              listing.images.first,
              width: double.infinity,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
                if (progress == null) {
                  return child;
                }
                return Container(
                  color: const Color(0xFFF2F2F2),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFEDEDED),
                alignment: Alignment.center,
                child: const Icon(Icons.landscape_outlined, size: 36),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(listing.location),
                const SizedBox(height: 4),
                Chip(label: Text(listing.kind.label)),
                const SizedBox(height: 8),
                Text(
                  'USD ${listing.priceUsd.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewDetail,
                    child: const Text('Ver detalle'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
