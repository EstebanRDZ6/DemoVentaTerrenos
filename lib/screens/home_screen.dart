import 'package:flutter/material.dart';

import '../app.dart';
import '../widgets/company_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            currentRoute: AppRoutes.home,
            onGoHome: () => _goTopRoute(context, AppRoutes.home),
            onGoSales: () => _goTopRoute(context, AppRoutes.sales),
            onGoRentals: () => _goTopRoute(context, AppRoutes.rentals),
            onGoContact: () => _goTopRoute(context, AppRoutes.contact),
            onGoLogin: () => _goTopRoute(context, AppRoutes.login),
            onGoProfile: () => _goTopRoute(context, AppRoutes.profile),
            onGoCrm: () => _goTopRoute(context, AppRoutes.crm),
          ),
          HeroSection(
            onGoSales: () => _goTopRoute(context, AppRoutes.sales),
          ),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CompanySection(),
          ),
          const SizedBox(height: 32),
          const SiteFooter(),
        ],
      ),
    );
  }
}