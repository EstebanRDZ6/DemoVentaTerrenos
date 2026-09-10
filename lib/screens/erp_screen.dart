import 'package:flutter/material.dart';

import '../app.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../widgets/site_header.dart';

class ErpScreen extends StatefulWidget {
  const ErpScreen({super.key});

  @override
  State<ErpScreen> createState() => _ErpScreenState();
}

class _ErpScreenState extends State<ErpScreen> {
  int _section = 0;
  final Set<String> _paid = <String>{'ALQ-1002', 'ALQ-1004'};

  static const List<_ErpSection> _sections = <_ErpSection>[
    _ErpSection(Icons.dashboard_outlined, 'Resumen', 'Vista general'),
    _ErpSection(Icons.home_work_outlined, 'Propiedades', 'Inventario'),
    _ErpSection(Icons.people_alt_outlined, 'Clientes', 'Contactos y leads'),
    _ErpSection(Icons.receipt_long_outlined, 'Alquileres', 'Contratos y cobros'),
    _ErpSection(Icons.account_balance_wallet_outlined, 'Finanzas', 'Ingresos y gastos'),
    _ErpSection(Icons.task_alt_outlined, 'Tareas', 'Agenda comercial'),
    _ErpSection(Icons.analytics_outlined, 'Reportes', 'Indicadores'),
  ];

