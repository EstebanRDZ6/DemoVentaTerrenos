import '../models/property_listing.dart';
import '../models/consulta.dart';

class MockPropertyService {
  MockPropertyService._();

  static final MockPropertyService instance = MockPropertyService._();

  static const List<String> locations = <String>[
    'Posadas',
    'Garupa',
    'Candelaria',
    'Obera',
    'Eldorado',
    'Puerto Iguazu',
    'Corrientes',
  ];

  static const List<String> operationTypes = <String>[
    'Compra',
    'Venta',
    'Alquiler',
  ];

  static const List<String> interests = <String>[
    'Terreno',
    'Casa',
    'Departamento',
  ];

  static const List<PropertyKind> propertyKinds = <PropertyKind>[
    PropertyKind.house,
    PropertyKind.office,
    PropertyKind.shop,
    PropertyKind.land,
    PropertyKind.apartment,
  ];

  final List<PropertyListing> _listings = <PropertyListing>[
    const PropertyListing(
      id: 'v1',
      type: ListingType.sale,
      kind: PropertyKind.land,
      title: 'Terreno Residencial en Candelaria',
      priceUsd: 5200,
      location: 'Candelaria',
      areaM2: 360,
      description:
          'Lote para vivienda familiar en zona de crecimiento y rapido acceso.',
      images: <String>[
        'https://picsum.photos/seed/sale1a/900/600',
        'https://picsum.photos/seed/sale1b/900/600',
        'https://picsum.photos/seed/sale1c/900/600',
      ],
    ),
    const PropertyListing(
      id: 'v2',
      type: ListingType.sale,
      kind: PropertyKind.land,
      title: 'Terreno Urbano en Posadas Sur',
      priceUsd: 5900,
      location: 'Posadas',
      areaM2: 300,
      description: 'Ideal para inversion de mediano plazo con conectividad urbana.',
      images: <String>[
        'https://picsum.photos/seed/sale2a/900/600',
        'https://picsum.photos/seed/sale2b/900/600',
        'https://picsum.photos/seed/sale2c/900/600',
      ],
    ),
    const PropertyListing(
      id: 'v3',
      type: ListingType.sale,
      kind: PropertyKind.land,
      title: 'Terreno Esquinero en Garupa',
      priceUsd: 4900,
      location: 'Garupa',
      areaM2: 400,
      description: 'Lote amplio para casa con jardin o proyecto comercial.',
      images: <String>[
        'https://picsum.photos/seed/sale3a/900/600',
        'https://picsum.photos/seed/sale3b/900/600',
        'https://picsum.photos/seed/sale3c/900/600',
      ],
    ),
    const PropertyListing(
      id: 'v4',
      type: ListingType.sale,
      kind: PropertyKind.land,
      title: 'Terreno Familiar en Posadas Oeste',
      priceUsd: 6100,
      location: 'Posadas',
      areaM2: 320,
      description: 'Lote nivelado listo para construir con servicios cercanos.',
      images: <String>[
        'https://picsum.photos/seed/sale4a/900/600',
        'https://picsum.photos/seed/sale4b/900/600',
        'https://picsum.photos/seed/sale4c/900/600',
      ],
    ),
    const PropertyListing(
      id: 'a1',
      type: ListingType.rent,
      kind: PropertyKind.house,
      title: 'Casa 2 Dormitorios en Posadas',
      priceUsd: 320,
      location: 'Posadas',
      areaM2: 110,
      description: 'Alquiler mensual con patio, cochera y cercania a avenidas.',
      images: <String>[
        'https://picsum.photos/seed/rent1a/900/600',
        'https://picsum.photos/seed/rent1b/900/600',
        'https://picsum.photos/seed/rent1c/900/600',
      ],
    ),
    const PropertyListing(
      id: 'a2',
      type: ListingType.rent,
      kind: PropertyKind.apartment,
      title: 'Departamento 1 Dormitorio en Garupa',
      priceUsd: 250,
      location: 'Garupa',
      areaM2: 58,
      description: 'Unidad moderna para pareja o estudiante, zona tranquila.',
      images: <String>[
        'https://picsum.photos/seed/rent2a/900/600',
        'https://picsum.photos/seed/rent2b/900/600',
        'https://picsum.photos/seed/rent2c/900/600',
      ],
    ),
    const PropertyListing(
      id: 'a3',
      type: ListingType.rent,
      kind: PropertyKind.house,
      title: 'Casa en Candelaria con Jardin',
      priceUsd: 410,
      location: 'Candelaria',
      areaM2: 145,
      description: 'Alquiler mensual ideal para familia, con espacios verdes.',
      images: <String>[
        'https://picsum.photos/seed/rent3a/900/600',
        'https://picsum.photos/seed/rent3b/900/600',
        'https://picsum.photos/seed/rent3c/900/600',
      ],
    ),
    const PropertyListing(
      id: 'a4',
      type: ListingType.rent,
      kind: PropertyKind.office,
      title: 'Duplex en Posadas Norte',
      priceUsd: 470,
      location: 'Posadas',
      areaM2: 130,
      description: 'Duplex con dos plantas y buena conectividad comercial.',
      images: <String>[
        'https://picsum.photos/seed/rent4a/900/600',
        'https://picsum.photos/seed/rent4b/900/600',
        'https://picsum.photos/seed/rent4c/900/600',
      ],
    ),
  ];

