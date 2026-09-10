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

  void _go(BuildContext context, String route) => Navigator.pushReplacementNamed(context, route);
  Future<void> _open(String value) async => launchUrl(Uri.parse(value), mode: LaunchMode.platformDefault);

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (BuildContext context, AppUser? user, _) {
        if (user?.role != UserRole.owner) return _denied(context);
        final List<Consulta> all = _service.fetchConsultas();
        final List<Consulta> filtered = _service.buscarConsultas(query: _search.text, estado: _status, operacion: _operation, ubicacion: _location);
        final List<PropertyListing> listings = _service.fetchAll();
        final List<ListingMetrics> metrics = _service.fetchMetrics();
        final int active = all.where((Consulta c) => c.estado != ConsultaEstado.cerrado).length;
        final int hot = all.where((Consulta c) => c.estado == ConsultaEstado.visitoPropiedad || c.estado == ConsultaEstado.reserva).length;
        final int closed = all.where((Consulta c) => c.estado == ConsultaEstado.cerrado).length;
        final int contacts = metrics.fold(0, (int n, ListingMetrics m) => n + m.contacts);
        final int views = metrics.fold(0, (int n, ListingMetrics m) => n + m.views);

        return Scaffold(
          body: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(child: SiteHeader(
              currentRoute: AppRoutes.crm,
              onGoHome: () => _go(context, AppRoutes.home), onGoSales: () => _go(context, AppRoutes.sales),
              onGoRentals: () => _go(context, AppRoutes.rentals), onGoContact: () => _go(context, AppRoutes.contact),
              onGoLogin: () => _go(context, AppRoutes.login), onGoProfile: () => _go(context, AppRoutes.profile), onGoCrm: () => _go(context, AppRoutes.crm),
            )),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text('Panel comercial', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      const Text('Gestioná leads, seguimiento, reservas y rendimiento de publicaciones.'),
                    ])),
                    OutlinedButton.icon(onPressed: () => _go(context, AppRoutes.sales), icon: const Icon(Icons.inventory_2_outlined), label: const Text('Publicaciones')),
                  ]),
                  const SizedBox(height: 20),
                  _kpis(active, hot, closed, contacts, views),
                  const SizedBox(height: 20),
                  _filters(),
                  const SizedBox(height: 20),
                  Text('Pipeline de oportunidades · ${filtered.length}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _pipeline(filtered),
                  const SizedBox(height: 20),
                  _performance(listings, metrics),
                ]),
              ))),
            ),
          ]),
        );
      },
    );
  }

  Widget _denied(BuildContext context) => Scaffold(
    body: Column(children: <Widget>[
      SiteHeader(currentRoute: AppRoutes.crm, onGoHome: () => _go(context, AppRoutes.home), onGoSales: () => _go(context, AppRoutes.sales), onGoRentals: () => _go(context, AppRoutes.rentals), onGoContact: () => _go(context, AppRoutes.contact), onGoLogin: () => _go(context, AppRoutes.login), onGoProfile: () => _go(context, AppRoutes.profile), onGoCrm: () => _go(context, AppRoutes.crm)),
      const Expanded(child: Center(child: Text('El CRM está disponible únicamente para el propietario.'))),
    ]),
  );

  Widget _kpis(int active, int hot, int closed, int contacts, int views) {
    final List<_KpiData> data = <_KpiData>[
      _KpiData(Icons.people_alt_outlined, 'Leads activos', '$active'),
      _KpiData(Icons.local_fire_department_outlined, 'Alta intención', '$hot'),
      _KpiData(Icons.check_circle_outline, 'Cerrados', '$closed'),
      _KpiData(Icons.touch_app_outlined, 'Contactos', '$contacts · $views vistas'),
    ];
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
      if (c.maxWidth < 720) return Column(children: data.map((d) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _Kpi(d))).toList());
      return Row(children: data.map((d) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: _Kpi(d)))).toList());
    });
  }

  Widget _filters() {
    final Widget search = TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: 'Buscar nombre o teléfono', prefixIcon: const Icon(Icons.search_rounded), suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close))));
    final Widget status = DropdownButtonFormField<ConsultaEstado?>(initialValue: _status, decoration: const InputDecoration(labelText: 'Estado'), items: <DropdownMenuItem<ConsultaEstado?>>[const DropdownMenuItem(value: null, child: Text('Todos')), ...ConsultaEstado.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label)))], onChanged: (v) => setState(() => _status = v));
    final Widget operation = DropdownButtonFormField<String?>(initialValue: _operation, decoration: const InputDecoration(labelText: 'Operación'), items: <DropdownMenuItem<String?>>[const DropdownMenuItem(value: null, child: Text('Todas')), ...MockPropertyService.operationTypes.map((e) => DropdownMenuItem(value: e, child: Text(e)))], onChanged: (v) => setState(() => _operation = v));
    final Widget location = DropdownButtonFormField<String?>(initialValue: _location, decoration: const InputDecoration(labelText: 'Ubicación'), items: <DropdownMenuItem<String?>>[const DropdownMenuItem(value: null, child: Text('Todas')), ...MockPropertyService.locations.map((e) => DropdownMenuItem(value: e, child: Text(e)))], onChanged: (v) => setState(() => _location = v));
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
      if (c.maxWidth < 800) return Column(children: <Widget>[search, const SizedBox(height: 10), status, const SizedBox(height: 10), operation, const SizedBox(height: 10), location]);
      return Row(children: <Widget>[Expanded(flex: 2, child: search), const SizedBox(width: 10), Expanded(child: status), const SizedBox(width: 10), Expanded(child: operation), const SizedBox(width: 10), Expanded(child: location)]);
    })));
  }

  Widget _pipeline(List<Consulta> consultas) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
      final List<Widget> columns = ConsultaEstado.values.map((ConsultaEstado state) => _PipelineColumn(
        state: state,
        items: consultas.where((Consulta x) => x.estado == state).toList(),
        onMove: (Consulta x, ConsultaEstado next) { _service.actualizarEstadoConsulta(consultaId: x.id, estado: next); setState(() {}); },
        onAction: (Consulta x, String action) { if (action == 'whatsapp') _open('https://wa.me/${x.whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}'); if (action == 'phone') _open('tel:${x.telefono.replaceAll(' ', '')}'); if (action == 'email') _open('mailto:${x.email}'); },
      )).toList();
      if (c.maxWidth < 900) return Column(children: columns.map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w)).toList());
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns.map((w) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: w))).toList());
    });
  }

  Widget _performance(List<PropertyListing> listings, List<ListingMetrics> metrics) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    const Text('Rendimiento de publicaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
    const SizedBox(height: 5), const Text('Vistas y contactos generados por cada publicación.'), const SizedBox(height: 14),
    ...metrics.map((m) { final PropertyListing? p = _service.findById(m.listingId); if (p == null) return const SizedBox.shrink(); return ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.terrain_outlined)), title: Text(p.title), subtitle: Text(p.location), trailing: Text('${m.views} vistas\n${m.contacts} contactos', textAlign: TextAlign.right)); }),
  ])));
}

