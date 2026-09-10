import 'package:flutter/material.dart';

import '../app.dart';
import '../models/app_user.dart';
import '../models/property_listing.dart';
import '../services/auth_service.dart';
import '../services/demo_listing_store.dart';
import '../widgets/site_header.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final TextEditingController _location = TextEditingController(text: 'Posadas');
  final TextEditingController _description = TextEditingController();

  ListingType _type = ListingType.sale;
  PropertyKind _kind = PropertyKind.land;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _area.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = AuthService.instance.currentUser.value;
    if (user == null || !user.canCreateListings) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
            child: const Text('No tenés permiso para crear publicaciones'),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SiteHeader(
              currentRoute: '',
              onGoHome: () => Navigator.pushNamed(context, AppRoutes.home),
              onGoSales: () => Navigator.pushNamed(context, AppRoutes.sales),
              onGoRentals: () => Navigator.pushNamed(context, AppRoutes.rentals),
              onGoContact: () => Navigator.pushNamed(context, AppRoutes.contact),
              onGoLogin: () => Navigator.pushNamed(context, AppRoutes.login),
              onGoProfile: () => Navigator.pushNamed(context, AppRoutes.profile),
              onGoCrm: () => Navigator.pushNamed(context, AppRoutes.crm),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Nueva publicación', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 5),
                            const Text('Cargá una propiedad para incorporarla a la demo.'),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                final List<Widget> fields = <Widget>[
                                  _field(_title, 'Título', Icons.title),
                                  _field(_price, 'Precio en USD', Icons.attach_money, numeric: true),
                                  _field(_area, 'Superficie m²', Icons.square_foot, numeric: true),
                                  _field(_location, 'Ubicación', Icons.location_on_outlined),
                                ];

                                if (constraints.maxWidth < 650) {
                                  return Column(
                                    children: fields
                                        .map(
                                          (Widget field) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: field,
                                          ),
                                        )
                                        .toList(),
                                  );
                                }

                                return Wrap(spacing: 12, runSpacing: 12, children: fields);
                              },
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: <Widget>[
                                SizedBox(
                                  width: 260,
                                  child: DropdownButtonFormField<ListingType>(
                                    initialValue: _type,
                                    decoration: const InputDecoration(labelText: 'Operación'),
                                    items: const <DropdownMenuItem<ListingType>>[
                                      DropdownMenuItem(value: ListingType.sale, child: Text('Venta')),
                                      DropdownMenuItem(value: ListingType.rent, child: Text('Alquiler')),
                                    ],
                                    onChanged: (ListingType? value) {
                                      setState(() => _type = value ?? _type);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: DropdownButtonFormField<PropertyKind>(
                                    initialValue: _kind,
                                    decoration: const InputDecoration(labelText: 'Tipo'),
                                    items: PropertyKind.values
                                        .map(
                                          (PropertyKind value) =>
                                              DropdownMenuItem<PropertyKind>(value: value, child: Text(value.label)),
                                        )
                                        .toList(),
                                    onChanged: (PropertyKind? value) {
                                      setState(() => _kind = value ?? _kind);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _description,
                              minLines: 4,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                alignLabelWithHint: true,
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresá una descripción';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: _save,
                                icon: const Icon(Icons.publish_outlined),
                                label: const Text('Publicar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool numeric = false}) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo requerido';
          }
          return null;
        },
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? price = double.tryParse(_price.text.replaceAll(',', '.'));
    final double? area = double.tryParse(_area.text.replaceAll(',', '.'));

    if (price == null || area == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Precio y superficie deben ser números.')),
      );
      return;
    }

    DemoListingStore.instance.add(
      PropertyListing(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        type: _type,
        kind: _kind,
        title: _title.text.trim(),
        priceUsd: price,
        location: _location.text.trim(),
        description: _description.text.trim(),
        images: const <String>['https://picsum.photos/seed/newlisting/900/600'],
        areaM2: area,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publicación creada correctamente.')),
    );

    Navigator.pushNamed(context, _type == ListingType.sale ? AppRoutes.sales : AppRoutes.rentals);
  }
}