  void _go(BuildContext context, String route) => Navigator.pushNamed(context, route);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (BuildContext context, AppUser? user, Widget? child) {
        if (user?.canUseCrm != true) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                _header(context),
                const Expanded(
                  child: Center(child: Text('No tenés permisos para utilizar el ERP.')),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Column(
            children: <Widget>[
              _header(context),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool wide = constraints.maxWidth >= 980;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (wide) _sideNav(),
                        Expanded(child: _content(context, user!, wide)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return SiteHeader(
      currentRoute: AppRoutes.erp,
      onGoHome: () => _go(context, AppRoutes.home),
      onGoSales: () => _go(context, AppRoutes.sales),
      onGoRentals: () => _go(context, AppRoutes.rentals),
      onGoContact: () => _go(context, AppRoutes.contact),
      onGoLogin: () => _go(context, AppRoutes.login),
      onGoProfile: () => _go(context, AppRoutes.profile),
      onGoCrm: () => _go(context, AppRoutes.crm),
      onGoErp: () => _go(context, AppRoutes.erp),
    );
  }

  Widget _sideNav() {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFE6ECEF))),
        color: Color(0xFFFBFCFD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 4, 10, 14),
            child: Text(
              'GESTIÓN',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF75818A),
              ),
            ),
          ),
          ..._sections.asMap().entries.map((MapEntry<int, _ErpSection> entry) {
            return _navItem(entry.key, entry.value);
          }),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.auto_awesome, size: 19, color: Color(0xFF0A4D68)),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'ERP + CRM en una sola plataforma para centralizar la operación.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF24566A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, _ErpSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        selected: _section == index,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(section.icon, size: 20),
        title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: _section == index ? Text(section.subtitle, style: const TextStyle(fontSize: 10)) : null,
        onTap: () => setState(() => _section = index),
      ),
    );
  }

  Widget _content(BuildContext context, AppUser user, bool wide) {
    if (!wide) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              scrollDirection: Axis.horizontal,
              itemCount: _sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, int i) {
                return ChoiceChip(
                  label: Text(_sections[i].title),
                  selected: _section == i,
                  onSelected: (_) => setState(() => _section = i),
                );
              },
            ),
          ),
          Expanded(child: _sectionContent(context, user)),
        ],
      );
    }

    return _sectionContent(context, user);
  }

  Widget _sectionContent(BuildContext context, AppUser user) {
    switch (_section) {
      case 0:
        return _overview(context, user);
      case 1:
        return _inventory(context);
      case 2:
        return _clients(context);
      case 3:
        return _rentals(context);
      case 4:
        return _finances(context);
      case 5:
        return _tasks(context);
      case 6:
        return _reports(context);
      default:
        return _overview(context, user);
    }
  }

  Widget _shell(
    BuildContext context, {
    required String eyebrow,
    required String title,
    required String subtitle,
    required Widget child,
    List<Widget> actions = const <Widget>[],
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
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
                        Text(
                          eyebrow.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0A4D68),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xFF68757D)),
                        ),
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: actions),
                ],
              ),
              const SizedBox(height: 22),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _overview(BuildContext context, AppUser user) {
    return _shell(
      context,
      eyebrow: 'Centro de operaciones',
      title: 'ERP inmobiliario',
      subtitle: user.isOwner
          ? 'Controlá propiedades, clientes, contratos, cobranzas y rendimiento desde un único lugar.'
          : 'Tu espacio de trabajo para gestionar la operación comercial.',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () => setState(() => _section = 1),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nueva operación'),
        ),
      ],
      child: Column(
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<_Metric> data = <_Metric>[
                const _Metric('Propiedades activas', '24', '+3 este mes', Icons.home_work_outlined),
                const _Metric('Leads abiertos', '18', '+12,5%', Icons.people_alt_outlined),
                const _Metric('Cobrado este mes', 'ARS 4,82 M', '+8,4%', Icons.payments_outlined),
                const _Metric('Vencimientos', '3', 'próximos 7 días', Icons.event_outlined),
              ];

              if (constraints.maxWidth < 760) {
                return Column(
                  children: data
                      .map((_) => data)
                      .expand((List<_Metric> list) => list)
                      .take(data.length)
                      .map(
                        (_Metric metric) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _metric(metric),
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                children: data
                    .map(
                      (_Metric metric) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _metric(metric),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < 850) {
                return Column(
                  children: <Widget>[
                    _activityCard(),
                    const SizedBox(height: 14),
                    _alertsCard(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 3, child: _activityCard()),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: _alertsCard()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metric(_Metric metric) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: <Widget>[
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4F7),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(metric.icon, color: const Color(0xFF0A4D68)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(metric.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(metric.value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                  Text(metric.delta, style: const TextStyle(fontSize: 11, color: Color(0xFF527A62))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityCard() {
    return _panel(
      'Actividad reciente',
      Icons.timeline_outlined,
      const Column(
        children: <Widget>[
          _Activity(
            '08:42',
            'Nueva consulta',
            'Mariana consultó por Terreno Candelaria',
            Icons.person_add_alt_1_outlined,
          ),
          _Activity('09:15', 'Visita agendada', 'Casa Posadas · sábado 10:30', Icons.calendar_month_outlined),
          _Activity('10:02', 'Pago recibido', 'Contrato ALQ-1004 · ARS 420.000', Icons.payments_outlined),
          _Activity(
            '11:20',
            'Publicación actualizada',
            'Terreno Posadas Sur · Vendedor Demo',
            Icons.edit_note_outlined,
          ),
        ],
      ),
    );
  }

  Widget _alertsCard() {
    return _panel(
      'Atención requerida',
      Icons.priority_high_rounded,
      const Column(
        children: <Widget>[
          _Alert('3 alquileres vencen esta semana', 'Revisar cobranzas', Icons.warning_amber_rounded),
          _Alert('5 leads sin seguimiento', 'Contactar hoy', Icons.person_search_outlined),
          _Alert('2 publicaciones sin fotos', 'Completar contenido', Icons.photo_library_outlined),
        ],
      ),
    );
  }

  Widget _panel(String title, IconData icon, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 20, color: const Color(0xFF0A4D68)),
                const SizedBox(width: 9),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 13),
            child,
          ],
        ),
      ),
    );
  }

  Widget _inventory(BuildContext context) {
    return _shell(
      context,
      eyebrow: 'Activos',
      title: 'Inventario inmobiliario',
      subtitle: 'Vista operativa de propiedades, estado, responsable y rendimiento.',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () => _go(context, AppRoutes.createListing),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nueva publicación'),
        ),
      ],
      child: _dataTable(
        const <String>['Propiedad', 'Operación', 'Responsable', 'Estado', 'Interacciones'],
        const <List<String>>[
          <String>['Terreno Candelaria', 'Venta', 'Vendedor Demo', 'Publicada', '128'],
          <String>['Casa Posadas', 'Alquiler', 'Administrador', 'Alquilada', '96'],
          <String>['Terreno Posadas Sur', 'Venta', 'Vendedor Demo', 'Destacada', '214'],
          <String>['Depto Garupá', 'Alquiler', 'Administrador', 'Disponible', '73'],
        ],
      ),
    );
  }

  Widget _clients(BuildContext context) {
    return _shell(
      context,
      eyebrow: 'Relaciones',
      title: 'Clientes y oportunidades',
      subtitle: 'Centralizá contactos y próximos pasos comerciales.',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
          label: const Text('Nuevo cliente'),
        ),
      ],
      child: _dataTable(
        const <String>['Cliente', 'Interés', 'Etapa', 'Responsable', 'Próximo paso'],
        const <List<String>>[
          <String>['Mariana Benitez', 'Terreno · Candelaria', 'Nueva', 'Vendedor Demo', 'Contactar hoy'],
          <String>[
            'Carlos Fernandez',
            'Terreno · Posadas',
            'Seguimiento',
            'Vendedor Demo',
            'Enviar documentación',
          ],
          <String>['Lucía Gomez', 'Casa · Alquiler', 'Visita', 'Administrador', 'Confirmar visita'],
          <String>['Nicolás Rios', 'Depto · Garupá', 'Reserva', 'Administrador', 'Contrato viernes'],
        ],
      ),
    );
  }

  Widget _rentals(BuildContext context) {
    return _shell(
      context,
      eyebrow: 'Administración de alquileres',
      title: 'Contratos y cobranzas',
      subtitle: 'Seguimiento de inquilinos, vencimientos, pagos y morosidad.',
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Exportar'),
        ),
      ],
      child: Column(
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<_Metric> data = <_Metric>[
                const _Metric('Cobrado', 'ARS 1,68 M', '4 contratos', Icons.check_circle_outline),
                const _Metric('Pendiente', 'ARS 620.000', '2 contratos', Icons.schedule),
                const _Metric('Vencido', 'ARS 210.000', '1 contrato', Icons.warning_amber_rounded),
              ];

              if (constraints.maxWidth < 700) {
                return Column(
                  children: data
                      .map(
                        (_Metric metric) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _metric(metric),
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                children: data
                    .map(
                      (_Metric metric) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 9),
                          child: _metric(metric),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          _dataTableWithAction(context),
        ],
      ),
    );
  }

  Widget _dataTableWithAction(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Contrato')),
            DataColumn(label: Text('Inquilino')),
            DataColumn(label: Text('Vence')),
            DataColumn(label: Text('Importe')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Acción')),
          ],
          rows: <DataRow>[
            _rentalRow('ALQ-1001', 'Lucía Gomez', '05/09/2026', 'ARS 320.000'),
            _rentalRow('ALQ-1002', 'Nicolás Rios', '10/09/2026', 'ARS 250.000'),
            _rentalRow('ALQ-1003', 'Marcos Ayala', '15/09/2026', 'ARS 410.000'),
            _rentalRow('ALQ-1004', 'Romina Pereyra', '20/09/2026', 'ARS 420.000'),
          ],
        ),
      ),
    );
  }

  DataRow _rentalRow(String id, String tenant, String due, String amount) {
    final bool paid = _paid.contains(id);
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w700))),
        DataCell(Text(tenant)),
        DataCell(Text(due)),
        DataCell(Text(amount)),
        DataCell(_status(paid ? 'PAGADO' : (id == 'ALQ-1001' ? 'VENCIDO' : 'PENDIENTE'))),
        DataCell(
          TextButton(
            onPressed: () {
              setState(() {
                if (paid) {
                  _paid.remove(id);
                } else {
                  _paid.add(id);
                }
              });
            },
            child: Text(paid ? 'Marcar pendiente' : 'Marcar pagado'),
          ),
        ),
      ],
    );
  }

  Widget _status(String value) {
    final bool isPaid = value == 'PAGADO';
    final bool overdue = value == 'VENCIDO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFE8F5EC)
            : overdue
                ? const Color(0xFFFDECEC)
                : const Color(0xFFFFF5E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isPaid
              ? const Color(0xFF2E7545)
              : overdue
                  ? const Color(0xFFA73B3B)
                  : const Color(0xFF94620D),
        ),
      ),
    );
  }

  Widget _finances(BuildContext context) {
    return _shell(
      context,
      eyebrow: 'Control financiero',
      title: 'Finanzas',
      subtitle: 'Ingresos, gastos y resultado operativo de la inmobiliaria.',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Registrar movimiento'),
        ),
      ],
      child: Column(
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<_Metric> data = <_Metric>[
                const _Metric('Ingresos', 'ARS 6,24 M', 'este mes', Icons.trending_up),
                const _Metric('Gastos', 'ARS 1,42 M', 'este mes', Icons.trending_down),
                const _Metric(
                  'Resultado',
                  'ARS 4,82 M',
                  '77,2% margen',
                  Icons.account_balance_wallet_outlined,
                ),
              ];

              if (constraints.maxWidth < 700) {
                return Column(
                  children: data
                      .map(
                        (_Metric metric) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _metric(metric),
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                children: data
                    .map(
                      (_Metric metric) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 9),
                          child: _metric(metric),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          _dataTable(
            const <String>['Fecha', 'Concepto', 'Tipo', 'Categoría', 'Importe'],
            const <List<String>>[
              <String>['02/09/2026', 'Alquiler ALQ-1004', 'Ingreso', 'Alquileres', 'ARS 420.000'],
              <String>['04/09/2026', 'Comisión venta V-14', 'Ingreso', 'Ventas', 'ARS 850.000'],
              <String>['05/09/2026', 'Publicidad digital', 'Gasto', 'Marketing', 'ARS 95.000'],
              <String>['06/09/2026', 'Mantenimiento propiedad', 'Gasto', 'Operaciones', 'ARS 120.000'],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tasks(BuildContext context) {
    return _shell(
      context,
      eyebrow: 'Productividad',
      title: 'Agenda y tareas',
      subtitle: 'Organizá seguimientos, visitas, llamadas y vencimientos.',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_task, size: 18),
          label: const Text('Nueva tarea'),
        ),
      ],
      child: _dataTable(
        const <String>['Prioridad', 'Tarea', 'Responsable', 'Fecha', 'Estado'],
        const <List<String>>[
          <String>['Alta', 'Llamar a Carlos Fernandez', 'Vendedor Demo', 'Hoy · 14:00', 'Pendiente'],
          <String>['Alta', 'Reclamar alquiler ALQ-1001', 'Administrador', 'Hoy · 15:30', 'Pendiente'],
          <String>['Media', 'Confirmar visita Casa Posadas', 'Administrador', '11/09 · 10:30', 'Programada'],
          <String>['Baja', 'Actualizar fotos Terreno V-14', 'Vendedor Demo', '12/09', 'Pendiente'],
        ],
      ),
    );
  }

  Widget _reports(BuildContext context) {
    return _shell(
      context,
      eyebrow: 'Inteligencia comercial',
      title: 'Reportes',
      subtitle: 'Indicadores para tomar decisiones y detectar oportunidades.',
      child: Column(
        children: <Widget>[
          _panel(
            'Embudo comercial',
            Icons.filter_alt_outlined,
            const Column(
              children: <Widget>[
                _Bar(label: 'Consultas', value: 100, count: '64'),
                _Bar(label: 'Contactados', value: 76, count: '49'),
                _Bar(label: 'Visitas', value: 43, count: '28'),
                _Bar(label: 'Reservas', value: 18, count: '12'),
                _Bar(label: 'Cierres', value: 9, count: '6'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            'Indicadores clave',
            Icons.insights_outlined,
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _Insight('Conversión lead → visita', '43,7%'),
                _Insight('Conversión visita → cierre', '21,4%'),
                _Insight('Tiempo medio de respuesta', '18 min'),
                _Insight('Ocupación alquileres', '92%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataTable(List<String> columns, List<List<String>> rows) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns.map((String column) => DataColumn(label: Text(column))).toList(),
          rows: rows
              .map(
                (List<String> row) =>
                    DataRow(cells: row.map((String value) => DataCell(Text(value))).toList()),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ErpSection {
  const _ErpSection(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

class _Metric {
  const _Metric(this.label, this.value, this.delta, this.icon);

  final String label;
  final String value;
  final String delta;
  final IconData icon;
}

class _Activity extends StatelessWidget {
  const _Activity(this.time, this.title, this.detail, this.icon);

  final String time;
  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEAF4F7),
        foregroundColor: const Color(0xFF0A4D68),
        child: Icon(icon, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(detail),
      trailing: Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF7A858C))),
    );
  }
}

class _Alert extends StatelessWidget {
  const _Alert(this.title, this.action, this.icon);

  final String title;
  final String action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF94620D)),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(action),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value, required this.count});

  final String label;
  final String count;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          SizedBox(width: 130, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: value / 100, minHeight: 9),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Text(
              count,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  const _Insight(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF68757D))),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
