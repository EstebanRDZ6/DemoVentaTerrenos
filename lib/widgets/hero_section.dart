import 'package:flutter/material.dart';

import '../services/app_locale.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({required this.onGoSales, super.key});
  final VoidCallback onGoSales;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AppLanguage>(valueListenable: AppLocale.instance.language, builder: (context, _, __) => LayoutBuilder(builder: (context, constraints) {
    final bool compact = constraints.maxWidth < 700;
    final double height = compact ? 560 : 500;
    final t = AppLocale.instance.text;
    return SizedBox(height: height, child: Stack(fit: StackFit.expand, children: [
      Image.network('https://picsum.photos/seed/hero-misiones/1600/1000', fit: BoxFit.cover, filterQuality: FilterQuality.low, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF163B49), child: Center(child: Icon(Icons.landscape_outlined, color: Colors.white54, size: 64)))),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xCC061E29), Color(0x66061E29), Color(0x33061E29)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
      Align(alignment: compact ? Alignment.center : Alignment.centerLeft, child: SingleChildScrollView(padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 48, vertical: 30), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24)), child: Text(t('TERRENOS · MISIONES', 'LAND · MISIONES', 'TERRENOS · MISIONES'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.2))),
        const SizedBox(height: 18), Text(t('Encontrá tu terreno ideal en Misiones', 'Find your ideal property in Misiones', 'Encontre seu terreno ideal em Misiones'), textAlign: compact ? TextAlign.center : TextAlign.left, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontSize: compact ? 34 : 46)),
        const SizedBox(height: 14), Text(t('Lotes seleccionados, información clara y contacto directo para decidir con confianza.', 'Selected properties, clear information and direct contact to decide with confidence.', 'Lotes selecionados, informações claras e contato direto para decidir com confiança.'), textAlign: compact ? TextAlign.center : TextAlign.left, style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.45)),
        const SizedBox(height: 22), Container(padding: EdgeInsets.all(compact ? 12 : 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 22, offset: Offset(0, 10))]), child: compact ? Column(children: [const _SearchHint(icon: Icons.location_on_outlined, text: '¿Dónde querés comprar?'), const SizedBox(height: 8), SizedBox(width: double.infinity, child: _SearchButton(onPressed: onGoSales))]) : Row(children: [const Expanded(child: _SearchHint(icon: Icons.location_on_outlined, text: '¿Dónde querés comprar?')), const SizedBox(width: 8), SizedBox(width: 190, child: _SearchButton(onPressed: onGoSales))])),
        const SizedBox(height: 18), Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [Chip(avatar: const Icon(Icons.verified_outlined, size: 17), label: Text(t('Información clara', 'Clear information', 'Informações claras'))), Chip(avatar: const Icon(Icons.map_outlined, size: 17), label: Text(t('Ubicaciones', 'Locations', 'Localizações'))), Chip(avatar: const Icon(Icons.chat_outlined, size: 17), label: Text(t('Contacto directo', 'Direct contact', 'Contato direto')))])
      ]))))),
    ]));
  }));
}

class _SearchHint extends StatelessWidget { const _SearchHint({required this.icon, required this.text}); final IconData icon; final String text; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), decoration: BoxDecoration(color: const Color(0xFFF6F8F9), borderRadius: BorderRadius.circular(13)), child: Row(children: [Icon(icon, color: const Color(0xFF0A4D68)), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))) ])); }
class _SearchButton extends StatelessWidget { const _SearchButton({required this.onPressed}); final VoidCallback onPressed; @override Widget build(BuildContext context) => FilledButton.icon(onPressed: onPressed, icon: const Icon(Icons.search_rounded), label: Text(AppLocale.instance.text('Buscar terrenos', 'Search properties', 'Buscar terrenos')), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: const Color(0xFF0A4D68), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)))); }
