import 'package:flutter/material.dart';

class GoogleMapsPreview extends StatelessWidget {
  const GoogleMapsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://staticmap.openstreetmap.de/staticmap.php?center=-27.3703386,-55.9025746&zoom=16&size=1200x500&markers=-27.3703386,-55.9025746,red-pushpin',
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFEAEAEA),
        alignment: Alignment.center,
        child: const Icon(Icons.map_outlined, size: 42),
      ),
    );
  }
}
