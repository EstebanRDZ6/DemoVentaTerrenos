import 'package:flutter/material.dart';

import '../app.dart';
import '../models/property_listing.dart';
import '../services/demo_listing_store.dart';
import '../services/mock_property_service.dart';
import '../services/rating_service.dart';
import '../widgets/listing_card.dart';
import '../widgets/location_filter_chips.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({required this.type, super.key});
  final ListingType type;
  @override State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final MockPropertyService _service = MockPropertyService.instance;
  final Set<String> _selectedLocations = <String>{};
  final Set<PropertyKind> _selectedKinds = <PropertyKind>{};
  final TextEditingController _search = TextEditingController();
  SortOption _sortOption = SortOption.lowestPrice;
  bool _currencyUsd = true;
  double _maxPrice = 8000;
  double _draftMaxPrice = 8000;
  static const double _arsPerUsd = 1400;

  @override void initState() { super.initState(); _resetPriceRange(); }
  @override void dispose() { _search.dispose(); super.dispose(); }
  void _resetPriceRange() { final sale = widget.type == ListingType.sale; _maxPrice = _currencyUsd ? (sale ? 8000 : 600) : (sale ? 11200000 : 840000); _draftMaxPrice = _maxPrice; }
  void _go(BuildContext context, String route) { if (ModalRoute.of(context)?.settings.name == route) return; Navigator.pushNamed(context, route); }
  void _clearFilters() { setState(() { _selectedLocations.clear(); _selectedKinds.clear(); _search.clear(); _sortOption = SortOption.lowestPrice; _resetPriceRange(); }); }

  @override
  Widget build(BuildContext context) {
    final sale = widget.type == ListingType.sale;
    final minPrice = _currencyUsd ? (sale ? 4000 : 150) : (sale ? 5600000 : 210000);
    final maxPrice = _currencyUsd ? (sale ? 8000 : 600) : (sale ? 11200000 : 840000);
    final listings = [..._service.fetchByType(widget.type), ...DemoListingStore.instance.created.value.where((p) => p.type == widget.type)];
    final query = _search.text.trim().toLowerCase();
    final filtered = listings.where((item) {
      final locationOk = _selectedLocations.isEmpty || _selectedLocations.contains(item.location);
      final kindOk = _selectedKinds.isEmpty || _selectedKinds.contains(item.kind);
      final price = _currencyUsd ? item.priceUsd : item.priceUsd * _arsPerUsd;
      final textOk = query.isEmpty || item.title.toLowerCase().contains(query) || item.location.toLowerCase().contains(query) || item.description.toLowerCase().contains(query);
      return locationOk && kindOk && price <= _maxPrice && textOk;
    }).toList();
    filtered.sort((a, b) {
      final pa = _currencyUsd ? a.priceUsd : a.priceUsd * _arsPerUsd;
      final pb = _currencyUsd ? b.priceUsd : b.priceUsd * _arsPerUsd;
      switch (_sortOption) {
        case SortOption.lowestPrice: return pa.compareTo(pb);
        case SortOption.highestPrice: return pb.compareTo(pa);
        case SortOption.highestRating: return RatingService.instance.average(b.id).compareTo(RatingService.instance.average(a.id));
        case SortOption.locationAsc: return a.location.compareTo(b.location);
      }
    });

    return Scaffold(body: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: SiteHeader(currentRoute: sale ? AppRoutes.sales : AppRoutes.rentals, onGoHome: () => _go(context, AppRoutes.home), onGoSales: () => _go(context, AppRoutes.sales), onGoRentals: () => _go(context, AppRoutes.rentals), onGoContact: () => _go(context, AppRoutes.contact), onGoLogin: () => _go(context, AppRoutes.login), onGoProfile: () => _go(context, AppRoutes.profile), onGoCrm: () => _go(context, AppRoutes.crm))),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 28, 16, 0), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sale ? 'Propiedades en venta' : 'Propiedades en alquiler', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 6), Text(sale ? 'Encontrá propiedades por ubicación, presupuesto, servicios y calificación de clientes.' : 'Explorá propiedades disponibles, compará opciones y encontrá la que mejor encaja con vos.')])) , const SizedBox(width: 12), OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, AppRoutes.map), icon: const Icon(Icons.map_outlined), label: const Text('Ver en mapa'))]),
        const SizedBox(height: 18), _buildSearchPanel(minPrice, maxPrice, sale), const SizedBox(height: 16), Row(children: [Text('${filtered.length} resultados', style: Theme.of(context).textTheme.titleMedium), const Spacer(), if (_hasActiveFilters) TextButton.icon(onPressed: _clearFilters, icon: const Icon(Icons.restart_alt_rounded, size: 18), label: const Text('Limpiar'))])
      ]))))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), sliver: SliverLayoutBuilder(builder: (context, constraints) { final width = constraints.crossAxisExtent; final columns = width >= 1180 ? 3 : width >= 720 ? 2 : 1; return SliverGrid.builder(itemCount: filtered.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: columns == 1 ? 1.18 : .76), itemBuilder: (context, index) { final listing = filtered[index]; return ListingCard(listing: listing, onViewDetail: () => Navigator.pushNamed(context, AppRoutes.detail, arguments: listing)); }); })),
      if (filtered.isEmpty) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 50), child: _EmptyResults())),
      const SliverToBoxAdapter(child: SiteFooter()), const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ]));
  }

  bool get _hasActiveFilters => _selectedLocations.isNotEmpty || _selectedKinds.isNotEmpty || _search.text.isNotEmpty || _maxPrice != (_currencyUsd ? (widget.type == ListingType.sale ? 8000 : 600) : (widget.type == ListingType.sale ? 11200000 : 840000));

  Widget _buildSearchPanel(double minPrice, double maxPrice, bool isSale) => Card(clipBehavior: Clip.antiAlias, child: Padding(padding: const EdgeInsets.all(18), child: LayoutBuilder(builder: (context, constraints) { final compact = constraints.maxWidth < 720; final fields = _filterFields(minPrice, maxPrice, isSale); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.tune_rounded, color: Theme.of(context).colorScheme.primary)), const SizedBox(width: 10), Expanded(child: Text('Buscar, filtrar y ordenar', style: Theme.of(context).textTheme.titleLarge)), _currencyToggle()]), const SizedBox(height: 14), if (compact) Column(children: fields.map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(width: double.infinity, child: w))).toList()) else Wrap(spacing: 12, runSpacing: 12, children: fields), const SizedBox(height: 8), LocationFilterChips(locations: MockPropertyService.locations, selectedLocations: _selectedLocations, onToggle: (location, selected) => setState(() => selected ? _selectedLocations.add(location) : _selectedLocations.remove(location)), onClear: () => setState(_selectedLocations.clear)), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: MockPropertyService.propertyKinds.map((kind) => FilterChip(avatar: Icon(_iconForKind(kind), size: 17), label: Text(kind.label), selected: _selectedKinds.contains(kind), onSelected: (selected) => setState(() => selected ? _selectedKinds.add(kind) : _selectedKinds.remove(kind))).toList())]); }));

  Widget _currencyToggle() => SegmentedButton<bool>(segments: const [ButtonSegment(value: true, label: Text('USD')), ButtonSegment(value: false, label: Text('ARS'))], selected: {_currencyUsd}, onSelectionChanged: (v) { setState(() { _currencyUsd = v.first; _resetPriceRange(); }); });

  List<Widget> _filterFields(double minPrice, double maxPrice, bool isSale) => [SizedBox(width: 310, child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: 'Buscar por zona, título o descripción', prefixIcon: const Icon(Icons.manage_search_rounded), suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close))))), SizedBox(width: 240, child: DropdownButtonFormField<SortOption>(initialValue: _sortOption, decoration: const InputDecoration(labelText: 'Ordenar por'), items: const [DropdownMenuItem(value: SortOption.lowestPrice, child: Text('Menor precio')), DropdownMenuItem(value: SortOption.highestPrice, child: Text('Mayor precio')), DropdownMenuItem(value: SortOption.highestRating, child: Text('Mejor calificación')), DropdownMenuItem(value: SortOption.locationAsc, child: Text('Ubicación A-Z'))], onChanged: (v) => setState(() => _sortOption = v ?? _sortOption))), SizedBox(width: 270, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hasta ${_priceLabel(_draftMaxPrice)}', style: Theme.of(context).textTheme.titleMedium), Slider(value: _draftMaxPrice.clamp(minPrice, maxPrice).toDouble(), min: minPrice, max: maxPrice, divisions: isSale ? 16 : 18, label: _priceLabel(_draftMaxPrice), onChanged: (value) => setState(() { _draftMaxPrice = value; _maxPrice = value; }))]))];

  String _priceLabel(double value) => _currencyUsd ? 'USD ${value.toStringAsFixed(0)}' : 'ARS ${value.toStringAsFixed(0)}';
  IconData _iconForKind(PropertyKind kind) { switch (kind) { case PropertyKind.house: return Icons.home_outlined; case PropertyKind.office: return Icons.business_outlined; case PropertyKind.shop: return Icons.storefront_outlined; case PropertyKind.land: return Icons.terrain_outlined; case PropertyKind.apartment: return Icons.apartment_outlined; } }
}

class _EmptyResults extends StatelessWidget { const _EmptyResults(); @override Widget build(BuildContext context) => Center(child: Card(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [Icon(Icons.search_off_rounded, size: 52, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 10), Text('No encontramos publicaciones', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), const Text('Probá ampliar la ubicación o aumentar el presupuesto máximo.')] ))); }
