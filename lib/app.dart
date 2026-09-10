import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/property_listing.dart';
import 'screens/admin_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/create_listing_screen.dart';
import 'screens/crm_dashboard_screen.dart';
import 'screens/erp_screen.dart';
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
  static const String erp = '/erp';
  static const String login = '/login';
  static const String profile = '/perfil';
  static const String admin = '/administracion';
  static const String createListing = '/nueva-publicacion';

  static Route<dynamic> page(String name, Widget child) => MaterialPageRoute<dynamic>(settings: RouteSettings(name: name), builder: (_) => child);
}

class SitiosPropiedadesApp extends StatelessWidget {
  const SitiosPropiedadesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sitios Propiedades',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    initialRoute: AppRoutes.home,
    onGenerateRoute: (RouteSettings settings) {
      switch (settings.name) {
        case AppRoutes.home: return MaterialPageRoute<void>(settings: settings, builder: (_) => const HomeScreen());
        case AppRoutes.sales: return MaterialPageRoute<void>(settings: settings, builder: (_) => const PropertyListScreen(type: ListingType.sale));
        case AppRoutes.rentals: return MaterialPageRoute<void>(settings: settings, builder: (_) => const PropertyListScreen(type: ListingType.rent));
        case AppRoutes.detail:
          final PropertyListing listing = settings.arguments! as PropertyListing;
          return MaterialPageRoute<void>(settings: settings, builder: (_) => PropertyDetailScreen(listing: listing));
        case AppRoutes.contact: return MaterialPageRoute<void>(settings: settings, builder: (_) => const ContactScreen());
        case AppRoutes.crm: return MaterialPageRoute<void>(settings: settings, builder: (_) => const CrmDashboardScreen());
        case AppRoutes.erp: return MaterialPageRoute<void>(settings: settings, builder: (_) => const ErpScreen());
        case AppRoutes.login: return MaterialPageRoute<void>(settings: settings, builder: (_) => const LoginScreen());
        case AppRoutes.profile: return MaterialPageRoute<void>(settings: settings, builder: (_) => const ProfileScreen());
        case AppRoutes.admin: return MaterialPageRoute<void>(settings: settings, builder: (_) => const AdminScreen());
        case AppRoutes.createListing: return MaterialPageRoute<void>(settings: settings, builder: (_) => const CreateListingScreen());
        default: return MaterialPageRoute<void>(settings: settings, builder: (_) => const HomeScreen());
      }
    },
  );
}
