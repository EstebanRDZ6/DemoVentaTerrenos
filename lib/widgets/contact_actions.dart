import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactActions extends StatelessWidget {
  const ContactActions({
    required this.title,
    required this.subtitle,
    this.highlightPrimaryContact = false,
    this.onAnyContactTap,
    super.key,
  });

  static final Uri _whatsAppUri = Uri.parse('https://wa.me/5493764260767');
  static final Uri _emailUri = Uri.parse('mailto:sitiospropiedades@gmail.com');
  static final Uri _mapsUri = Uri.parse(
    'https://www.google.com/maps/place/Sitios+Propiedades/@-27.3702589,-55.9027245,18z/data=!4m6!3m5!1s0x9457be39d4720e7f:0x9b4f61718b19c5a!8m2!3d-27.3703386!4d-55.9025746!16s%2Fg%2F1tfdzyqj',
  );

  final String title;
  final String subtitle;
  final bool highlightPrimaryContact;
  final VoidCallback? onAnyContactTap;

  Future<void> _openUri(Uri uri) async {
    onAnyContactTap?.call();
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () => _openUri(_whatsAppUri),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(highlightPrimaryContact ? 'Contactar ahora' : 'WhatsApp'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openUri(_emailUri),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openUri(_mapsUri),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Google Maps'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}