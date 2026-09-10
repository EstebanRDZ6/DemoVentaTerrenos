import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../models/app_user.dart';
import '../models/consulta.dart';
import '../models/property_listing.dart';
import '../models/rental_payment.dart';
import '../services/auth_service.dart';
import '../services/mock_property_service.dart';
import '../services/mock_rental_service.dart';
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
    Navigator.pushNamed(context, route);
  }

  Future<void> _open(String value) async {
    await launchUrl(Uri.parse(value), mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (BuildContext context, AppUser? user, _) {
        if (user?.canUseCrm != true) {
          return _denied(context);
        }

        final List<Consulta> all = _service.fetchConsultas();
        final List<Consulta> filtered = _service.buscarConsultas(
          query: _search.text,
          estado: _status,
          operacion: _operation,
          ubicacion: _location,
        );
        final List<PropertyListing> listings = _service.fetchAll();
        final List<ListingMetrics> metrics = _service.fetchMetrics();
        final List<RentalPayment> rentals = MockRentalService.instance.fetchPayments();

        final int active = all.where((Consulta item) => item.estado != ConsultaEstado.cerrado).length;
        final int hot = all
            .where(
              (Consulta item) =>
                  item.estado == ConsultaEstado.visitoPropiedad || item.estado == ConsultaEstado.reserva,
            )
            .length;
        final int closed = all.where((Consulta item) => item.estado == ConsultaEstado.cerrado).length;
        final int contacts = metrics.fold(0, (int value, ListingMetrics item) => value + item.contacts);
        final int views = metrics.fold(0, (int value, ListingMetrics item) => value + item.views);

        final int paid = rentals.where((RentalPayment p) => p.status == PaymentStatus.paid).length;
        final int pending = rentals.where((RentalPayment p) => p.status == PaymentStatus.pending).length;
        final int overdue = rentals.where((RentalPayment p) => p.status == PaymentStatus.overdue).length;

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
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Panel comercial', style: Theme.of(context).textTheme.headlineMedium),
                                    const SizedBox(height: 4),
                                    Text(
                                      user!.isOwner
                                          ? 'Administrá leads, alquileres, publicaciones y permisos.'
                                          : 'Gestioná tus oportunidades y el seguimiento comercial.',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Wrap(
                                spacing: 8,
                                children: <Widget>[
                                  if (user.canCreateListings)
                                    OutlinedButton.icon(
                                      onPressed: () => _go(context, AppRoutes.createListing),
                                      icon: const Icon(Icons.add_business_outlined),
                                      label: const Text('Nueva publicación'),
                                    ),
                                  if (user.isOwner)
                                    OutlinedButton.icon(
                                      onPressed: () => _go(context, AppRoutes.admin),
                                      icon: const Icon(Icons.manage_accounts_outlined),
                                      label: const Text('Usuarios'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _kpis(active, hot, closed, contacts, views),
                          const SizedBox(height: 20),
                          _filters(),
                          const SizedBox(height: 20),
                          Text(
                            'Pipeline de oportunidades · ${filtered.length}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          _pipeline(filtered),
                          const SizedBox(height: 24),
                          _rentals(rentals, paid, pending, overdue),
                          const SizedBox(height: 24),
                          _performance(listings, metrics),
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

  Widget _denied(BuildContext context) {
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
          const Expanded(
            child: Center(child: Text('No tenés permisos para utilizar el CRM.')),
          ),
        ],
      ),
    );
  }

  Widget _kpis(int active, int hot, int closed, int contacts, int views) {
    final List<_KpiData> data = <_KpiData>[
      _KpiData(Icons.people_alt_outlined, 'Leads activos', '$active'),
      _KpiData(Icons.local_fire_department_outlined, 'Alta intención', '$hot'),
      _KpiData(Icons.check_circle_outline, 'Cerrados', '$closed'),
      _KpiData(Icons.touch_app_outlined, 'Contactos', '$contacts · $views vistas'),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: data
                .map(
                  (_KpiData item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Kpi(item),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: data
              .map(
                (_KpiData item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _Kpi(item),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _filters() {
    final Widget search = TextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'Buscar nombre o teléfono',
        prefixIcon: const Icon(Icons.search_rounded),
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
    );

    final Widget status = DropdownButtonFormField<ConsultaEstado?>(
      initialValue: _status,
      decoration: const InputDecoration(labelText: 'Estado'),
      items: <DropdownMenuItem<ConsultaEstado?>>[
        const DropdownMenuItem<ConsultaEstado?>(value: null, child: Text('Todos')),
        ...ConsultaEstado.values.map(
          (ConsultaEstado item) => DropdownMenuItem<ConsultaEstado?>(value: item, child: Text(item.label)),
        ),
      ],
      onChanged: (ConsultaEstado? value) => setState(() => _status = value),
    );

    final Widget operation = DropdownButtonFormField<String?>(
      initialValue: _operation,
      decoration: const InputDecoration(labelText: 'Operación'),
      items: <DropdownMenuItem<String?>>[
        const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
        ...MockPropertyService.operationTypes.map(
          (String item) => DropdownMenuItem<String?>(value: item, child: Text(item)),
        ),
      ],
      onChanged: (String? value) => setState(() => _operation = value),
    );

    final Widget location = DropdownButtonFormField<String?>(
      initialValue: _location,
      decoration: const InputDecoration(labelText: 'Ubicación'),
      items: <DropdownMenuItem<String?>>[
        const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
        ...MockPropertyService.locations.map(
          (String item) => DropdownMenuItem<String?>(value: item, child: Text(item)),
        ),
      ],
      onChanged: (String? value) => setState(() => _location = value),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 800) {
              return Column(
                children: <Widget>[
                  search,
                  const SizedBox(height: 10),
                  status,
                  const SizedBox(height: 10),
                  operation,
                  const SizedBox(height: 10),
                  location,
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(flex: 2, child: search),
                const SizedBox(width: 10),
                Expanded(child: status),
                const SizedBox(width: 10),
                Expanded(child: operation),
                const SizedBox(width: 10),
                Expanded(child: location),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _pipeline(List<Consulta> consultas) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final List<Widget> columns = ConsultaEstado.values
            .map(
              (ConsultaEstado state) => _PipelineColumn(
                state: state,
                items: consultas.where((Consulta item) => item.estado == state).toList(),
                onMove: (Consulta item, ConsultaEstado next) {
                  _service.actualizarEstadoConsulta(consultaId: item.id, estado: next);
                  setState(() {});
                },
                onAction: (Consulta item, String action) {
                  if (action == 'whatsapp') {
                    _open('https://wa.me/${item.whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}');
                  }
                  if (action == 'phone') {
                    _open('tel:${item.telefono.replaceAll(' ', '')}');
                  }
                  if (action == 'email') {
                    _open('mailto:${item.email}');
                  }
                },
              ),
            )
            .toList();

        if (constraints.maxWidth < 900) {
          return Column(
            children: columns
                .map(
                  (Widget column) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: column,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns
              .map(
                (Widget column) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: column,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _rentals(List<RentalPayment> payments, int paid, int pending, int overdue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Seguimiento de alquileres', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      const Text('Controlá quién pagó, quién adeuda y cuándo vence cada alquiler.'),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    _MiniBadge(label: 'Pagados $paid', icon: Icons.check_circle_outline),
                    _MiniBadge(label: 'Pendientes $pending', icon: Icons.schedule),
                    _MiniBadge(label: 'Vencidos $overdue', icon: Icons.warning_amber_rounded),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 760) {
                  return Column(children: payments.map(_rentalTile).toList());
                }
                return Column(children: payments.map(_rentalRow).toList());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _rentalTile(RentalPayment payment) {
    return Card(
      color: const Color(0xFFF7F9FA),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _rentalMain(payment),
            const SizedBox(height: 8),
            Text('Vence: ${_date(payment.dueDate)}'),
            Text('Importe: ARS ${payment.amountArs.toStringAsFixed(0)}'),
            if (payment.paidDate != null) Text('Pagó: ${_date(payment.paidDate!)}'),
          ],
        ),
      ),
    );
  }

  Widget _rentalRow(RentalPayment payment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(flex: 2, child: _rentalMain(payment)),
          Expanded(child: Text(payment.month)),
          Expanded(child: Text('Vence ${_date(payment.dueDate)}')),
          Expanded(child: Text('ARS ${payment.amountArs.toStringAsFixed(0)}')),
          _statusBadge(payment.status),
        ],
      ),
    );
  }

  Widget _rentalMain(RentalPayment payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(payment.tenant, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(payment.property),
      ],
    );
  }

  Widget _statusBadge(PaymentStatus status) {
    final String label = status == PaymentStatus.paid
        ? 'PAGADO'
        : status == PaymentStatus.pending
            ? 'PENDIENTE'
            : 'VENCIDO';
    final IconData icon = status == PaymentStatus.paid
        ? Icons.check
        : status == PaymentStatus.pending
            ? Icons.schedule
            : Icons.warning_amber_rounded;
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }

  String _date(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _performance(List<PropertyListing> listings, List<ListingMetrics> metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Rendimiento de publicaciones', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            const Text('Vistas y contactos generados por cada publicación.'),
            const SizedBox(height: 14),
            ...metrics.map((ListingMetrics metric) {
              final PropertyListing? listing = _service.findById(metric.listingId);
              if (listing == null) {
                return const SizedBox.shrink();
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.terrain_outlined)),
                title: Text(listing.title),
                subtitle: Text(listing.location),
                trailing: Text(
                  '${metric.views} vistas\n${metric.contacts} contactos',
                  textAlign: TextAlign.right,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _KpiData {
  const _KpiData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.data);

  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4F7),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(data.icon, color: const Color(0xFF0A4D68)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(data.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(data.value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }
}

class _PipelineColumn extends StatelessWidget {
  const _PipelineColumn({
    required this.state,
    required this.items,
    required this.onMove,
    required this.onAction,
  });

  final ConsultaEstado state;
  final List<Consulta> items;
  final void Function(Consulta, ConsultaEstado) onMove;
  final void Function(Consulta, String) onAction;

  Color get color {
    switch (state) {
      case ConsultaEstado.nueva:
        return Colors.blue;
      case ConsultaEstado.seguimiento:
        return Colors.orange;
      case ConsultaEstado.visitoPropiedad:
        return Colors.deepPurple;
      case ConsultaEstado.reserva:
        return Colors.teal;
      case ConsultaEstado.cerrado:
        return Colors.green;
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
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(state.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text(
                  '${items.length}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text('Sin oportunidades'),
              )
            else
              ...items.take(6).map(
                    (Consulta item) => _LeadCard(item, color, onMove, onAction),
                  ),
          ],
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard(this.item, this.color, this.onMove, this.onAction);

  final Consulta item;
  final Color color;
  final void Function(Consulta, ConsultaEstado) onMove;
  final void Function(Consulta, String) onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(item.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz, size: 20),
                onSelected: (String value) => onAction(item, value),
                itemBuilder: (_) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'whatsapp', child: Text('WhatsApp')),
                  PopupMenuItem<String>(value: 'phone', child: Text('Llamar')),
                  PopupMenuItem<String>(value: 'email', child: Text('Email')),
                ],
              ),
            ],
          ),
          Text('${item.interes} · ${item.ubicacion}'),
          Text(item.presupuesto, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          DropdownButtonFormField<ConsultaEstado>(
            initialValue: item.estado,
            isDense: true,
            decoration: const InputDecoration(labelText: 'Estado'),
            items: ConsultaEstado.values
                .map(
                  (ConsultaEstado value) =>
                      DropdownMenuItem<ConsultaEstado>(value: value, child: Text(value.label)),
                )
                .toList(),
            onChanged: (ConsultaEstado? value) {
              if (value != null) {
                onMove(item, value);
              }
            },
          ),
        ],
      ),
    );
  }
}
