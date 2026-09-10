import 'package:flutter/material.dart';

class CompanySection extends StatelessWidget {
  const CompanySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('La empresa', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('Mision', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Brindar un servicio profesional y responsable de intermediacion en la compra, venta y alquiler de inmuebles, buscando satisfacer al cliente atendiendo, comprendiendo y trabajando sobre sus necesidades inmobiliarias especificas, y aportando valor a los inversores en bienes raices.',
            ),
            const SizedBox(height: 12),
            Text('Vision', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Ser una empresa lider en servicios inmobiliarios, referente absoluto de profesionalismo y atencion personalizada.',
            ),
            const SizedBox(height: 12),
            Text('Valores', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text('Compromiso')),
                Chip(label: Text('Integridad')),
                Chip(label: Text('Profesionalismo')),
              ],
            ),
            const SizedBox(height: 12),
            Text('Tipos de propiedades', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text('Casa')),
                Chip(label: Text('Oficina')),
                Chip(label: Text('Locales')),
                Chip(label: Text('Terreno')),
                Chip(label: Text('Departamento')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
