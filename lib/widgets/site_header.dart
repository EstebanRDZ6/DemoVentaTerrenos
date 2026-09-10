import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({
    required this.currentRoute,
    required this.onGoHome,
    required this.onGoSales,
    required this.onGoRentals,
    required this.onGoContact,
    required this.onGoLogin,
    required this.onGoProfile,
    required this.onGoCrm,
    super.key,
  });

  final String currentRoute;
  final VoidCallback onGoHome;
  final VoidCallback onGoSales;
  final VoidCallback onGoRentals;
  final VoidCallback onGoContact;
  final VoidCallback onGoLogin;
  final VoidCallback onGoProfile;
  final VoidCallback onGoCrm;

  void _select(BuildContext context, String value) {
    switch (value) {
      case 'home':
        onGoHome();
        return;
      case 'sales':
        onGoSales();
        return;
      case 'rentals':
        onGoRentals();
        return;
      case 'contact':
        onGoContact();
        return;
      case 'crm':
        onGoCrm();
        return;
      case 'profile':
        onGoProfile();
        return;
      case 'logout':
        AuthService.instance.logout();
        onGoHome();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<AppUser?>(
          valueListenable: AuthService.instance.currentUser,
          builder: (BuildContext context, AppUser? user, _) {
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool compact = constraints.maxWidth < 760;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 28, vertical: compact ? 10 : 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE9EDF0))),
                  ),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onGoHome,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A4D68),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.location_on_outlined, color: Colors.white),
                            ),
                            if (!compact) ...<Widget>[
                              const SizedBox(width: 10),
                              const Text('Sitios Propiedades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            ],
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (!compact) ...<Widget>[
                        _NavItem(label: 'Inicio', selected: currentRoute == '/', onTap: onGoHome),
                        _NavItem(label: 'Venta', selected: currentRoute == '/venta', onTap: onGoSales),
                        _NavItem(label: 'Alquiler', selected: currentRoute == '/alquiler', onTap: onGoRentals),
                        _NavItem(label: 'Contacto', selected: currentRoute == '/contacto', onTap: onGoContact),
                        if (user?.role == UserRole.owner)
                          _NavItem(label: 'CRM', selected: currentRoute == '/crm', onTap: onGoCrm),
                        const SizedBox(width: 8),
                      ],
                      if (user == null)
                        compact
                            ? IconButton(tooltip: 'Iniciar sesión', onPressed: onGoLogin, icon: const Icon(Icons.login_rounded))
                            : FilledButton.icon(
                                onPressed: onGoLogin,
                                icon: const Icon(Icons.login_rounded, size: 18),
                                label: const Text('Iniciar sesión'),
                              )
                      else
                        PopupMenuButton<String>(
                          tooltip: 'Cuenta',
                          onSelected: (String value) => _select(context, value),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFDCECF2),
                            foregroundColor: const Color(0xFF0A4D68),
                            child: Text(user.username.substring(0, 1).toUpperCase()),
                          ),
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(value: 'profile', child: Text('Perfil · ${user.role.label}')),
                            if (user.role == UserRole.owner)
                              const PopupMenuItem<String>(value: 'crm', child: Text('Abrir CRM')),
                            const PopupMenuDivider(),
                            const PopupMenuItem<String>(value: 'logout', child: Text('Cerrar sesión')),
                          ],
                        ),
                      if (compact)
                        PopupMenuButton<String>(
                          tooltip: 'Menú',
                          icon: const Icon(Icons.menu_rounded),
                          onSelected: (String value) => _select(context, value),
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(value: 'home', child: Text('Inicio')),
                            const PopupMenuItem<String>(value: 'sales', child: Text('Terrenos en venta')),
                            const PopupMenuItem<String>(value: 'rentals', child: Text('Alquileres')),
                            const PopupMenuItem<String>(value: 'contact', child: Text('Contacto')),
                            if (user?.role == UserRole.owner)
                              const PopupMenuItem<String>(value: 'crm', child: Text('CRM')),
                          ],
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? const Color(0xFF0A4D68) : const Color(0xFF52606A),
          backgroundColor: selected ? const Color(0xFFEAF4F7) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}
