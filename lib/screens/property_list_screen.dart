import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../app.dart';
import '../models/property_listing.dart';
import '../services/demo_listing_store.dart';
import '../services/mock_property_service.dart';
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

  void _resetPriceRange() { final bool sale = widget.type == ListingType.sale; _maxPrice = _currencyUsd ? (sale ? 8000 : 600) : (sale ? 11200000 : 840000); _draftMaxPrice = _maxPrice; }
  void _goTopRoute(BuildContext context, String route) { if (ModalRoute.of(context)?.settings.name == route) return; Navigator.pushNamed(context, route); }
  void _clearFilters() { setState(() { _selectedLocations.clear(); _selectedKinds.clear(); _search.clear(); _sortOption = SortOption.lowestPrice; _resetPriceRange(); }); }

  @override
  Widget build(BuildContext context) {
    final bool isSale = widget.type == ListingType.sale;
    final double minPrice = _currencyUsd ? (isSale ? 4000 : 150) : (isSale ? 5600000 : 210000);
    final double maxPrice = _currencyUsd ? (isSale ? 8000 : 600) : (isSale ? 11200000 : 840000);
    final List<PropertyListing> listings = [..._service.fetchByType(widget.type), ...DemoListingStore.instance.created.value.where((p) => p.type == widget.type)];
    final String query = _search.text.trim().toLowerCase();
    final List<PropertyListing> filtered = listings.where((item) {
      final bool locationOk = _selectedLocations.isEmpty || _selectedLocations.contains(item.location);
      final bool kindOk = _selectedKinds.isEmpty || _selectedKinds.contains(item.kind);
      final double price = _currencyUsd ? item.priceUsd : item.priceUsd * _arsPerUsd;
      final bool priceOk = price <= _maxPrice;
      final bool textOk = query.isEmpty || item.title.toLowerCase().contains(query) || item.location.toLowerCase().contains(query) || item.description.toLowerCase().contains(query);
      return locationOk && kindOk && priceOk && textOk;
    }).toList();
    filtered.sort((a, b) { final double pa = _currencyUsd ? a.priceUsd : a.priceUsd * _arsPerUsd; final double pb = _currencyUsd ? b.priceUsd : b.priceUsd * _arsPerUsd; switch (_sortOption) { case SortOption.lowestPrice: return pa.compareTo(pb); case SortOption.highestPrice: return pb.compareTo(pa); case SortOption.locationAsc: return a.location.compareTo(b.location); } });

    return Scaffold(body: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: SiteHeader(currentRoute: isSale ? AppRoutes.sales : AppRoutes.rentals, onGoHome: () => _goTopRoute(context, AppRoutes.home), onGoSales: () => _goTopRoute(context, AppRoutes.sales), onGoRentals: () => _goTopRoute(context, AppRoutes.rentals), onGoContact: () => _goTopRoute(context, AppRoutes.contact), onGoLogin: () => _goTopRoute(context, AppRoutes.login), onGoProfile: () => _goTopRoute(context, AppRoutes.profile), onGoCrm: () => _goTopRoute(context, AppRoutes.crm))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 0), sliver: SliverToBoxAdapter(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isSale ? 'Terrenos en venta' : 'Propiedades en alquiler', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 6), Text(isSale ? 'Encontrá lotes por ubicación, superficie, presupuesto y características.' : 'Explorá propiedades disponibles y contactá directamente con el equipo.'), const SizedBox(height: 18), _buildSearchPanel(minPrice, maxPrice, isSale), const SizedBox(height: 16), Row(children: [Text('${filtered.length} resultados', style: Theme.of(context).textTheme.titleMedium), const Spacer(), if (_hasActiveFilters) TextButton.icon(onPressed: _clearFilters, icon: const Icon(Icons.restart_alt_rounded, size: 18), label: const Text('Limpiar'))])
      ]))))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), sliver: SliverLayoutBuilder(builder: (context, constraints) { final double width = constraints.crossAxisExtent; final int columns = width >= 1180 ? 3 : width >= 720 ? 2 : 1; return SliverGrid.builder(itemCount: filtered.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: columns == 1 ? 1.28 : 0.82), itemBuilder: (context, index) { final listing = filtered[index]; return ListingCard(listing: listing, onViewDetail: () => Navigator.pushNamed(context, AppRoutes.detail, arguments: listing)); }); })),
      if (filtered.isEmpty) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 50), child: _EmptyResults())),
      const SliverToBoxAdapter(child: SiteFooter()), const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ]));
  }

  bool get _hasActiveFilters => _selectedLocations.isNotEmpty || _selectedKinds.isNotEmpty || _search.text.isNotEmpty || _maxPrice != (_currencyUsd ? (widget.type == ListingType.sale ? 8000 : 600) : (widget.type == ListingType.sale ? 11200000 : 840000));

  Widget _buildSearchPanel(double minPrice, double maxPrice, bool isSale) => Card(clipBehavior: Clip.antiAlias, child: Padding(padding: const EdgeInsets.all(16), child: LayoutBuilder(builder: (context, constraints) { final bool compact = constraints.maxWidth < 720; final fields = _filterFields(minPrice, maxPrice, isSale); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.search_rounded, color: Color(0xFF0A4D68)), const SizedBox(width: 8), Expanded(child: Text('Buscar y filtrar', style: Theme.of(context).textTheme.titleLarge)), _currencyToggle()]), const SizedBox(height: 14), if (compact) Column(children: fields.map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(width: double.infinity, child: w))).toList()) else Wrap(spacing: 12, runSpacing: 12, children: fields), const SizedBox(height: 8), LocationFilterChips(locations: MockPropertyService.locations, selectedLocations: _selectedLocations, onToggle: (location, selected) => setState(() => selected ? _selectedLocations.add(location) : _selectedLocations.remove(location)), onClear: () => setState(_selectedLocations.clear)), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: MockPropertyService.propertyKinds.map((kind) => FilterChip(avatar: Icon(_iconForKind(kind), size: 17), label: Text(kind.label), selected: _selectedKinds.contains(kind), onSelected: (selected) => setState(() => selected ? _selectedKinds.add(kind) : _selectedKinds.remove(kind))).toList())]); }));

  Widget _currencyToggle() => SegmentedButton<bool>(segments: const [ButtonSegment(value: true, label: Text('USD')), ButtonSegment(value: false, label: Text('ARS'))], selected: {_currencyUsd}, onSelectionChanged: (v) { setState(() { _currencyUsd = v.first; _resetPriceRange(); }); });

  List<Widget> _filterFields(double minPrice, double maxPrice, bool isSale) => [SizedBox(width: 310, child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: 'Buscar por zona, título o descripción', prefixIcon: const Icon(Icons.manage_search_rounded), suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close))))), SizedBox(width: 240, child: DropdownButtonFormField<SortOption>(initialValue: _sortOption, decoration: const InputDecoration(labelText: 'Ordenar por'), items: const [DropdownMenuItem(value: SortOption.lowestPrice, child: Text('Menor precio')), DropdownMenuItem(value: SortOption.highestPrice, child: Text('Mayor precio')), DropdownMenuItem(value: SortOption.locationAsc, child: Text('Ubicación A-Z'))], onChanged: (v) => setState(() => _sortOption = v ?? _sortOption))), SizedBox(width: 270, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hasta ${_priceLabel(_draftMaxPrice)}', style: Theme.of(context).textTheme.titleMedium), Slider(value: _draftMaxPrice.clamp(minPrice, maxPrice).toDouble(), min: minPrice, max: maxPrice, divisions: isSale ? 16 : 18, label: _priceLabel(_draftMaxPrice), onChanged: (value) => setState(() { _draftMaxPrice = value; _maxPrice = value; }))]))];

  String _priceLabel(double value) => _currencyUsd ? 'USD ${value.toStringAsFixed(0)}' : 'ARS ${value.toStringAsFixed(0)}';
  IconData _iconForKind(PropertyKind kind) { switch (kind) { case PropertyKind.house: return Icons.home_outlined; case PropertyKind.office: return Icons.business_outlined; case PropertyKind.shop: return Icons.storefront_outlined; case PropertyKind.land: return Icons.terrain_outlined; case PropertyKind.apartment: return Icons.apartment_outlined; } }
}

class _EmptyResults extends StatelessWidget { const _EmptyResults(); @override Widget build(BuildContext context) => Center(child: Card(child: Padding(padding: const EdgeInsets.all(28), child: Column(children: [Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 10), Text('No encontramos publicaciones', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), const Text('Probá ampliar la ubicación o aumentar el presupuesto máximo.')] ))); }
