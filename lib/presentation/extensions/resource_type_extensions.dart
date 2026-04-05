import 'package:flutter/material.dart';
import '../../domain/resource/resource_type.dart';
import '../theme/abyss_colors.dart';

extension ResourceTypeColor on ResourceType {
  Color get color => switch (this) {
    ResourceType.algae => AbyssColors.algaeGreen,
    ResourceType.coral => AbyssColors.coralPink,
    ResourceType.ore => AbyssColors.oreBlue,
    ResourceType.energy => AbyssColors.energyYellow,
    ResourceType.pearl => AbyssColors.pearlWhite,
  };
}

extension ResourceTypeInfo on ResourceType {
  String get displayName => switch (this) {
    ResourceType.algae => 'Algues',
    ResourceType.coral => 'Corail',
    ResourceType.ore => 'Minerai',
    ResourceType.energy => 'Énergie',
    ResourceType.pearl => 'Perles',
  };

  String get flavorText => switch (this) {
    ResourceType.algae => 'Nourriture cultivée dans les fermes sous-marines pour nourrir vos unités.',
    ResourceType.coral => 'Matériau de construction récolté sur les récifs pour bâtir votre base.',
    ResourceType.ore => 'Métal extrait des profondeurs pour forger des équipements avancés.',
    ResourceType.energy => 'Énergie captée pour alimenter vos bâtiments et machines.',
    ResourceType.pearl => 'Gemmes rares découvertes lors d\'explorations, essentielles aux technologies avancées.',
  };
}
