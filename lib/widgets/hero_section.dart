import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({required this.onGoSales, super.key});

  final VoidCallback onGoSales;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            'https://picsum.photos/seed/hero-misiones/1600/1000',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) {
                return child;
              }
              return Container(
                color: const Color(0xFF212121),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (_, _, _) {
              return Container(
                color: const Color(0xFF1B1B1B),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 48),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.76),
                  Colors.black.withValues(alpha: 0.34),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Encontra tu terreno ideal en Misiones',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Catalogo moderno de lotes con informacion clara, filtros rapidos y contacto directo.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        Chip(label: Text('Venta')),
                        Chip(label: Text('Alquiler')),
                        Chip(label: Text('Asesoria personalizada')),
                      ],
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: onGoSales,
                      child: const Text('Ver propiedades en venta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}