  final Map<String, ListingMetrics> _metricsByListing = <String, ListingMetrics>{};
  final List<Consulta> _consultas = <Consulta>[
    Consulta(
      id: 'c1',
      publicacionId: 'v1',
      publicacionTitulo: 'Terreno Residencial en Candelaria',
      nombreCompleto: 'Mariana Benitez',
      telefono: '+54 9 3764 22-0199',
      email: 'mariana.benitez@gmail.com',
      tipoOperacion: 'Compra',
      interes: 'Terreno',
      ubicacion: 'Candelaria',
      presupuesto: 'USD 8.500',
      estado: ConsultaEstado.nueva,
      fechaContacto: DateTime(2026, 3, 30),
      notas: 'Viene de Facebook, consulta financiacion parcial.',
      creadoPor: 'Visitante',
      whatsapp: '+54 9 3764 22-0199',
      direccion: 'Av. Mitre 2450, Posadas',
    ),
    Consulta(
      id: 'c2',
      publicacionId: 'v2',
      publicacionTitulo: 'Terreno Urbano en Posadas Sur',
      nombreCompleto: 'Carlos Fernandez',
      telefono: '+54 9 376 438-7721',
      email: 'cfernandez@yahoo.com.ar',
      tipoOperacion: 'Compra',
      interes: 'Terreno',
      ubicacion: 'Posadas',
      presupuesto: 'USD 12.000',
      estado: ConsultaEstado.seguimiento,
      fechaContacto: DateTime(2026, 3, 28),
      notas: 'Quiere cerrar en abril si acepta contraoferta.',
      creadoPor: 'Sitios',
      whatsapp: '+54 9 376 438-7721',
      direccion: 'Barrio Itaembe Mini, Posadas',
    ),
    Consulta(
      id: 'c3',
      publicacionId: 'a1',
      publicacionTitulo: 'Casa 2 Dormitorios en Posadas',
      nombreCompleto: 'Lucia Gomez',
      telefono: '+54 9 11 6422-1180',
      email: 'lu.gomez@outlook.com',
      tipoOperacion: 'Alquiler',
      interes: 'Casa',
      ubicacion: 'Posadas',
      presupuesto: 'ARS 320.000',
      estado: ConsultaEstado.visitoPropiedad,
      fechaContacto: DateTime(2026, 3, 25),
      notas: 'Visito el sabado, espera respuesta de garante.',
      creadoPor: 'Sitios',
      whatsapp: '+54 9 11 6422-1180',
      direccion: 'Villa Sarita, Posadas',
    ),
    Consulta(
      id: 'c4',
      publicacionId: 'a2',
      publicacionTitulo: 'Departamento 1 Dormitorio en Garupa',
      nombreCompleto: 'Nicolas Rios',
      telefono: '+54 9 376 480-3302',
      email: 'nrios@gmail.com',
      tipoOperacion: 'Alquiler',
      interes: 'Departamento',
      ubicacion: 'Garupa',
      presupuesto: 'ARS 240.000',
      estado: ConsultaEstado.reserva,
      fechaContacto: DateTime(2026, 3, 22),
      notas: 'Seño con transferencia, firma contrato el viernes.',
      creadoPor: 'Cliente',
      whatsapp: '+54 9 376 480-3302',
      direccion: 'Santa Helena, Garupa',
    ),
    Consulta(
      id: 'c5',
      publicacionId: 'v3',
      publicacionTitulo: 'Terreno Esquinero en Garupa',
      nombreCompleto: 'Sofia Acosta',
      telefono: '+54 9 376 402-0981',
      email: 'sofiacosta@icloud.com',
      tipoOperacion: 'Compra',
      interes: 'Terreno',
      ubicacion: 'Garupa',
      presupuesto: 'USD 7.000',
      estado: ConsultaEstado.cerrado,
      fechaContacto: DateTime(2026, 3, 18),
      notas: 'Operacion cerrada, pago contado.',
      creadoPor: 'Sitios',
      whatsapp: '+54 9 376 402-0981',
      direccion: 'Barrio Don Santiago, Garupa',
    ),
    Consulta(
      id: 'c6',
      publicacionId: 'v4',
      publicacionTitulo: 'Terreno Familiar en Posadas Oeste',
      nombreCompleto: 'Juan Pablo Mendez',
      telefono: '+54 9 376 513-4894',
      email: 'jpmendez@mail.com',
      tipoOperacion: 'Compra',
      interes: 'Terreno',
      ubicacion: 'Posadas',
      presupuesto: 'USD 9.500',
      estado: ConsultaEstado.seguimiento,
      fechaContacto: DateTime(2026, 3, 27),
      notas: 'Solicito planos y escritura por correo.',
      creadoPor: 'Sitios',
      whatsapp: '+54 9 376 513-4894',
      direccion: 'Miguel Lanus, Posadas',
    ),
    Consulta(
      id: 'c7',
      publicacionId: 'a3',
      publicacionTitulo: 'Casa en Candelaria con Jardin',
      nombreCompleto: 'Marcos Ayala',
      telefono: '+54 9 376 528-7701',
      email: 'marcos.ayala@gmail.com',
      tipoOperacion: 'Alquiler',
      interes: 'Casa',
      ubicacion: 'Candelaria',
      presupuesto: 'ARS 420.000',
      estado: ConsultaEstado.nueva,
      fechaContacto: DateTime(2026, 3, 31),
      notas: 'Busca mudarse en 15 dias, tiene mascotas.',
      creadoPor: 'Visitante',
      whatsapp: '+54 9 376 528-7701',
      direccion: 'Centro, Candelaria',
    ),
    Consulta(
      id: 'c8',
      publicacionId: 'a4',
      publicacionTitulo: 'Duplex en Posadas Norte',
      nombreCompleto: 'Romina Pereyra',
      telefono: '+54 9 376 543-0990',
      email: 'romi.pereyra@live.com',
      tipoOperacion: 'Alquiler',
      interes: 'Departamento',
      ubicacion: 'Posadas',
      presupuesto: 'ARS 500.000',
      estado: ConsultaEstado.visitoPropiedad,
      fechaContacto: DateTime(2026, 3, 21),
      notas: 'Le gusto la zona, consulta por expensas.',
      creadoPor: 'Cliente',
      whatsapp: '+54 9 376 543-0990',
      direccion: 'Av. Jauretche, Posadas',
    ),
    Consulta(
      id: 'c9',
      publicacionId: 'v2',
      publicacionTitulo: 'Terreno Urbano en Posadas Sur',
      nombreCompleto: 'Eliana Martinez',
      telefono: '+54 9 376 401-1123',
      email: 'elianamartinez@gmail.com',
      tipoOperacion: 'Venta',
      interes: 'Terreno',
      ubicacion: 'Posadas',
      presupuesto: 'USD 10.000',
      estado: ConsultaEstado.nueva,
      fechaContacto: DateTime(2026, 3, 29),
      notas: 'Tiene lote para permuta parcial.',
      creadoPor: 'Visitante',
      whatsapp: '+54 9 376 401-1123',
      direccion: 'Villa Cabello, Posadas',
    ),
    Consulta(
      id: 'c10',
      publicacionId: 'v1',
      publicacionTitulo: 'Terreno Residencial en Candelaria',
      nombreCompleto: 'Diego Ruiz',
      telefono: '+54 9 376 389-7760',
      email: 'druiz@empresa.com',
      tipoOperacion: 'Compra',
      interes: 'Casa',
      ubicacion: 'Candelaria',
      presupuesto: 'USD 15.000',
      estado: ConsultaEstado.seguimiento,
      fechaContacto: DateTime(2026, 3, 24),
      notas: 'Busca terreno para construir vivienda y oficina.',
      creadoPor: 'Sitios',
      whatsapp: '+54 9 376 389-7760',
      direccion: 'Km 10, Candelaria',
    ),
    Consulta(
      id: 'c11',
      publicacionId: 'a2',
      publicacionTitulo: 'Departamento 1 Dormitorio en Garupa',
      nombreCompleto: 'Paola Franco',
      telefono: '+54 9 376 410-3377',
      email: 'paola.franco@gmail.com',
      tipoOperacion: 'Alquiler',
      interes: 'Departamento',
      ubicacion: 'Garupa',
      presupuesto: 'ARS 260.000',
      estado: ConsultaEstado.cerrado,
      fechaContacto: DateTime(2026, 3, 15),
      notas: 'Contrato firmado por 24 meses.',
      creadoPor: 'Cliente',
      whatsapp: '+54 9 376 410-3377',
      direccion: 'Los Paraisos, Garupa',
    ),
    Consulta(
      id: 'c12',
      publicacionId: 'v4',
      publicacionTitulo: 'Terreno Familiar en Posadas Oeste',
      nombreCompleto: 'Luis Britez',
      telefono: '+54 9 376 462-0980',
      email: 'luis.britez@yahoo.com',
      tipoOperacion: 'Compra',
      interes: 'Terreno',
      ubicacion: 'Posadas',
      presupuesto: 'USD 6.200',
      estado: ConsultaEstado.nueva,
      fechaContacto: DateTime(2026, 4, 1),
      notas: 'Llego por recomendacion de un cliente.',
      creadoPor: 'Visitante',
      whatsapp: '+54 9 376 462-0980',
      direccion: 'Itaembe Guazu, Posadas',
    ),
    Consulta(
      id: 'c13',
      publicacionId: 'v3',
      publicacionTitulo: 'Terreno Esquinero en Garupa',
      nombreCompleto: 'Micaela Sosa',
      telefono: '+54 9 351 588-7700',
      email: 'mica.sosa@gmail.com',
      tipoOperacion: 'Compra',
      interes: 'Terreno',
      ubicacion: 'Garupa',
      presupuesto: 'USD 9.000',
      estado: ConsultaEstado.reserva,
      fechaContacto: DateTime(2026, 3, 20),
      notas: 'Seño en USD, resta escrituracion.',
      creadoPor: 'Sitios',
      whatsapp: '+54 9 351 588-7700',
      direccion: 'Belen, Garupa',
    ),
    Consulta(
      id: 'c14',
      publicacionId: 'a1',
      publicacionTitulo: 'Casa 2 Dormitorios en Posadas',
      nombreCompleto: 'Federico Nuñez',
      telefono: '+54 9 376 421-0011',
      email: 'federico.nunez@hotmail.com',
      tipoOperacion: 'Alquiler',
      interes: 'Casa',
      ubicacion: 'Posadas',
      presupuesto: 'ARS 380.000',
      estado: ConsultaEstado.seguimiento,
      fechaContacto: DateTime(2026, 3, 26),
      notas: 'Pidio video completo de la propiedad.',
      creadoPor: 'Cliente',
      whatsapp: '+54 9 376 421-0011',
      direccion: 'Chacra 32-33, Posadas',
    ),
    Consulta(
      id: 'c15',
      publicacionId: 'a3',
      publicacionTitulo: 'Casa en Candelaria con Jardin',
      nombreCompleto: 'Gisela Duarte',
      telefono: '+54 9 376 477-4433',
      email: 'gisela.duarte@gmail.com',
      tipoOperacion: 'Alquiler',
      interes: 'Casa',
      ubicacion: 'Candelaria',
      presupuesto: 'ARS 430.000',
      estado: ConsultaEstado.nueva,
      fechaContacto: DateTime(2026, 3, 31),
      notas: 'Consulta por mudanza con dos niños.',
      creadoPor: 'Visitante',
      whatsapp: '+54 9 376 477-4433',
      direccion: 'Ruta 12, Candelaria',
    ),
    Consulta(
      id: 'c16',
      publicacionId: 'v1',
      publicacionTitulo: 'Terreno Residencial en Candelaria',
      nombreCompleto: 'Pablo Diaz',
      telefono: '+54 9 376 433-5502',
      email: 'pdiaz@correo.com',
      tipoOperacion: 'Venta',
      interes: 'Terreno',
      ubicacion: 'Posadas',
      presupuesto: 'USD 11.500',
      estado: ConsultaEstado.visitoPropiedad,
      fechaContacto: DateTime(2026, 3, 23),
      notas: 'Quiere publicar su lote y comprar otro mas grande.',
      creadoPor: 'Sitios',
      whatsapp: '+54 9 376 433-5502',
      direccion: 'Av. Uruguay, Posadas',
    ),
    Consulta(
      id: 'c17',
      publicacionId: 'a4',
      publicacionTitulo: 'Duplex en Posadas Norte',
      nombreCompleto: 'Vanesa Silva',
      telefono: '+54 9 376 487-8890',
      email: 'vane.silva@gmail.com',
      tipoOperacion: 'Alquiler',
      interes: 'Departamento',
      ubicacion: 'Posadas',
      presupuesto: 'ARS 520.000',
      estado: ConsultaEstado.cerrado,
      fechaContacto: DateTime(2026, 3, 17),
      notas: 'Ingreso inmediato, contrato firmado.',
      creadoPor: 'Sitios',
      whatsapp: '+54 9 376 487-8890',
      direccion: 'Villa Urquiza, Posadas',
    ),
    Consulta(
      id: 'c18',
      publicacionId: 'v2',
      publicacionTitulo: 'Terreno Urbano en Posadas Sur',
      nombreCompleto: 'Hector Leiva',
      telefono: '+54 9 376 490-6005',
      email: 'hector.leiva@gmail.com',
      tipoOperacion: 'Compra',
      interes: 'Terreno',
      ubicacion: 'Obera',
      presupuesto: 'USD 13.000',
      estado: ConsultaEstado.seguimiento,
      fechaContacto: DateTime(2026, 3, 30),
      notas: 'Viaja desde Obera, coordinar visita sabado.',
      creadoPor: 'Visitante',
      whatsapp: '+54 9 376 490-6005',
      direccion: 'Barrio Norte, Obera',
    ),
  ];

