import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/property_listing.dart';
import 'screens/contact_screen.dart';
import 'screens/crm_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/property_detail_screen.dart';
import 'screens/property_list_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String sales = '/venta';
  static const String rentals = '/alquiler';
  static const String detail = '/publicacion-detalle';
  static const String contact = '/contacto';
  static const String crm = '/crm';
  static const String login = '/login';
  static const String profile = '/perfil';
}

class SitiosPropiedadesApp extends StatelessWidget {
  const SitiosPropiedadesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sitios Propiedades',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute<void>(
              builder: (_) => const HomeScreen(),
            );
          case AppRoutes.sales:
            return MaterialPageRoute<void>(
              builder: (_) => const PropertyListScreen(type: ListingType.sale),
            );
          case AppRoutes.rentals:
            return MaterialPageRoute<void>(
              builder: (_) => const PropertyListScreen(type: ListingType.rent),
            );
          case AppRoutes.detail:
            final PropertyListing listing = settings.arguments! as PropertyListing;
            return MaterialPageRoute<void>(
              builder: (_) => PropertyDetailScreen(listing: listing),
            );
          case AppRoutes.contact:
            return MaterialPageRoute<void>(
              builder: (_) => const ContactScreen(),
            );
          case AppRoutes.crm:
            return MaterialPageRoute<void>(
              builder: (_) => const CrmScreen(),
            );
          case AppRoutes.login:
            return MaterialPageRoute<void>(
              builder: (_) => const LoginScreen(),
            );
          case AppRoutes.profile:
            return MaterialPageRoute<void>(
              builder: (_) => const ProfileScreen(),
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const HomeScreen(),
            );
        }
      },
    );
  }
}