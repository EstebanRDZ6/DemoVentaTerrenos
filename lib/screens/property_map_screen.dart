import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../models/property_listing.dart';
import '../services/mock_property_service.dart';
import '../services/rating_service.dart';
import '../widgets/site_header.dart';

class PropertyMapScreen extends StatefulWidget {
  const PropertyMapScreen({super.key});

  @override
  State<PropertyMapScreen> createState() => _PropertyMapScreenState();
}

class _PropertyMapScreenState extends State<PropertyMapScreen> {
  final TextEditingController _search = TextEditingController();
  ListingType _type = ListingType.sale;
  String? _selectedId;

  List<PropertyListing> get _listings {
    final q = _search.text.trim().toLowerCase();
    return MockPropertyService.instance.fetchByType(_type).where((p) => q.isEmpty || p.title.toLowerCase().contains(q) || p.location.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openMaps(PropertyListing property) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${property.title}, ${property.location}, Misiones, Argentina')}');
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final listings = _listings;
    final selected = listings.where((p) => p.id == _selectedId).firstOrNull ?? (listings.isEmpty ? null : listings.first);
    return Scaffold(
      body: Column(children: [
        SiteHeader(currentRoute: AppRoutes.map, onGoHome: () => Navigator.pushNamed(context, AppRoutes.home), onGoSales: () => Navigator.pushNamed(context, AppRoutes.sales), onGoRentals: () => Navigator.pushNamed(context, AppRoutes.rentals), onGoContact: () => Navigator.pushNamed(context, AppRoutes.contact), onGoLogin: () => Navigator.pushNamed(context, AppRoutes.login), onGoProfile: () => Navigator.pushNamed(context, AppRoutes.profile), onGoCrm: () => Navigator.pushNamed(context, AppRoutes.crm)),
        Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 12), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Row(children: [Expanded(child: Text('Explorá propiedades en el mapa', style: Theme.of(context).textTheme.headlineMedium)), SegmentedButton<ListingType>(segments: const [ButtonSegment(value: ListingType.sale, label: Text('Venta')), ButtonSegment(value: ListingType.rent, label: Text('Alquiler'))], selected: {_type}, onSelectionChanged: (v) => setState(() { _type = v.first; _selectedId = null; }))]))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), labelText: 'Buscar por zona o propiedad', suffixIcon: Icon(Icons.map_outlined))))),
        const SizedBox(height: 12),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final map = _MapCanvas(listings: listings, selectedId: selected?.id, onSelect: (id) => setState(() => _selectedId = id));
          final list = _PropertyMapList(listings: listings, selectedId: selected?.id, onSelect: (p) => setState(() => _selectedId = p.id), onOpenMaps: _openMaps);
          return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: compact ? Column(children: [Expanded(child: map), const SizedBox(height: 12), SizedBox(height: 245, child: list)]) : Row(children: [Expanded(flex: 6, child: map), const SizedBox(width: 14), Expanded(flex: 4, child: list)]));
        })),
      ]),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({required this.listings, required this.selectedId, required this.onSelect});
  final List<PropertyListing> listings;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _MapPainter())),
        Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(blurRadius: 14, color: Colors.black12)]), child: const Row(children: [Icon(Icons.layers_outlined, size: 18), SizedBox(width: 7), Text('Vista mapa · Misiones')]))),
        ...List.generate(listings.length, (index) {
          final p = listings[index];
          final positions = const [Offset(.25, .38), Offset(.53, .27), Offset(.69, .50), Offset(.42, .65), Offset(.78, .72), Offset(.20, .72)];
          final pos = positions[index % positions.length];
          final selected = p.id == selectedId;
          return Positioned(left: MediaQuery.sizeOf(context).width * pos.dx, top: 170 * pos.dy + 55, child: InkWell(onTap: () => onSelect(p.id), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: EdgeInsets.all(selected ? 9 : 7), decoration: BoxDecoration(color: selected ? Theme.of(context).colorScheme.primary : Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)]), child: Icon(Icons.location_on, color: selected ? Colors.white : Theme.of(context).colorScheme.primary, size: selected ? 24 : 20))));
        }),
        if (listings.isEmpty) const Center(child: Text('No hay propiedades para mostrar.')),
      ]));
}

class _PropertyMapList extends StatelessWidget {
  const _PropertyMapList({required this.listings, required this.selectedId, required this.onSelect, required this.onOpenMaps});
  final List<PropertyListing> listings;
  final String? selectedId;
  final ValueChanged<PropertyListing> onSelect;
  final ValueChanged<PropertyListing> onOpenMaps;

  @override
  Widget build(BuildContext context) => Card(child: Column(children: [Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.list_alt_rounded), const SizedBox(width: 8), Text('${listings.length} propiedades', style: Theme.of(context).textTheme.titleMedium)])), const Divider(height: 1), Expanded(child: ListView.separated(itemCount: listings.length, separatorBuilder: (_, _) => const Divider(height: 1), itemBuilder: (context, index) { final p = listings[index]; final selected = p.id == selectedId; final rating = RatingService.instance.average(p.id); return ListTile(selected: selected, onTap: () => onSelect(p), leading: CircleAvatar(backgroundImage: NetworkImage(p.images.first), radius: 23), title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('${p.location} · USD ${p.priceUsd.toStringAsFixed(0)} · ★ ${rating.toStringAsFixed(1)}'), trailing: IconButton(tooltip: 'Abrir en Google Maps', onPressed: () => onOpenMaps(p), icon: const Icon(Icons.open_in_new_rounded))); }))]));
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFE9F1EA);
    canvas.drawRect(Offset.zero & size, background);
    final road = Paint()..color = Colors.white..strokeWidth = 26..style = PaintingStyle.stroke;
    final thinRoad = Paint()..color = const Color(0xFFD8E1DA)..strokeWidth = 2..style = PaintingStyle.stroke;
    for (var i = 1; i < 7; i++) canvas.drawLine(Offset(0, size.height * i / 7), Offset(size.width, size.height * (i + 1) / 8), road);
    for (var i = 1; i < 8; i++) canvas.drawLine(Offset(size.width * i / 8, 0), Offset(size.width * (i + 1) / 9, size.height), road);
    for (var i = 1; i < 10; i++) canvas.drawLine(Offset(0, size.height * i / 10), Offset(size.width, size.height * i / 10), thinRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
