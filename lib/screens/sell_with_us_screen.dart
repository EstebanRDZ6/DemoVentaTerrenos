import 'package:flutter/material.dart';

import '../app.dart';
import '../services/app_locale.dart';
import '../widgets/site_header.dart';
import '../widgets/site_footer.dart';

class SellWithUsScreen extends StatelessWidget {
  const SellWithUsScreen({super.key});

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocale.instance.text;
    return Scaffold(
      body: ListView(
        children: [
          SiteHeader(
            currentRoute: AppRoutes.sellWithUs,
            onGoHome: () => _go(context, AppRoutes.home),
            onGoSales: () => _go(context, AppRoutes.sales),
            onGoRentals: () => _go(context, AppRoutes.rentals),
            onGoContact: () => _go(context, AppRoutes.contact),
            onGoLogin: () => _go(context, AppRoutes.login),
            onGoProfile: () => _go(context, AppRoutes.profile),
            onGoCrm: () => _go(context, AppRoutes.crm),
          ),
          _hero(context, t),
          _channels(context, t),
          _production(context, t),
          _process(context, t),
          _cta(context, t),
          const SiteFooter(),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, String Function(String, String, String) t) => Container(
        constraints: const BoxConstraints(minHeight: 430),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF073B4C), Color(0xFF0A4D68), Color(0xFF176B87)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 40,
              runSpacing: 32,
              children: [
                SizedBox(
                  width: 650,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24)), child: Text(t('VENDÉ CON NOSOTROS', 'SELL WITH US', 'VENDA CONOSCO'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.3))),
                    const SizedBox(height: 20),
                    Text(t('Máxima exposición para tu propiedad.', 'Maximum exposure for your property.', 'Máxima exposição para seu imóvel.'), style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontSize: 46)),
                    const SizedBox(height: 16),
                    Text(t('Combinamos marketing inmobiliario, tecnología y seguimiento comercial para que tu inmueble tenga una presentación profesional y llegue a más compradores.', 'We combine real-estate marketing, technology and sales follow-up so your property is presented professionally and reaches more buyers.', 'Combinamos marketing imobiliário, tecnologia e acompanhamento comercial para apresentar seu imóvel com profissionalismo e alcançar mais compradores.'), style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.55)),
                    const SizedBox(height: 28),
                    FilledButton.icon(onPressed: () => Navigator.pushNamed(context, AppRoutes.contact), icon: const Icon(Icons.arrow_forward_rounded), label: Text(t('Quiero vender mi propiedad', 'I want to sell my property', 'Quero vender meu imóvel')), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0A4D68), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16))),
                  ]),
                ),
                Container(width: 310, padding: const EdgeInsets.all(26), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.campaign_outlined, color: Colors.white, size: 46), const SizedBox(height: 18), Text(t('Una publicación. Muchos puntos de contacto.', 'One listing. Many touchpoints.', 'Um anúncio. Muitos pontos de contato.'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 10), Text(t('Tu inmueble se integra a una estrategia digital y comercial, no queda aislado en una sola página.', 'Your property becomes part of a digital and commercial strategy, not an isolated listing.', 'Seu imóvel entra em uma estratégia digital e comercial, não fica isolado em uma única página.'), style: const TextStyle(color: Colors.white70, height: 1.5))])),
              ],
            ),
          ),
        ),
      );

  Widget _channels(BuildContext context, String Function(String, String, String) t) {
    const channels = [
      ('Instagram', Icons.camera_alt_outlined),
      ('Facebook', Icons.facebook),
      ('TikTok', Icons.music_note_outlined),
      ('Zonaprop', Icons.home_work_outlined),
      ('Argenprop', Icons.apartment_outlined),
      ('Más canales', Icons.language_outlined),
    ];
    return _section(context, t('Máxima exposición', 'Maximum exposure', 'Máxima exposição'), t('Publicamos y distribuimos el inmueble en los canales digitales y portales inmobiliarios que más utilizan los compradores.', 'We distribute the property across the digital channels and real-estate portals buyers use most.', 'Distribuímos o imóvel nos canais digitais e portais imobiliários mais usados pelos compradores.'), Wrap(spacing: 14, runSpacing: 14, children: channels.map((item) => _channelCard(context, item.$1, item.$2)).toList()));
  }

  Widget _channelCard(BuildContext context, String name, IconData icon) => Container(width: 180, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)), child: Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 10), Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)))]));

  Widget _production(BuildContext context, String Function(String, String, String) t) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .35), child: _section(context, t('Material comercial profesional', 'Professional commercial material', 'Material comercial profissional'), t('Producimos contenido pensado para presentar el inmueble con solidez, coherencia de marca y foco comercial.', 'We create content designed to present the property with confidence, brand consistency and commercial focus.', 'Criamos conteúdo pensado para apresentar o imóvel com solidez, consistência de marca e foco comercial.'), LayoutBuilder(builder: (context, c) { final cols = c.maxWidth > 850 ? 3 : 1; final items = [
    ('Fotografía', Icons.photo_camera_outlined, 'Imágenes cuidadas para destacar ambientes, espacios, luz y atributos.'),
    ('Video', Icons.videocam_outlined, 'Recorridos y piezas dinámicas para redes y canales digitales.'),
    ('Presentación', Icons.auto_awesome_outlined, 'Ficha comercial clara, atractiva y preparada para convertir consultas.'),
  ]; return GridView.count(crossAxisCount: cols, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: 1.7, children: items.map((item) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(item.$2, size: 34, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 14), Text(item.$1, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(item.$3, style: Theme.of(context).textTheme.bodyMedium)])))).toList()); }));

  Widget _process(BuildContext context, String Function(String, String, String) t) => _section(context, t('Cómo trabajamos', 'How we work', 'Como trabalhamos'), t('Un proceso pensado para reducir fricción y mantener al propietario informado.', 'A process designed to reduce friction and keep the owner informed.', 'Um processo pensado para reduzir atrito e manter o proprietário informado.'), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _step(context, '01', 'Valuación', 'Analizamos ubicación, características y contexto de mercado.')), Expanded(child: _step(context, '02', 'Producción', 'Preparamos fotografías, video y ficha comercial.')), Expanded(child: _step(context, '03', 'Difusión', 'Distribuimos en web, redes y portales.')), Expanded(child: _step(context, '04', 'Seguimiento', 'Gestionamos consultas, visitas y oportunidades desde CRM.'))]));

  Widget _step(BuildContext context, String number, String title, String body) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(number, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 8), Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 6), Text(body, style: Theme.of(context).textTheme.bodyMedium)]));

  Widget _cta(BuildContext context, String Function(String, String, String) t) => Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 60), child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 1180), padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(28)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t('¿Querés conocer cuánto podemos hacer por tu propiedad?', 'Want to know what we can do for your property?', 'Quer saber o que podemos fazer pelo seu imóvel?'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)), const SizedBox(height: 8), Text(t('Solicitá una valuación y armamos una estrategia de publicación.', 'Request a valuation and we will build a publication strategy.', 'Solicite uma avaliação e montamos uma estratégia de divulgação.'), style: const TextStyle(color: Colors.white70))])), const SizedBox(width: 20), FilledButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.contact), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0A4D68), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16)), child: Text(t('Solicitar valuación', 'Request valuation', 'Solicitar avaliação')))])));

  Widget _section(BuildContext context, String title, String subtitle, Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 58), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text(subtitle, style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 28), child])));
}
