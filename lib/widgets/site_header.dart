import 'package:flutter/material.dart';

import '../app.dart';
import '../models/app_user.dart';
import '../services/app_locale.dart';
import '../services/auth_service.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({required this.currentRoute, required this.onGoHome, required this.onGoSales, required this.onGoRentals, required this.onGoContact, required this.onGoLogin, required this.onGoProfile, required this.onGoCrm, super.key});
  final String currentRoute; final VoidCallback onGoHome, onGoSales, onGoRentals, onGoContact, onGoLogin, onGoProfile, onGoCrm;

  void _select(BuildContext context, String value) {
    switch (value) {
      case 'home': onGoHome(); break;
      case 'sales': onGoSales(); break;
      case 'rentals': onGoRentals(); break;
      case 'contact': onGoContact(); break;
      case 'crm': onGoCrm(); break;
      case 'profile': onGoProfile(); break;
      case 'admin': Navigator.pushNamed(context, AppRoutes.admin); break;
      case 'create': Navigator.pushNamed(context, AppRoutes.createListing); break;
      case 'logout': AuthService.instance.logout(); onGoHome(); break;
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AppUser?>(valueListenable: AuthService.instance.currentUser, builder: (context, user, _) => ValueListenableBuilder<AppLanguage>(valueListenable: AppLocale.instance.language, builder: (context, language, _) {
    return Material(color: Colors.white, child: SafeArea(bottom: false, child: LayoutBuilder(builder: (context, constraints) {
      final bool compact = constraints.maxWidth < 900;
      return Container(padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 28, vertical: 10), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE9EDF0)))), child: Row(children: [
        InkWell(borderRadius: BorderRadius.circular(12), onTap: onGoHome, child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF0A4D68), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.location_on_outlined, color: Colors.white)), if (!compact) ...[const SizedBox(width: 10), const Text('Sitios Propiedades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))]])),
        const Spacer(),
        if (!compact) ...[_NavItem(label: 'Inicio', selected: currentRoute == '/', onTap: onGoHome), _NavItem(label: 'Venta', selected: currentRoute == '/venta', onTap: onGoSales), _NavItem(label: 'Alquiler', selected: currentRoute == '/alquiler', onTap: onGoRentals), _NavItem(label: 'Contacto', selected: currentRoute == '/contacto', onTap: onGoContact), if (user?.canUseCrm == true) _NavItem(label: 'CRM', selected: currentRoute == '/crm', onTap: onGoCrm)],
        _languageButton(context, language),
        const SizedBox(width: 4),
        if (user == null) FilledButton.icon(onPressed: onGoLogin, icon: const Icon(Icons.login_rounded, size: 18), label: Text(compact ? 'Entrar' : 'Iniciar sesión')) else PopupMenuButton<String>(tooltip: 'Cuenta', onSelected: (v) => _select(context, v), child: CircleAvatar(radius: 19, backgroundColor: const Color(0xFFDCECF2), foregroundColor: const Color(0xFF0A4D68), child: Text(user.username.substring(0, 1).toUpperCase())), itemBuilder: (_) => [PopupMenuItem(value: 'profile', child: Text('Perfil · ${user.role.label}')), if (user.canCreateListings) const PopupMenuItem(value: 'create', child: Text('Nueva publicación')), if (user.canUseCrm) const PopupMenuItem(value: 'crm', child: Text('Abrir CRM')), if (user.isOwner) const PopupMenuItem(value: 'admin', child: Text('Administración')), const PopupMenuDivider(), const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión'))]),
        if (compact) PopupMenuButton<String>(tooltip: 'Menú', icon: const Icon(Icons.menu_rounded), onSelected: (v) => _select(context, v), itemBuilder: (_) => [const PopupMenuItem(value: 'home', child: Text('Inicio')), const PopupMenuItem(value: 'sales', child: Text('Terrenos en venta')), const PopupMenuItem(value: 'rentals', child: Text('Alquileres')), const PopupMenuItem(value: 'contact', child: Text('Contacto')), if (user?.canUseCrm == true) const PopupMenuItem(value: 'crm', child: Text('CRM')), if (user?.canCreateListings == true) const PopupMenuItem(value: 'create', child: Text('Nueva publicación')), if (user?.isOwner == true) const PopupMenuItem(value: 'admin', child: Text('Administración'))]),
      ]);
    })));
  }));

  Widget _languageButton(BuildContext context, AppLanguage current) => PopupMenuButton<AppLanguage>(tooltip: 'Idioma', onSelected: AppLocale.instance.setLanguage, itemBuilder: (_) => const [PopupMenuItem(value: AppLanguage.es, child: Text('🇦🇷 Español')), PopupMenuItem(value: AppLanguage.en, child: Text('🇺🇸 English')), PopupMenuItem(value: AppLanguage.pt, child: Text('🇧🇷 Português'))], child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.language_rounded, size: 20), if (MediaQuery.sizeOf(context).width >= 700) ...[const SizedBox(width: 5), Text(current == AppLanguage.es ? 'ES' : current == AppLanguage.en ? 'EN' : 'PT', style: const TextStyle(fontWeight: FontWeight.w700))]])));
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.selected, required this.onTap});
  final String label; final bool selected; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 4), child: TextButton(onPressed: onTap, style: TextButton.styleFrom(foregroundColor: selected ? const Color(0xFF0A4D68) : const Color(0xFF52606A), backgroundColor: selected ? const Color(0xFFEAF4F7) : Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500))));
}
