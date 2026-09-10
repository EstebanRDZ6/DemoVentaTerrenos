import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/property_listing.dart';
import '../services/auth_service.dart';
import '../services/property_image_catalog.dart';
import '../services/rating_service.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({required this.listing, required this.onViewDetail, super.key});
  final PropertyListing listing;

  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Map<String, List<int>>>(valueListenable: RatingService.instance.ratings, builder: (context, _, __) {
    final rating = RatingService.instance.average(listing.id);
    final count = RatingService.instance.count(listing.id);
    final image = PropertyImageCatalog.forListing(listing.id, listing.images).first;
    return Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: onViewDetail, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stack(fit: StackFit.expand, children: [Image.network(image, fit: BoxFit.cover, filterQuality: FilterQuality.low, cacheWidth: 900, cacheHeight: 600, gaplessPlayback: true, errorBuilder: (_, _, _) => ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Center(child: Icon(Icons.home_work_outlined, size: 42)))), Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: .94), borderRadius: BorderRadius.circular(20)), child: Text(listing.type == ListingType.sale ? 'VENTA' : 'ALQUILER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)))), Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .55), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 16), const SizedBox(width: 3), Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))])))])),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(listing.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5), Row(children: [Icon(Icons.location_on_outlined, size: 17, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 4), Expanded(child: Text(listing.location, maxLines: 1, overflow: TextOverflow.ellipsis))]), const SizedBox(height: 10), Wrap(spacing: 6, runSpacing: 6, children: [Chip(label: Text(listing.kind.label)), _serviceChip(context, Icons.water_drop_outlined, listing.hasWater, 'Agua'), _serviceChip(context, Icons.bolt_outlined, listing.hasElectricity, 'Luz')]), const SizedBox(height: 10), Row(children: [Expanded(child: Text('USD ${listing.priceUsd.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary))), Text('$count reseñas', style: Theme.of(context).textTheme.bodyMedium)]), const SizedBox(height: 12), Row(children: [Expanded(child: FilledButton.icon(onPressed: onViewDetail, icon: const Icon(Icons.arrow_forward_rounded, size: 18), label: const Text('Ver propiedad'))), const SizedBox(width: 8), IconButton(tooltip: 'Calificar', onPressed: () => _rate(context), icon: const Icon(Icons.star_border_rounded))])]))
    ])));
  });

  Future<void> _rate(BuildContext context) async {
    final user = AuthService.instance.currentUser.value;
    if (user?.role != UserRole.common) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Iniciá sesión como cliente para calificar esta propiedad.')));
      return;
    }
    int selected = 0;
    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setState) => AlertDialog(title: const Text('Calificar propiedad'), content: Column(mainAxisSize: MainAxisSize.min, children: [Text(listing.title, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 14), Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (index) => IconButton(onPressed: () => setState(() => selected = index + 1), icon: Icon(index < selected ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 34))))]), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')), FilledButton(onPressed: selected == 0 ? null : () { RatingService.instance.rate(listing.id, selected); Navigator.pop(dialogContext); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Gracias por tu calificación!'))); }, child: const Text('Enviar'))])));
  }

  Widget _serviceChip(BuildContext context, IconData icon, bool enabled, String label) => Chip(avatar: Icon(icon, size: 16, color: enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor), label: Text(label), backgroundColor: enabled ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .55) : Theme.of(context).disabledColor.withValues(alpha: .08));
}
