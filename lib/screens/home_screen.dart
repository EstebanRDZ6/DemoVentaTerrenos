import 'package:flutter/material.dart';

import '../app.dart';
import '../widgets/company_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _go(BuildContext context, String route) { if (ModalRoute.of(context)?.settings.name == route) return; Navigator.pushNamed(context, route); }

  @override
  Widget build(BuildContext context) => Scaffold(body: ListView(children: [
    SiteHeader(currentRoute: AppRoutes.home, onGoHome: () => _go(context, AppRoutes.home), onGoSales: () => _go(context, AppRoutes.sales), onGoRentals: () => _go(context, AppRoutes.rentals), onGoContact: () => _go(context, AppRoutes.contact), onGoLogin: () => _go(context, AppRoutes.login), onGoProfile: () => _go(context, AppRoutes.profile), onGoCrm: () => _go(context, AppRoutes.crm)),
    HeroSection(onGoSales: () => _go(context, AppRoutes.sales)),
    const SizedBox(height: 28),
    _quickActions(context),
    const SizedBox(height: 20),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: CompanySection()),
    const SizedBox(height: 28),
    _businessValue(context),
    const SizedBox(height: 28),
    const SiteFooter(),
  ]));

  Widget _quickActions(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: LayoutBuilder(builder: (context, c) { final columns = c.maxWidth > 850 ? 3 : 1; final cards = [
    _action(context, Icons.map_outlined, 'Explorá en mapa', 'Visualizá propiedades por zona y abrí su ubicación en Google Maps.', () => _go(context, AppRoutes.map)),
    _action(context, Icons.campaign_outlined, 'Vendé con nosotros', 'Máxima exposición, fotografía, video y difusión multicanal.', () => _go(context, AppRoutes.sellWithUs)),
    _action(context, Icons.auto_awesome_outlined, 'Una experiencia premium', 'Compará, filtrá, calificá propiedades y contactá a un asesor.', () => _go(context, AppRoutes.sales)),
  ]; return GridView.count(crossAxisCount: columns, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.2, children: cards); })));

  Widget _action(BuildContext context, IconData icon, String title, String body, VoidCallback onTap) => Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 27)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5), Text(body, maxLines: 2, overflow: TextOverflow.ellipsis)])), const Icon(Icons.arrow_forward_rounded)]))));

  Widget _businessValue(BuildContext context) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .35), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 52), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Más que una inmobiliaria digital', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text('Una experiencia pensada para compradores, propietarios y equipos comerciales.', style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 26), Wrap(spacing: 12, runSpacing: 12, children: const [_Pill(icon: Icons.verified_outlined, text: 'Información clara'), _Pill(icon: Icons.speed_outlined, text: 'Búsqueda rápida'), _Pill(icon: Icons.star_rounded, text: 'Opiniones de clientes'), _Pill(icon: Icons.security_outlined, text: 'Proceso profesional'), _Pill(icon: Icons.insights_outlined, text: 'Seguimiento comercial')])])));
}

class _Pill extends StatelessWidget { const _Pill({required this.icon, required this.text}); final IconData icon; final String text; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(30), border: Border.all(color: Theme.of(context).dividerColor)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 7), Text(text, style: const TextStyle(fontWeight: FontWeight.w650))])); }
