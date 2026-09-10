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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: ValueListenableBuilder<AppUser?>(
        valueListenable: AuthService.instance.currentUser,
        builder: (BuildContext context, AppUser? user, _) {
          return Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.location_city, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 210,
                      child: Text(
                        'Sitios Propiedades',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    _NavButton(
                      label: 'Inicio',
                      isSelected: currentRoute == '/',
                      onPressed: onGoHome,
                    ),
                    _NavButton(
                      label: 'Venta',
                      isSelected: currentRoute == '/venta',
                      onPressed: onGoSales,
                    ),
                    _NavButton(
                      label: 'Alquiler',
                      isSelected: currentRoute == '/alquiler',
                      onPressed: onGoRentals,
                    ),
                    _NavButton(
                      label: 'Contacto',
                      isSelected: currentRoute == '/contacto',
                      onPressed: onGoContact,
                    ),
                    if (user?.role == UserRole.owner)
                      _NavButton(
                        label: 'CRM',
                        isSelected: currentRoute == '/crm',
                        onPressed: onGoCrm,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (user == null)
                ElevatedButton.icon(
                  onPressed: onGoLogin,
                  icon: const Icon(Icons.login_outlined),
                  label: const Text('Iniciar sesion'),
                )
              else
                PopupMenuButton<String>(
                  icon: CircleAvatar(
                    child: Text(user.username.substring(0, 1).toUpperCase()),
                  ),
                  onSelected: (String value) {
                    if (value == 'profile') {
                      onGoProfile();
                      return;
                    }
                    AuthService.instance.logout();
                    onGoHome();
                  },
                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Text('Perfil (${user.role.label})'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Cerrar sesion'),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}