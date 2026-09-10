import 'package:flutter/material.dart';

import '../app.dart';
import '../models/consulta.dart';
import '../models/property_listing.dart';
import '../services/auth_service.dart';
import '../services/mock_property_service.dart';
import '../widgets/contact_actions.dart';
import '../widgets/land_gallery.dart';
import '../widgets/site_header.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({required this.listing, super.key});

  final PropertyListing listing;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final MockPropertyService _service = MockPropertyService.instance;
  final AuthService _auth = AuthService.instance;

  @override
  void initState() {
    super.initState();
    _service.trackView(widget.listing.id);
  }

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SiteHeader(
            currentRoute: widget.listing.type == ListingType.sale ? AppRoutes.sales : AppRoutes.rentals,
            onGoHome: () => _go(context, AppRoutes.home),
            onGoSales: () => _go(context, AppRoutes.sales),
            onGoRentals: () => _go(context, AppRoutes.rentals),
            onGoContact: () => _go(context, AppRoutes.contact),
            onGoLogin: () => _go(context, AppRoutes.login),
            onGoProfile: () => _go(context, AppRoutes.profile),
            onGoCrm: () => _go(context, AppRoutes.crm),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.listing.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(widget.listing.location, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                LandGallery(images: widget.listing.images),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'USD ${widget.listing.priceUsd.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 6),
                        Text('Tipo: ${widget.listing.kind.label}'),
                        const SizedBox(height: 4),
                        Text('Superficie: ${widget.listing.areaM2.toStringAsFixed(0)} m2'),
                        const SizedBox(height: 10),
                        Text(widget.listing.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ContactActions(
                  title: 'Contactanos para mas informacion',
                  subtitle: 'Te asesoramos de forma personalizada sobre esta publicacion.',
                  highlightPrimaryContact: true,
                  onAnyContactTap: () => _service.trackContact(widget.listing.id),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openLeadDialog,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Quiero mas informacion'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLeadDialog() async {
    final user = _auth.currentUser.value;
    final GlobalKey<FormState> key = GlobalKey<FormState>();
    final TextEditingController fullName = TextEditingController(text: user?.fullName ?? '');
    final TextEditingController email = TextEditingController(text: user?.email ?? '');
    final TextEditingController whatsapp = TextEditingController(text: user?.whatsapp ?? '');
    final TextEditingController address = TextEditingController(text: user?.address ?? '');

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Datos de la consulta'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: key,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: fullName,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                      validator: (String? value) {
                        if (value == null || !value.contains('@')) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: whatsapp,
                      decoration: const InputDecoration(labelText: 'WhatsApp'),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: address,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!key.currentState!.validate()) {
                  return;
                }

                _service.registrarConsulta(
                  Consulta(
                    id: 'consulta-${DateTime.now().millisecondsSinceEpoch}',
                    publicacionId: widget.listing.id,
                    publicacionTitulo: widget.listing.title,
                    nombreCompleto: fullName.text.trim(),
                    telefono: whatsapp.text.trim(),
                    email: email.text.trim(),
                    tipoOperacion: widget.listing.type == ListingType.sale ? 'Compra' : 'Alquiler',
                    interes: widget.listing.kind.label,
                    ubicacion: widget.listing.location,
                    presupuesto: widget.listing.type == ListingType.sale
                        ? 'USD ${widget.listing.priceUsd.toStringAsFixed(0)}'
                        : 'ARS ${(widget.listing.priceUsd * 1400).round()}',
                    estado: ConsultaEstado.nueva,
                    fechaContacto: DateTime.now(),
                    notas: 'Consulta generada desde detalle de publicación.',
                    creadoPor: user?.username ?? 'Visitante',
                    whatsapp: whatsapp.text.trim(),
                    direccion: address.text.trim(),
                  ),
                );

                _service.trackContact(widget.listing.id);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Consulta registrada. Te contactaremos pronto.')),
                );
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    fullName.dispose();
    email.dispose();
    whatsapp.dispose();
    address.dispose();
  }
}
