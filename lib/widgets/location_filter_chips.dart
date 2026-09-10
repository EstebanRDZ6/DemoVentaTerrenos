import 'package:flutter/material.dart';

class LocationFilterChips extends StatelessWidget {
  const LocationFilterChips({
    required this.locations,
    required this.selectedLocations,
    required this.onToggle,
    required this.onClear,
    super.key,
  });

  final List<String> locations;
  final Set<String> selectedLocations;
  final void Function(String location, bool selected) onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: onClear,
          icon: const Icon(Icons.filter_alt_off_outlined),
          label: const Text('Limpiar filtros'),
        ),
        ...locations.map(
          (String location) => FilterChip(
            label: Text(location),
            selected: selectedLocations.contains(location),
            onSelected: (bool selected) => onToggle(location, selected),
          ),
        ),
      ],
    );
  }
}