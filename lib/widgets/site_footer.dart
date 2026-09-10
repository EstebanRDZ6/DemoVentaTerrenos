import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  static final Uri _whatsAppUri = Uri.parse('https://wa.me/5493764260767');
  static final Uri _emailUri = Uri.parse('mailto:sitiospropiedades@gmail.com');

  Future<void> _openUri(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Colors.white.withValues(alpha: 0.94);

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sitios Propiedades',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text('WhatsApp: +54 9 3764 26-0767', style: TextStyle(color: textColor)),
          const SizedBox(height: 4),
          Text(
            'Email: sitiospropiedades@gmail.com',
            style: TextStyle(color: textColor),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: <Widget>[
              TextButton(
                onPressed: () => _openUri(_whatsAppUri),
                child: const Text('WhatsApp'),
              ),
              TextButton(
                onPressed: () => _openUri(_emailUri),
                child: const Text('Email'),
              ),
              const Chip(label: Text('Inicio')),
              const Chip(label: Text('Venta')),
              const Chip(label: Text('Alquiler')),
              const Chip(label: Text('Contacto')),
            ],
          ),
        ],
      ),
    );
  }
}