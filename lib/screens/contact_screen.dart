import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../widgets/contact_actions.dart';
import '../widgets/maps_preview.dart';
import '../widgets/site_header.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});
  static final Uri _mapsUri = Uri.parse('https://www.google.com/maps/place/Sitios+Propiedades/@-27.3702589,-55.9027245,18z');
  void _go(BuildContext context, String route) { if (ModalRoute.of(context)?.settings.name == route) return; Navigator.pushNamed(context, route); }
  @override Widget build(BuildContext context) => Scaffold(body: ListView(children: [SiteHeader(currentRoute: AppRoutes.contact, onGoHome: () => _go(context, AppRoutes.home), onGoSales: () => _go(context, AppRoutes.sales), onGoRentals: () => _go(context, AppRoutes.rentals), onGoContact: () => _go(context, AppRoutes.contact), onGoLogin: () => _go(context, AppRoutes.login), onGoProfile: () => _go(context, AppRoutes.profile), onGoCrm: () => _go(context, AppRoutes.crm)), Padding(padding: const EdgeInsets.all(16), child: Column(children: [const ContactActions(title: 'Contactanos', subtitle: 'Escribinos por WhatsApp, email o visita nuestra oficina.', highlightPrimaryContact: true), const SizedBox(height: 16), Card(clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 240, width: double.infinity, child: GoogleMapsPreview()), Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ubicación', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), const Text('Av. Francisco de Haro 1234, Posadas, Misiones'), const SizedBox(height: 10), ElevatedButton.icon(onPressed: () => launchUrl(_mapsUri, mode: LaunchMode.platformDefault), icon: const Icon(Icons.map_outlined), label: const Text('Ir a Google Maps'))]))])), const SizedBox(height: 24)]))]));
}
