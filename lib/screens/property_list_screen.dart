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
  SortOption _sortOption = SortOption.lowestPrice;
  double _maxPrice = 8000;
  final ValueNotifier<double> _draftMaxPrice = ValueNotifier<double>(8000);

  @override
  void initState() {
    super.initState();
    _maxPrice = widget.type == ListingType.sale ? 8000 : 600;
    _draftMaxPrice.value = _maxPrice;
  }

  @override
  void dispose() {
    _draftMaxPrice.dispose();
    super.dispose();
  }

  void _goTopRoute(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final List<PropertyListing> listings = _service.fetchByType(widget.type);
    final bool isSale = widget.type == ListingType.sale;
    final double min = isSale ? 4000 : 150;
    final double max = isSale ? 8000 : 600;

    final List<PropertyListing> filtered = listings.where((PropertyListing item) {
      final bool locationOk = _selectedLocations.isEmpty || _selectedLocations.contains(item.location);
      final bool kindOk = _selectedKinds.isEmpty || _selectedKinds.contains(item.kind);
      final bool priceOk = item.priceUsd <= _maxPrice;
      return locationOk && kindOk && priceOk;
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isSale ? 'Propiedades en venta' : 'Propiedades en alquiler',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text('Filtra por ubicacion, tipo de propiedad y precio para encontrar rapido lo que buscas.'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      Text('${filtered.length} publicaciones', style: Theme.of(context).textTheme.titleMedium),
                      OutlinedButton.icon(
                        onPressed: () => _goTopRoute(
                          context,
                          isSale ? AppRoutes.rentals : AppRoutes.sales,
                        ),
                        icon: Icon(isSale ? Icons.home_work_outlined : Icons.sell_outlined),
                        label: Text(isSale ? 'Ir a Alquiler' : 'Ir a Venta'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LocationFilterChips(
                    locations: MockPropertyService.locations,
                    selectedLocations: _selectedLocations,
                    onToggle: (String location, bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedLocations.add(location);
                        } else {
                          _selectedLocations.remove(location);
                        }
                      });
                    },
                    onClear: () => setState(_selectedLocations.clear),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: () => setState(_selectedKinds.clear),
                        icon: const Icon(Icons.layers_clear_outlined),
                        label: const Text('Limpiar tipos'),
                      ),
                      ...MockPropertyService.propertyKinds.map(
                        (PropertyKind kind) => FilterChip(
                          label: Text(kind.label),
                          selected: _selectedKinds.contains(kind),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedKinds.add(kind);
                              } else {
                                _selectedKinds.remove(kind);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Precio USD maximo', style: Theme.of(context).textTheme.titleMedium),
                          ValueListenableBuilder<double>(
                            valueListenable: _draftMaxPrice,
                            builder: (BuildContext context, double draftValue, _) {
                              final double clamped = draftValue.clamp(min, max);
                              return Slider(
                                value: clamped,
                                min: min,
                                max: max,
                                divisions: isSale ? 16 : 18,
                                label: 'USD ${clamped.toStringAsFixed(0)}',
                                onChanged: (double value) {
                                  _draftMaxPrice.value = value;
                                },
                                onChangeEnd: (double value) {
                                  setState(() => _maxPrice = value);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<SortOption>(
                            initialValue: _sortOption,
                            decoration: const InputDecoration(labelText: 'Ordenar por'),
                            items: const <DropdownMenuItem<SortOption>>[
                              DropdownMenuItem(
                                value: SortOption.lowestPrice,
                                child: Text('Menor costo'),
                              ),
                              DropdownMenuItem(
                                value: SortOption.highestPrice,
                                child: Text('Mas caro'),
                              ),
                              DropdownMenuItem(
                                value: SortOption.locationAsc,
                                child: Text('Ubicacion'),
                              ),
                            ],
                            onChanged: (SortOption? value) {
                              if (value != null) {
                                setState(() => _sortOption = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverLayoutBuilder(
              builder: (BuildContext context, constraints) {
                final double width = constraints.crossAxisExtent;
                int crossAxisCount = 1;
                if (width >= 1100) {
                  crossAxisCount = 3;
                } else if (width >= 700) {
                  crossAxisCount = 2;
                }

                return SliverGrid.builder(
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.84,
                  ),
                  itemBuilder: (_, int index) {
                    final PropertyListing listing = filtered[index];
                    return ListingCard(
                      listing: listing,
                      onViewDetail: () {
                        Navigator.pushNamed(context, AppRoutes.detail, arguments: listing);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: SiteFooter()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
