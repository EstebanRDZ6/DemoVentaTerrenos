enum ListingType { sale, rent }

enum SortOption { lowestPrice, highestPrice, highestRating, locationAsc }

enum PropertyKind { house, office, shop, land, apartment }

extension PropertyKindLabel on PropertyKind {
  String get label {
    switch (this) {
      case PropertyKind.house: return 'Casa';
      case PropertyKind.office: return 'Oficina';
      case PropertyKind.shop: return 'Local';
      case PropertyKind.land: return 'Terreno';
      case PropertyKind.apartment: return 'Departamento';
    }
  }
}

class PropertyListing {
  const PropertyListing({
    required this.id,
    required this.type,
    required this.kind,
    required this.title,
    required this.priceUsd,
    required this.location,
    required this.description,
    required this.images,
    required this.areaM2,
    this.hasWater = true,
    this.hasElectricity = true,
    this.hasSewer = false,
    this.hasGas = false,
    this.latitude = -27.36,
    this.longitude = -55.90,
  });

  final String id;
  final ListingType type;
  final PropertyKind kind;
  final String title;
  final double priceUsd;
  final String location;
  final String description;
  final List<String> images;
  final double areaM2;
  final bool hasWater;
  final bool hasElectricity;
  final bool hasSewer;
  final bool hasGas;
  final double latitude;
  final double longitude;
}

class ListingMetrics {
  const ListingMetrics({required this.listingId, required this.views, required this.contacts});
  final String listingId;
  final int views;
  final int contacts;
}
