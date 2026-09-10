import 'package:flutter/material.dart';

import '../app.dart';
import '../widgets/company_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: ListView(children: [
    SiteHeader(currentRoute: AppRoutes.home, onGoHome: () => _go(context, AppRoutes.home), onGoSales: () => _go(context, AppRoutes.sales), onGoRentals: () => _go(context, AppRoutes.rentals), onGoContact: () => _go(context, AppRoutes.contact), onGoLogin: () => _go(context, AppRoutes.login), onGoProfile: () => _go(context, AppRoutes.profile), onGoCrm: () => _go(context, AppRoutes.crm)),
    HeroSection(onGoSales: () => _go(context, AppRoutes.sales)), const SizedBox(height: 28), const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: CompanySection()), const SizedBox(height: 32), const SiteFooter(),
  ]));
}
