class LandPlot {
  const LandPlot({
    required this.id,
    required this.name,
    required this.priceUsd,
    required this.location,
    required this.description,
    required this.images,
    required this.areaM2,
  });

  final String id;
  final String name;
  final double priceUsd;
  final String location;
  final String description;
  final List<String> images;
  final double areaM2;
}