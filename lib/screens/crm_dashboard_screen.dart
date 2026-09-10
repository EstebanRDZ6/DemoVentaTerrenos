import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../models/app_user.dart';
import '../models/consulta.dart';
import '../models/property_listing.dart';
import '../services/auth_service.dart';
import '../services/mock_property_service.dart';
import '../widgets/site_header.dart';

class CrmDashboardScreen extends StatefulWidget {
  const CrmDashboardScreen({super.key});

  @override
  State<CrmDashboardScreen> createState() => _CrmDashboardScreenState();
}

class _CrmDashboardScreenState extends State<CrmDashboardScreen> {
  final MockPropertyService _service = MockPropertyService.instance;
  final TextEditingController _search = TextEditingController();
  ConsultaEstado? _status;
  String? _location;
  String? _operation;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _open(String value) async {
    final Uri uri = Uri.parse(value);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (BuildContext context, AppUser? user, _) {
        if (user?.role != UserRole.owner) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                SiteHeader(
                  currentRoute: AppRoutes.crm,
                  onGoHome: () => _go(context, AppRoutes.home),
                  onGoSales: () => _go(context, AppRoutes.sales),
                  onGoRentals: () => _go(context, AppRoutes.rentals),
                  onGoContact: () => _go(context, AppRoutes.contact),
                  onGoLogin: () => _go(context, AppRoutes.login),
                  onGoProfile: () => _go(context, AppRoutes.profile),
                  onGoCrm: () => _go(context, AppRoutes.crm),
                ),
                const Expanded(child: Center(child: Text('El CRM está disponible únicamente para el propietario.'))),
              ],
            ),
          );
        }

        final List<Consulta> consultas = _service.buscarConsultas(
          query: _search.text,
          estado: _status,
          operacion: _operation,
          ubicacion: _location,
        );
        final List<Consulta> all = _service.fetchConsultas();
        final List<PropertyListing> listings = _service.fetchAll();
        final List<ListingMetrics> metrics = _service.fetchMetrics();
        final int activeLeads = all.where((Consulta c) => c.estado != ConsultaEstado.cerrado).length;
        final int hotLeads = all.where((Consulta c) => c.estado == ConsultaEstado.reserva || c.estado == ConsultaEstado.visitoPropiedad).length;
        final int closed = all.where((Consulta c) => c.estado == ConsultaEstado.cerrado).length;
        final int contacts = metrics.fold<int>(0, (int total, ListingMetrics m) => total + m.contacts);
        final int views = metrics.fold<int>(0, (int total, ListingMetrics m) => total + m.views);

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: SiteHeader(
                  currentRoute: AppRoutes.crm,
                  onGoHome: () => _go(context, AppRoutes.home),
                  onGoSales: () => _go(context, AppRoutes.sales),
                  onGoRentals: () => _go(context, AppRoutes.rentals),
                  onGoContact: () => _go(context, AppRoutes.contact),
                  onGoLogin: () => _go(context, AppRoutes.login),
                  onGoProfile: () => _go(context, AppRoutes.profile),
                  onGoCrm: () => _go(context, AppRoutes.crm),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildHeading(context, user.username),
                          const SizedBox(height: 20),
                          _buildKpis(activeLeads, hotLeads, closed, contacts, views),
                          const SizedBox(height: 20),
                          _buildLeadSearch(),
                          const SizedBox(height: 20),
                          _buildPipeline(consultas),
                          const SizedBox(height: 20),
                          _buildListingsPerformance(listings, metrics),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeading(BuildContext context, String username) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Panel comercial', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 5),
              Text('Hola, $username. Gestioná oportunidades, consultas y publicaciones desde un solo lugar.'),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _go(context, AppRoutes.sales),
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Ver publicaciones'),
        ),
      ],
    );
  }

  Widget _buildKpis(int active, int hot, int closed, int contacts, int views) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 760;
        final List<Widget> cards = <Widget>[
          _KpiCard(icon: Icons.people_alt_outlined, label: 'Leads activos', value: '$active', detail: 'Oportunidades abiertas'),
          _KpiCard(icon: Icons.local_fire_department_outlined, label: 'Alta intención', value: '$hot', detail: 'Visita o reserva'),
          _KpiCard(icon: Icons.check_circle_outline, label: 'Cerrados', value: '$closed', detail: 'Consultas finalizadas'),
          _KpiCard(icon: Icons.touch_app_outlined, label: 'Contactos', value: '$contacts', detail: '$views vistas registradas'),
        ];
        return compact
            ? Column(children: cards.map((Widget c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: c)).toList())
            : Row(children: cards.map((Widget c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: c))).toList());
      },
    );
  }

  Widget _buildLeadSearch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 800;
            final List<Widget> fields = <Widget>[
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Buscar lead por nombre o teléfono',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close)),
                  ),
                ),
              ),
              Expanded(child: _dropdownStatus()),
              Expanded(child: _dropdownOperation()),
              Expanded(child: _dropdownLocation()),
            ];
            return compact
                ? Column(children: fields.map((Widget field) => Padding(padding: const EdgeInsets.only(bottom: 10), child: field is Expanded ? SizedBox(width: double.infinity, child: field) : field)).toList())
                : Row(children: fields.map((Widget field) => Padding(padding: const EdgeInsets.only(right: 10), child: field)).toList());
          },
        ),
      ),
    );
  }

  Widget _dropdownStatus() => DropdownButtonFormField<ConsultaEstado?>(
        initialValue: _status,
        decoration: const InputDecoration(labelText: 'Estado'),
        items: <DropdownMenuItem<ConsultaEstado?>>[
          const DropdownMenuItem(value: null, child: Text('Todos')),
          ...ConsultaEstado.values.map((ConsultaEstado e) => DropdownMenuItem(value: e, child: Text(e.label))),
        ],
        onChanged: (ConsultaEstado? value) => setState(() => _status = value),
      );

  Widget _dropdownOperation() => DropdownButtonFormField<String?>(
        initialValue: _operation,
        decoration: const InputDecoration(labelText: 'Operación'),
        items: <DropdownMenuItem<String?>>[
          const DropdownMenuItem(value: null, child: Text('Todas')),
          ...MockPropertyService.operationTypes.map((String e) => DropdownMenuItem(value: e, child: Text(e))),
        ],
        onChanged: (String? value) => setState(() => _operation = value),
      );

  Widget _dropdownLocation() => DropdownButtonFormField<String?>(
        initialValue: _location,
        decoration: const InputDecoration(labelText: 'Ubicación'),
        items: <DropdownMenuItem<String?>>[
          const DropdownMenuItem(value: null, child: Text('Todas')),
          ...MockPropertyService.locations.map((String e) => DropdownMenuItem(value: e, child: Text(e))),
        ],
        onChanged: (String? value) => setState(() => _location = value),
      );

  Widget _buildPipeline(List<Consulta> consultas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Pipeline de oportunidades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 900;
            final List<Widget> columns = ConsultaEstado.values.map((ConsultaEstado status) {
              final List<Consulta> items = consultas.where((Consulta c) => c.estado == status).toList();
              return _PipelineColumn(
                status: status,
                items: items,
                onStatusChanged: (Consulta consulta, ConsultaEstado value) {
                  _service.actualizarEstadoConsulta(consultaId: consulta.id, estado: value);
                  setState(() {});
                },
                onAction: (Consulta consulta, String action) {
                  if (action == 'whatsapp') {
                    _open('https://wa.me/${consulta.whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}');
                  } else if (action == 'phone') {
                    _open('tel:${consulta.telefono.replaceAll(' ', '')}');
                  } else {
                    _open('mailto:${consulta.email}');
                  }
                },
              );
            }).toList();
            return compact
                ? Column(children: columns.map((Widget c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList())
                : Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns.map((Widget c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: c))).toList());
          },
        ),
      ],
    );
  }

  Widget _buildListingsPerformance(List<PropertyListing> listings, List<ListingMetrics> metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Rendimiento de publicaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            const Text('Detectá qué publicaciones generan más interés y contactos.'),
            const SizedBox(height: 16),
            ...metrics.map((ListingMetrics metric) {
              final PropertyListing? listing = _service.findById(metric.listingId);
              if (listing == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: const Color(0xFFEAF4F7), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.terrain_outlined, color: Color(0xFF0A4D68)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('${metric.views} vistas · ${metric.contacts} contactos', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.icon, required this.label, required this.value, required this.detail});
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: const Color(0xFFEAF4F7), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: const Color(0xFF0A4D68)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                  Text(detail, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineColumn extends StatelessWidget {
  const _PipelineColumn({required this.status, required this.items, required this.onStatusChanged, required this.onAction});
  final ConsultaEstado status;
  final List<Consulta> items;
  final void Function(Consulta, ConsultaEstado) onStatusChanged;
  final void Function(Consulta, String) onAction;

  Color get color {
    switch (status) {
      case ConsultaEstado.nueva: return Colors.blue;
      case ConsultaEstado.seguimiento: return Colors.orange;
      case ConsultaEstado.visitoPropiedad: return Colors.deepPurple;
      case ConsultaEstado.reserva: return Colors.teal;
      case ConsultaEstado.cerrado: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(status.label, style: const TextStyle(fontWeight: FontWeight.w700))),
                CircleAvatar(radius: 13, backgroundColor: color.withValues(alpha: .12), child: Text('${items.length}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800))),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Text('Sin oportunidades'))
            else
              ...items.take(6).map((Consulta item) => _LeadCard(consulta: item, color: color, onStatusChanged: onStatusChanged, onAction: onAction)),
            if (items.length > 6)
              Padding(padding: const EdgeInsets.only(top: 6), child: Text('+ ${items.length - 6} más', style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.consulta, required this.color, required this.onStatusChanged, required this.onAction});
  final Consulta consulta;
  final Color color;
  final void Function(Consulta, ConsultaEstado) onStatusChanged;
  final void Function(Consulta, String) onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE7ECEF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(consulta.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w700))),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz, size: 20),
                onSelected: (String action) => onAction(consulta, action),
                itemBuilder: (_) => const <PopupMenuEntry<String>>[
                  PopupMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                  PopupMenuItem(value: 'phone', child: Text('Llamar')),
                  PopupMenuItem(value: 'email', child: Text('Enviar email')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text('${consulta.interes} · ${consulta.ubicacion}', maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(consulta.presupuesto, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          DropdownButtonFormField<ConsultaEstado>(
            initialValue: consulta.estado,
            isDense: true,
            decoration: const InputDecoration(labelText: 'Mover a'),
            items: ConsultaEstado.values.map((ConsultaEstado e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
            onChanged: (ConsultaEstado? value) {
              if (value != null && value != consulta.estado) onStatusChanged(consulta, value);
            },
          ),
        ],
      ),
    );
  }
}