  List<PropertyListing> fetchByType(ListingType type) {
    return _listings.where((PropertyListing item) => item.type == type).toList();
  }

  List<PropertyListing> fetchAll() {
    return List<PropertyListing>.from(_listings);
  }

  void trackView(String listingId) {
    final ListingMetrics current =
        _metricsByListing[listingId] ?? ListingMetrics(listingId: listingId, views: 0, contacts: 0);
    _metricsByListing[listingId] = ListingMetrics(
      listingId: listingId,
      views: current.views + 1,
      contacts: current.contacts,
    );
  }

  void trackContact(String listingId) {
    final ListingMetrics current =
        _metricsByListing[listingId] ?? ListingMetrics(listingId: listingId, views: 0, contacts: 0);
    _metricsByListing[listingId] = ListingMetrics(
      listingId: listingId,
      views: current.views,
      contacts: current.contacts + 1,
    );
  }

  List<ListingMetrics> fetchMetrics() {
    return _listings
        .map(
          (PropertyListing listing) =>
              _metricsByListing[listing.id] ?? ListingMetrics(listingId: listing.id, views: 0, contacts: 0),
        )
        .toList();
  }

  PropertyListing? findById(String id) {
    for (final PropertyListing listing in _listings) {
      if (listing.id == id) {
        return listing;
      }
    }
    return null;
  }

