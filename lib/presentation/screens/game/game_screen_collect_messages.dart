import '../../../domain/map/cell_content_type.dart';

String titleFor(CellContentType content) => switch (content) {
      CellContentType.resourceBonus => 'Trésor collecté !',
      CellContentType.ruins => 'Ruines fouillées !',
      _ => 'Collecte',
    };

String emptyMessageFor(CellContentType content) => switch (content) {
      CellContentType.ruins => 'Les ruines étaient vides...',
      _ => 'Rien à récupérer ici...',
    };
