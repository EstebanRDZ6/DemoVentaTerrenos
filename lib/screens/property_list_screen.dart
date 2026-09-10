import 'package:flutter/material.dart';

import '../app.dart';
import '../models/property_listing.dart';
import '../services/mock_property_service.dart';
import '../widgets/listing_card.dart';
import '../widgets/location_filter_chips.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({required this.type, super.key});
  final ListingType type;

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final MockPropertyService _service = MockPropertyService.instance;
  final Set<String> _selectedLocations = <String>{};
  final Set<PropertyKind> _selectedKinds = <PropertyKind>{};
  final TextEditingController _search = TextEditingController();
  SortOption _sortOption = SortOption.lowestPrice;
  double _maxPrice = 8000;
  double _draftMaxPrice = 8000;

  @override
  void initState() {
    super.initState();
    _maxPrice = widget.type == ListingType.sale ? 8000 : 600;
    _draftMaxPrice = _maxPrice;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _goTopRoute(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  void _clearFilters() {
    setState(() {
      _selectedLocations.clear();
      _selectedKinds.clear();
      _search.clear();
      _maxPrice = widget.type == ListingType.sale ? 8000 : 600;
      _draftMaxPrice = _maxPrice;
      _sortOption = SortOption.lowestPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSale = widget.type == ListingType.sale;
    final double minPrice = isSale ? 4000 : 150;
    final double maxPrice = isSale ? 8000 : 600;
    final List<PropertyListing> listings = _service.fetchByType(widget.type);

    final String query = _search.text.trim().toLowerCase();
    final List<PropertyListing> filtered = listings.where((PropertyListing item) {
      final bool locationOk = _selectedLocations.isEmpty || _selectedLocations.contains(item.location);
      final bool kindOk = _selectedKinds.isEmpty || _selectedKinds.contains(item.kind);
      final bool priceOk = item.priceUsd <= _maxPrice;
      final bool textOk = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      return locationOk && kindOk && priceOk && textOk;
    }).toList();

    filtered.sort((PropertyListing a, PropertyListing b) {
      switch (_sortOption) {
        case SortOption.lowestPrice:
          return a.priceUsd.compareTo(b.priceUsd);
        case SortOption.highestPrice:
          return b.priceUsd.compareTo(a.priceUsd);
        case SortOption.locationAsc:
          return a.location.compareTo(b.location);
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SiteHeader(
              currentRoute: isSale ? AppRoutes.sales : AppRoutes.rentals,
              onGoHome: () => _goTopRoute(context, AppRoutes.home),
              onGoSales: () => _goTopRoute(context, AppRoutes.sales),
              onGoRentals: () => _goTopRoute(context, AppRoutes.rentals),
              onGoContact: () => _goTopRoute(context, AppRoutes.contact),
              onGoLogin: () => _goTopRoute(context, AppRoutes.login),
              onGoProfile: () => _goTopRoute(context, AppRoutes.profile),
              onGoCrm: () => _goTopRoute(context, AppRoutes.crm),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(isSale ? 'Terrenos en venta' : 'Propiedades en alquiler', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Text(isSale
                          ? 'Encontrá lotes por ubicación, superficie, presupuesto y características.'
                          : 'Explorá propiedades disponibles y contactá directamente con el equipo.'),
                      const SizedBox(height: 18),
                      _buildSearchPanel(minPrice, maxPrice, isSale),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Text('${filtered.length} resultados', style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          if (_hasActiveFilters)
                            TextButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.restart_alt_rounded, size: 18),
                              label: const Text('Limpiar'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverLayoutBuilder(
              builder: (BuildContext context, SliverConstraints constraints) {
                final double width = constraints.crossAxisExtent;
                final int columns = width >= 1180 ? 3 : width >= 720 ? 2 : 1;
                final double aspect = columns == 1 ? 1.28 : 0.82;
                return SliverGrid.builder(
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: aspect,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final PropertyListing listing = filtered[index];
                    return ListingCard(
                      listing: listing,
                      onViewDetail: () => Navigator.pushNamed(context, AppRoutes.detail, arguments: listing),
                    );
                  },
                );
              },
            ),
          ),
          if (filtered.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                child: _EmptyResults(),
              ),
            ),
          const SliverToBoxAdapter(child: SiteFooter()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedLocations.isNotEmpty || _selectedKinds.isNotEmpty || _search.text.isNotEmpty;

  Widget _buildSearchPanel(double minPrice, double maxPrice, bool isSale) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 720;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.search_rounded, color: Color(0xFF0A4D68)),
                    const SizedBox(width: 8),
                    Text('Buscar y filtrar', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 14),
                if (compact)
                  Column(children: _filterFields(minPrice, maxPrice, isSale))
                else
                  Wrap(spacing: 12, runSpacing: 12, children: _filterFields(minPrice, maxPrice, isSale)),
                const SizedBox(height: 12),
                LocationFilterChips(
                  locations: MockPropertyService.locations,
                  selectedLocations: _selectedLocations,
                  onToggle: (String location, bool selected) {
                    setState(() => selected ? _selectedLocations.add(location) : _selectedLocations.remove(location));
                  },
                  onClear: () => setState(_selectedLocations.clear),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MockPropertyService.propertyKinds.map((PropertyKind kind) {
                    return FilterChip(
                      avatar: Icon(_iconForKind(kind), size: 17),
                      label: Text(kind.label),
                      selected: _selectedKinds.contains(kind),
                      onSelected: (bool selected) => setState(() {
                        selected ? _selectedKinds.add(kind) : _selectedKinds.remove(kind);
                      }),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _filterFields(double minPrice, double maxPrice, bool isSale) {
    return <Widget>[
      SizedBox(
        width: 310,
        child: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Buscar por zona, título o descripción',
            prefixIcon: const Icon(Icons.manage_search_rounded),
            suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close)),
          ),
        ),
      ),
      SizedBox(
        width: 240,
        child: DropdownButtonFormField<SortOption>(
          initialValue: _sortOption,
          decoration: const InputDecoration(labelText: 'Ordenar por'),
          items: const <DropdownMenuItem<SortOption>>[
            DropdownMenuItem(value: SortOption.lowestPrice, child: Text('Menor precio')),
            DropdownMenuItem(value: SortOption.highestPrice, child: Text('Mayor precio')),
            DropdownMenuItem(value: SortOption.locationAsc, child: Text('Ubicación A-Z')),
          ],
          onChanged: (SortOption? value) => setState(() => _sortOption = value ?? _sortOption),
        ),
      ),
      SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Hasta USD ${_draftMaxPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: _draftMaxPrice.clamp(minPrice, maxPrice),
              min: minPrice,
              max: maxPrice,
              divisions: isSale ? 16 : 18,
              label: 'USD ${_draftMaxPrice.toStringAsFixed(0)}',
              onChanged: (double value) => setState(() { _draftMaxPrice = value; _maxPrice = value; }),
            ),
          ],
        ),
      ),
    ];
  }

  IconData _iconForKind(PropertyKind kind) {
    switch (kind) {
      case PropertyKind.house: return Icons.home_outlined;
      case PropertyKind.office: return Icons.business_outlined;
      case PropertyKind.shop: return Icons.storefront_outlined;
      case PropertyKind.land: return Icons.terrain_outlined;
      case PropertyKind.apartment: return Icons.apartment_outlined;
    }
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: <Widget>[
              Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text('No encontramos publicaciones', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              const Text('Probá ampliar la ubicación o aumentar el presupuesto máximo.'),
            ],
          ),
        ),
      ),
    );
  }
}