  void addListing(PropertyListing listing) {
    _listings.insert(0, listing);
  }

  void registrarConsulta(Consulta consulta) {
    _consultas.insert(0, consulta);
  }

  List<Consulta> fetchConsultas() {
    return List<Consulta>.from(_consultas);
  }

  List<Consulta> fetchConsultasByUser(String username) {
    return _consultas
        .where((Consulta consulta) => consulta.creadoPor.toLowerCase() == username.toLowerCase())
        .toList();
  }

  void actualizarEstadoConsulta({required String consultaId, required ConsultaEstado estado}) {
    final int index = _consultas.indexWhere((Consulta item) => item.id == consultaId);
    if (index == -1) {
      return;
    }
    _consultas[index] = _consultas[index].copyWith(estado: estado);
  }

  List<Consulta> buscarConsultas({
    String query = '',
    ConsultaEstado? estado,
    String? operacion,
    String? ubicacion,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();

    return _consultas.where((Consulta item) {
      final bool matchEstado = estado == null || item.estado == estado;
      final bool matchOperacion = operacion == null || operacion.isEmpty || item.tipoOperacion == operacion;
      final bool matchUbicacion = ubicacion == null || ubicacion.isEmpty || item.ubicacion == ubicacion;
      final bool matchQuery =
          normalizedQuery.isEmpty ||
          item.nombreCompleto.toLowerCase().contains(normalizedQuery) ||
          item.telefono.toLowerCase().contains(normalizedQuery);

      return matchEstado && matchOperacion && matchUbicacion && matchQuery;
    }).toList();
  }
}
