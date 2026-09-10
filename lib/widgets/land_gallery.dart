import 'package:flutter/material.dart';

class LandGallery extends StatelessWidget {
  const LandGallery({required this.images, super.key});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.4,
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
                  if (progress == null) {
                    return child;
                  }
                  return Container(
                    color: const Color(0xFFF2F2F2),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFEDEDED),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, size: 34),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}