import 'package:flutter/material.dart';

import '../app.dart';
import '../models/app_user.dart';
import '../services/access_service.dart';
import '../services/auth_service.dart';
import '../widgets/site_header.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (context, user, _) {
        if (user?.isOwner != true) {
          return Scaffold(body: Center(child: FilledButton(onPressed: () => _go(context, AppRoutes.home), child: const Text('Volver al inicio'))));
        }
        return Scaffold(
          body: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: SiteHeader(currentRoute: '', onGoHome: () => _go(context, AppRoutes.home), onGoSales: () => _go(context, AppRoutes.sales), onGoRentals: () => _go(context, AppRoutes.rentals), onGoContact: () => _go(context, AppRoutes.contact), onGoLogin: () => _go(context, AppRoutes.login), onGoProfile: () => _go(context, AppRoutes.profile), onGoCrm: () => _go(context, AppRoutes.crm))),
            SliverPadding(padding: const EdgeInsets.all(18), sliver: SliverToBoxAdapter(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Administración', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 5), const Text('Gestioná roles y permisos comerciales de vendedores. En esta demo los cambios son locales.'),
              const SizedBox(height: 20),
              ValueListenableBuilder<List<ManagedUser>>(valueListenable: AccessService.instance.users, builder: (context, users, _) => Column(children: users.map((managed) => _UserCard(user: managed)).toList())),
              const SizedBox(height: 12),
              Card(child: ListTile(leading: const Icon(Icons.info_outline), title: const Text('Dueño'), subtitle: const Text('Siempre puede crear publicaciones, administrar usuarios y utilizar el CRM.'))),
            ]))))),
          ]),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});
  final ManagedUser user;

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(18), child: LayoutBuilder(builder: (context, c) {
      final controls = Wrap(spacing: 22, runSpacing: 8, children: [
        DropdownButton<UserRole>(value: user.role, items: UserRole.values.where((r) => r != UserRole.owner).map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(), onChanged: (value) { if (value != null) AccessService.instance.update(user, role: value); }),
        Row(mainAxisSize: MainAxisSize.min, children: [const Text('Crear publicaciones'), Switch(value: user.canCreateListings, onChanged: (v) => AccessService.instance.update(user, canCreateListings: v))]),
        Row(mainAxisSize: MainAxisSize.min, children: [const Text('Usar CRM'), Switch(value: user.canUseCrm, onChanged: (v) => AccessService.instance.update(user, canUseCrm: v))]),
      ]);
      if (c.maxWidth < 760) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_identity(), const SizedBox(height: 14), controls]);
      return Row(children: [Expanded(child: _identity()), controls]);
    })));
  }

  Widget _identity() => Row(children: [const CircleAvatar(child: Icon(Icons.person_outline)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w700)), Text('@${user.username} · ${user.email}'), const SizedBox(height: 4), Text(user.role.label, style: const TextStyle(fontSize: 12))]))]);
}
