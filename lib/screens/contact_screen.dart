import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../widgets/contact_actions.dart';
import '../widgets/maps_preview.dart';
import '../widgets/site_header.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static final Uri _mapsUri = Uri.parse(
    'https://www.google.com/maps/place/Sitios+Propiedades/@-27.3702589,-55.9027245,18z/data=!4m6!3m5!1s0x9457be39d4720e7f:0x9b4f61718b19c5a!8m2!3d-27.3703386!4d-55.9025746!16s%2Fg%2F1tfdzyqj',
  );

  void _goTopRoute(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SiteHeader(
            currentRoute: AppRoutes.contact,
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
              children: <Widget>[
                const ContactActions(
                  title: 'Contactanos',
                  subtitle: 'Escribinos por WhatsApp, email o visita nuestra oficina.',
                  highlightPrimaryContact: true,
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: const GoogleMapsPreview(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Ubicacion', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 6),
                            const Text('Av. Francisco de Haro 1234, Posadas, Misiones'),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => launchUrl(_mapsUri, mode: LaunchMode.platformDefault),
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Ir a Google Maps'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