class _KpiData { const _KpiData(this.icon, this.label, this.value); final IconData icon; final String label; final String value; }
class _Kpi extends StatelessWidget { const _Kpi(this.data); final _KpiData data; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: <Widget>[Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEAF4F7), borderRadius: BorderRadius.circular(13)), child: Icon(data.icon, color: const Color(0xFF0A4D68))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(data.label, style: const TextStyle(fontWeight: FontWeight.w600)), Text(data.value, style: Theme.of(context).textTheme.titleLarge)]))]))); }

class _PipelineColumn extends StatelessWidget {
  const _PipelineColumn({required this.state, required this.items, required this.onMove, required this.onAction});
  final ConsultaEstado state; final List<Consulta> items; final void Function(Consulta, ConsultaEstado) onMove; final void Function(Consulta, String) onAction;
  Color get color { switch (state) { case ConsultaEstado.nueva: return Colors.blue; case ConsultaEstado.seguimiento: return Colors.orange; case ConsultaEstado.visitoPropiedad: return Colors.deepPurple; case ConsultaEstado.reserva: return Colors.teal; case ConsultaEstado.cerrado: return Colors.green; } }
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Row(children: <Widget>[Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Expanded(child: Text(state.label, style: const TextStyle(fontWeight: FontWeight.w700))), Text('${items.length}', style: TextStyle(color: color, fontWeight: FontWeight.w800))]), const SizedBox(height: 10),
    if (items.isEmpty) const Padding(padding: EdgeInsets.all(14), child: Text('Sin oportunidades')) else ...items.take(6).map((x) => _LeadCard(x, color, onMove, onAction)),
  ])));
}

class _LeadCard extends StatelessWidget {
  const _LeadCard(this.item, this.color, this.onMove, this.onAction); final Consulta item; final Color color; final void Function(Consulta, ConsultaEstado) onMove; final void Function(Consulta, String) onAction;
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFFF7F9FA), borderRadius: BorderRadius.circular(13)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Row(children: <Widget>[Expanded(child: Text(item.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w700))), PopupMenuButton<String>(padding: EdgeInsets.zero, icon: const Icon(Icons.more_horiz, size: 20), onSelected: (v) => onAction(item, v), itemBuilder: (_) => const <PopupMenuEntry<String>>[PopupMenuItem(value: 'whatsapp', child: Text('WhatsApp')), PopupMenuItem(value: 'phone', child: Text('Llamar')), PopupMenuItem(value: 'email', child: Text('Email'))])]),
    Text('${item.interes} · ${item.ubicacion}'), Text(item.presupuesto, style: TextStyle(color: color, fontWeight: FontWeight.w800)), const SizedBox(height: 6),
    DropdownButtonFormField<ConsultaEstado>(initialValue: item.estado, isDense: true, decoration: const InputDecoration(labelText: 'Estado'), items: ConsultaEstado.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(), onChanged: (v) { if (v != null) onMove(item, v); }),
  ]));
}
