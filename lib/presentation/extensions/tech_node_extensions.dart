import '../../domain/tech/tech_branch.dart';
import '../../domain/tech/tech_option.dart';

/// Name, effect and icon of every node of the research reef. A node is a
/// branch [level], plus the [TechOption] on a choice level (2 and 4).
extension TechNodeInfo on TechBranch {
  String nodeName(int level, [TechOption? option]) =>
      _info(level, option).$1;

  String nodeEffect(int level, [TechOption? option]) =>
      _info(level, option).$2;

  String nodeIconPath(int level, [TechOption? option]) =>
      'assets/icons/tech/${name}_$level${option?.name ?? ''}.svg';

  (String, String) _info(int level, TechOption? option) =>
      _nodes[this]!['$level${option?.name ?? ''}'] ?? ('', '');
}

const _tier = '+20 % ATK et DEF';
const _prod = '+20 % de production';

const Map<TechBranch, Map<String, (String, String)>> _nodes = {
  TechBranch.military: {
    '1': ('Trident aiguisé', _tier),
    '2a': ('Lames de corail', '+35 % ATK'),
    '2b': ('Carapace de nacre', '+35 % PV'),
    '3': ('Discipline des abysses', _tier),
    '4a': ('Rempart vivant', '+35 % DEF en défense de la base'),
    '4b': ('Assaut des profondeurs',
        '+35 % ATK contre repaires, bases et Noyau'),
    '5': ('Légion abyssale', _tier),
  },
  TechBranch.resources: {
    '1': ('Bancs fertiles', _prod),
    '2a': ('Culture intensive', "+35 % d'algues et de corail"),
    '2b': ('Forage profond', "+35 % de minerai et d'énergie"),
    '3': ('Courants nourriciers', _prod),
    '4a': ('Coffres scellés', 'Un raid perdu pille 15 % au lieu de 30 %'),
    '4b': ('Chantiers économes', 'Améliorations 15 % moins chères'),
    '5': ('Abondance des grands fonds', _prod),
  },
  TechBranch.explorer: {
    '1': ('Lanterne bioluminescente', 'Zone explorée 5×5'),
    '2a': ('Sonar profond', 'Zone explorée agrandie de 2'),
    '2b': ('Nage silencieuse', 'Explorer et combattre ne font plus de bruit'),
    '3': ('Cartographie des courants', 'Zone explorée 7×7'),
    '4a': ("Pillards d'épaves",
        '+50 % de butin (repaires, trésors, raids repoussés)'),
    '4b': ('Sentinelles', "Raids annoncés 4 tours à l'avance au lieu de 2"),
    '5': ("Œil de l'abysse", 'Zone explorée 9×9'),
  },
};
