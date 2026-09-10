import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../models/app_user.dart';
import '../models/consulta.dart';
import '../models/property_listing.dart';
import '../services/auth_service.dart';
import '../services/mock_property_service.dart';
import '../widgets/site_header.dart';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});

  @override
  State<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends State<CrmScreen> {
  final AuthService _auth = AuthService.instance;
  final MockPropertyService _service = MockPropertyService.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _area = TextEditingController(text: '320');
  final TextEditingController _description = TextEditingController();
  final TextEditingController _search = TextEditingController();

  ListingType _listingType = ListingType.sale;
  PropertyKind _kind = PropertyKind.land;
  String _location = MockPropertyService.locations.first;

  ConsultaEstado? _estadoFiltro;
  String? _operacionFiltro;
  String? _ubicacionFiltro;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _area.dispose();
    _description.dispose();
    _search.dispose();
    super.dispose();
  }

  void _goTopRoute(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _openUri(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  Color _statusColor(ConsultaEstado estado) {
    switch (estado) {
      case ConsultaEstado.nueva:
        return Colors.blue;
      case ConsultaEstado.seguimiento:
        return Colors.amber.shade800;
      case ConsultaEstado.visitoPropiedad:
        return Colors.deepPurple;
      case ConsultaEstado.reserva:
        return Colors.teal;
      case ConsultaEstado.cerrado:
        return Colors.green;
    }
  }

  IconData _statusIcon(ConsultaEstado estado) {
    switch (estado) {
      case ConsultaEstado.nueva:
        return Icons.mark_email_unread_outlined;
      case ConsultaEstado.seguimiento:
        return Icons.manage_accounts_outlined;
      case ConsultaEstado.visitoPropiedad:
        return Icons.home_work_outlined;
      case ConsultaEstado.reserva:
        return Icons.task_alt_outlined;
      case ConsultaEstado.cerrado:
        return Icons.verified_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: _auth.currentUser,
      builder: (BuildContext context, AppUser? user, _) {
        final bool canViewCrm = user?.role == UserRole.owner;

        if (!canViewCrm) {
          return Scaffold(
            body: ListView(
              children: <Widget>[
                SiteHeader(
                  currentRoute: AppRoutes.crm,
                  onGoHome: () => _goTopRoute(context, AppRoutes.home),
                  onGoSales: () => _goTopRoute(context, AppRoutes.sales),
                  onGoRentals: () => _goTopRoute(context, AppRoutes.rentals),
                  onGoContact: () => _goTopRoute(context, AppRoutes.contact),
                  onGoLogin: () => _goTopRoute(context, AppRoutes.login),
                  onGoProfile: () => _goTopRoute(context, AppRoutes.profile),
                  onGoCrm: () => _goTopRoute(context, AppRoutes.crm),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('CRM profesional', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 10),
                          const Text('Solo el rol Dueño puede ver este panel.'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _goTopRoute(context, AppRoutes.login),
                            icon: const Icon(Icons.lock_open_outlined),
                            label: const Text('Ir a iniciar sesion'),
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

        final List<PropertyListing> listings = _service.fetchAll();
        final List<ListingMetrics> metrics = _service.fetchMetrics();
        final List<Consulta> consultas = _service.buscarConsultas(
          query: _search.text,
          estado: _estadoFiltro,
          operacion: _operacionFiltro,
          ubicacion: _ubicacionFiltro,
        );

        final int maxViews = max(1, metrics.fold<int>(0, (int prev, ListingMetrics m) => max(prev, m.views)));
        final int maxContacts =
            max(1, metrics.fold<int>(0, (int prev, ListingMetrics m) => max(prev, m.contacts)));

        final Map<ConsultaEstado, List<Consulta>> grouped = <ConsultaEstado, List<Consulta>>{
          for (final ConsultaEstado status in ConsultaEstado.values)
            status: consultas.where((Consulta c) => c.estado == status).toList(),
        };

        return Scaffold(
          body: ListView(
            children: <Widget>[
              SiteHeader(
                currentRoute: AppRoutes.crm,
                onGoHome: () => _goTopRoute(context, AppRoutes.home),
                onGoSales: () => _goTopRoute(context, AppRoutes.sales),
                onGoRentals: () => _goTopRoute(context, AppRoutes.rentals),
                onGoContact: () => _goTopRoute(context, AppRoutes.contact),
                onGoLogin: () => _goTopRoute(context, AppRoutes.login),
                onGoProfile: () => _goTopRoute(context, AppRoutes.profile),
                onGoCrm: () => _goTopRoute(context, AppRoutes.crm),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('CRM profesional', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    const Text(
                      'Panel simple para inmobiliarias: seguimiento de consultas, cambios de estado y acciones rapidas.',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryChips(grouped),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    _buildMetricsCard(metrics, maxViews, maxContacts),
                    const SizedBox(height: 16),
                    ...ConsultaEstado.values.map((ConsultaEstado status) {
                      final List<Consulta> statusItems = grouped[status] ?? <Consulta>[];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _StatusSection(
                          color: _statusColor(status),
                          icon: _statusIcon(status),
                          title: status.label,
                          count: statusItems.length,
                          child: statusItems.isEmpty
                              ? const Text('Sin consultas en este estado.')
                              : Column(
                                  children: statusItems
                                      .map((Consulta consulta) => _ConsultaCard(
                                            consulta: consulta,
                                            color: _statusColor(consulta.estado),
                                            onEstadoChanged: (ConsultaEstado value) {
                                              _service.actualizarEstadoConsulta(
                                                consultaId: consulta.id,
                                                estado: value,
                                              );
                                              setState(() {});
                                            },
                                            onViewDetail: () => _openConsultaDetail(consulta),
                                            onCall: () => _openUri(Uri.parse('tel:${consulta.telefono.replaceAll(' ', '')}')),
                                            onWhatsApp: () => _openUri(
                                              Uri.parse(
                                                'https://wa.me/${consulta.whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}',
                                              ),
                                            ),
                                            onEmail: () => _openUri(Uri.parse('mailto:${consulta.email}')),
                                          ))
                                      .toList(),
                                ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    _buildAddListingForm(listings.length),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryChips(Map<ConsultaEstado, List<Consulta>> grouped) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ConsultaEstado.values.map((ConsultaEstado status) {
        final int count = grouped[status]?.length ?? 0;
        return Chip(
          avatar: Icon(_statusIcon(status), color: _statusColor(status), size: 18),
          label: Text('${status.label}: $count'),
        );
      }).toList(),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Filtros y busqueda', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o telefono',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<ConsultaEstado?>(
                    initialValue: _estadoFiltro,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: <DropdownMenuItem<ConsultaEstado?>>[
                      const DropdownMenuItem<ConsultaEstado?>(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ...ConsultaEstado.values.map(
                        (ConsultaEstado e) => DropdownMenuItem<ConsultaEstado?>(
                          value: e,
                          child: Text(e.label),
                        ),
                      ),
                    ],
                    onChanged: (ConsultaEstado? value) {
                      setState(() => _estadoFiltro = value);
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _operacionFiltro,
                    decoration: const InputDecoration(labelText: 'Operacion'),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...MockPropertyService.operationTypes.map(
                        (String op) => DropdownMenuItem<String?>(value: op, child: Text(op)),
                      ),
                    ],
                    onChanged: (String? value) {
                      setState(() => _operacionFiltro = value);
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _ubicacionFiltro,
                    decoration: const InputDecoration(labelText: 'Ubicacion'),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...MockPropertyService.locations
                          .toSet()
                           .map((String location) => DropdownMenuItem<String?>(value: location, child: Text(location))),
                    ],
                    onChanged: (String? value) {
                      setState(() => _ubicacionFiltro = value);
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    _estadoFiltro = null;
                    _operacionFiltro = null;
                    _ubicacionFiltro = null;
                    _search.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Limpiar filtros'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(List<ListingMetrics> metrics, int maxViews, int maxContacts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Interacciones por publicacion', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...metrics.map((ListingMetrics m) {
              final PropertyListing? listing = _service.findById(m.listingId);
              if (listing == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    _SimpleBar(
                      label: 'Vistas',
                      value: m.views,
                      maxValue: maxViews,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(height: 6),
                    _SimpleBar(
                      label: 'Contactos',
                      value: m.contacts,
                      maxValue: maxContacts,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddListingForm(int listingCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Añadir publicacion', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              DropdownButtonFormField<ListingType>(
                initialValue: _listingType,
                decoration: const InputDecoration(labelText: 'Operacion'),
                items: const <DropdownMenuItem<ListingType>>[
                  DropdownMenuItem(value: ListingType.sale, child: Text('Venta')),
                  DropdownMenuItem(value: ListingType.rent, child: Text('Alquiler')),
                ],
                onChanged: (ListingType? value) {
                  if (value != null) {
                    setState(() => _listingType = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<PropertyKind>(
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Tipo de propiedad'),
                items: MockPropertyService.propertyKinds
                    .map(
                      (PropertyKind kind) => DropdownMenuItem<PropertyKind>(
                        value: kind,
                        child: Text(kind.label),
                      ),
                    )
                    .toList(),
                onChanged: (PropertyKind? value) {
                  if (value != null) {
                    setState(() => _kind = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Titulo'),
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio USD'),
                validator: (String? value) {
                  final double? parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Precio invalido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _area,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Superficie m2'),
                validator: (String? value) {
                  final double? parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Superficie invalida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Ubicacion'),
                items: MockPropertyService.locations
                    .map(
                      (String loc) => DropdownMenuItem<String>(
                        value: loc,
                        child: Text(loc),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _location = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _description,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descripcion'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final String id = 'p${listingCount + 1}';
                      _service.addListing(
                        PropertyListing(
                          id: id,
                          type: _listingType,
                          kind: _kind,
                          title: _title.text.trim(),
                          priceUsd: double.parse(_price.text),
                          location: _location,
                          description: _description.text.trim().isEmpty
                              ? 'Publicacion agregada desde CRM profesional.'
                              : _description.text.trim(),
                          areaM2: double.parse(_area.text),
                          images: const <String>[
                            'https://picsum.photos/seed/newlisting1/900/600',
                            'https://picsum.photos/seed/newlisting2/900/600',
                            'https://picsum.photos/seed/newlisting3/900/600',
                          ],
                        ),
                      );
                      _title.clear();
                      _price.clear();
                      _description.clear();
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Guardar publicacion'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openConsultaDetail(Consulta consulta) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(consulta.nombreCompleto),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Publicacion: ${consulta.publicacionTitulo}'),
                  Text('Operacion: ${consulta.tipoOperacion}'),
                  Text('Interes: ${consulta.interes}'),
                  Text('Ubicacion: ${consulta.ubicacion}'),
                  Text('Presupuesto: ${consulta.presupuesto}'),
                  Text('Telefono: ${consulta.telefono}'),
                  Text('Email: ${consulta.email}'),
                  Text('Direccion: ${consulta.direccion}'),
                  Text('Fecha: ${consulta.fechaContacto.day}/${consulta.fechaContacto.month}/${consulta.fechaContacto.year}'),
                  const SizedBox(height: 8),
                  Text('Notas: ${consulta.notas}'),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.color,
    required this.icon,
    required this.title,
    required this.count,
    required this.child,
  });

  final Color color;
  final IconData icon;
  final String title;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$title ($count)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ConsultaCard extends StatelessWidget {
  const _ConsultaCard({
    required this.consulta,
    required this.color,
    required this.onEstadoChanged,
    required this.onViewDetail,
    required this.onCall,
    required this.onWhatsApp,
    required this.onEmail,
  });

  final Consulta consulta;
  final Color color;
  final ValueChanged<ConsultaEstado> onEstadoChanged;
  final VoidCallback onViewDetail;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    consulta.nombreCompleto,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                DropdownButton<ConsultaEstado>(
                  value: consulta.estado,
                  items: ConsultaEstado.values
                      .map(
                        (ConsultaEstado status) => DropdownMenuItem<ConsultaEstado>(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (ConsultaEstado? value) {
                    if (value != null) {
                      onEstadoChanged(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(avatar: const Icon(Icons.sell_outlined, size: 16), label: Text(consulta.tipoOperacion)),
                Chip(avatar: const Icon(Icons.home_outlined, size: 16), label: Text(consulta.interes)),
                Chip(avatar: const Icon(Icons.location_on_outlined, size: 16), label: Text(consulta.ubicacion)),
                Chip(avatar: const Icon(Icons.attach_money_outlined, size: 16), label: Text(consulta.presupuesto)),
              ],
            ),
            const SizedBox(height: 6),
            Text(consulta.publicacionTitulo),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Llamar'),
                ),
                OutlinedButton.icon(
                  onPressed: onWhatsApp,
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('WhatsApp'),
                ),
                OutlinedButton.icon(
                  onPressed: onEmail,
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email'),
                ),
                TextButton.icon(
                  onPressed: onViewDetail,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Ver detalle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleBar extends StatelessWidget {
  const _SimpleBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double factor = value / maxValue;
    return Row(
      children: <Widget>[
        SizedBox(width: 84, child: Text('$label: $value')),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 10,
              color: color,
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }
}
