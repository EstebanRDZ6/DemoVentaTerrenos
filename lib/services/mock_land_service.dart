import '../models/land_plot.dart';

class MockLandService {
  const MockLandService();

  static const List<String> locations = <String>[
    'Posadas',
    'Garupa',
    'Candelaria',
  ];

  List<LandPlot> fetchLands() {
    return const <LandPlot>[
      LandPlot(
        id: '1',
        name: 'Terreno Residencial en Candelaria',
        priceUsd: 5200,
        location: 'Candelaria',
        areaM2: 360,
        description:
            'Lote ideal para vivienda familiar, en zona en crecimiento y con acceso rapido a ruta principal.',
        images: <String>[
          'https://picsum.photos/seed/candelaria1/900/600',
          'https://picsum.photos/seed/candelaria2/900/600',
          'https://picsum.photos/seed/candelaria3/900/600',
        ],
      ),
      LandPlot(
        id: '2',
        name: 'Terreno en Posadas Centro',
        priceUsd: 6800,
        location: 'Posadas',
        areaM2: 280,
        description:
            'Excelente oportunidad para inversion, a minutos de comercios y servicios urbanos.',
        images: <String>[
          'https://picsum.photos/seed/posadas1/900/600',
          'https://picsum.photos/seed/posadas2/900/600',
          'https://picsum.photos/seed/posadas3/900/600',
        ],
      ),
      LandPlot(
        id: '3',
        name: 'Terreno Esquinero en Garupa',
        priceUsd: 4900,
        location: 'Garupa',
        areaM2: 400,
        description:
            'Lote amplio con excelente orientacion, ideal para casa con jardin o proyecto comercial.',
        images: <String>[
          'https://picsum.photos/seed/garupa1/900/600',
          'https://picsum.photos/seed/garupa2/900/600',
          'https://picsum.photos/seed/garupa3/900/600',
        ],
      ),
      LandPlot(
        id: '4',
        name: 'Terreno con Vista Abierta en Candelaria',
        priceUsd: 5600,
        location: 'Candelaria',
        areaM2: 350,
        description:
            'Zona tranquila, entorno natural y facil acceso. Ideal para primera vivienda.',
        images: <String>[
          'https://picsum.photos/seed/candelaria4/900/600',
          'https://picsum.photos/seed/candelaria5/900/600',
          'https://picsum.photos/seed/candelaria6/900/600',
        ],
      ),
      LandPlot(
        id: '5',
        name: 'Terreno Familiar en Posadas Oeste',
        priceUsd: 6100,
        location: 'Posadas',
        areaM2: 320,
        description:
            'Lote nivelado y listo para construir, con buena conectividad y servicios cercanos.',
        images: <String>[
          'https://picsum.photos/seed/posadas4/900/600',
          'https://picsum.photos/seed/posadas5/900/600',
          'https://picsum.photos/seed/posadas6/900/600',
        ],
      ),
      LandPlot(
        id: '6',
        name: 'Terreno de Inversion en Garupa',
        priceUsd: 5000,
        location: 'Garupa',
        areaM2: 370,
        description:
            'Ubicado en barrio en expansion con alta proyeccion de valorizacion a mediano plazo.',
        images: <String>[
          'https://picsum.photos/seed/garupa4/900/600',
          'https://picsum.photos/seed/garupa5/900/600',
          'https://picsum.photos/seed/garupa6/900/600',
        ],
      ),
      LandPlot(
        id: '7',
        name: 'Terreno Amplio en Candelaria Norte',
        priceUsd: 5400,
        location: 'Candelaria',
        areaM2: 430,
        description:
            'Ideal para proyecto de vivienda con quincho y espacio verde, calle consolidada.',
        images: <String>[
          'https://picsum.photos/seed/candelaria7/900/600',
          'https://picsum.photos/seed/candelaria8/900/600',
          'https://picsum.photos/seed/candelaria9/900/600',
        ],
      ),
      LandPlot(
        id: '8',
        name: 'Terreno Urbano en Posadas Sur',
        priceUsd: 5900,
        location: 'Posadas',
        areaM2: 300,
        description:
            'Opcion ideal para quienes buscan cercania con la ciudad y un entorno residencial.',
        images: <String>[
          'https://picsum.photos/seed/posadas7/900/600',
          'https://picsum.photos/seed/posadas8/900/600',
          'https://picsum.photos/seed/posadas9/900/600',
        ],
      ),
    ];
  }
}