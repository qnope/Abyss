// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get newGameTitle => 'Nueva partida';

  @override
  String get newGameEnterName => 'Escribe tu nombre';

  @override
  String get newGameNameHint => 'Nombre del jugador';

  @override
  String get newGameNameEmpty => 'Escribe un nombre';

  @override
  String newGameNameTooShort(int min) {
    return 'El nombre debe tener al menos $min caracteres';
  }

  @override
  String get newGameTutorial => 'Tutorial';

  @override
  String get newGameTutorialHint =>
      'Una guía te acompaña en los primeros turnos';

  @override
  String get newGameStart => 'Empezar';

  @override
  String get difficultyTitle => 'Dificultad';

  @override
  String get buildingHeadquartersName => 'Cuartel General';

  @override
  String buildingHeadquartersDescription(int coral, int ore) {
    return 'Centro de mando de tu base submarina. Su nivel determina las capacidades de tu colonia. Una vez construido, aporta $coral de coral y $ore de mineral por turno.';
  }

  @override
  String get buildingAlgaeFarmName => 'Granja de algas';

  @override
  String get buildingAlgaeFarmDescription =>
      'Cultiva algas para alimentar a tu colonia submarina.';

  @override
  String get buildingCoralMineName => 'Mina de coral';

  @override
  String get buildingCoralMineDescription =>
      'Extrae coral de los arrecifes para la construcción.';

  @override
  String get buildingCoralCitadelName => 'Ciudadela de coral';

  @override
  String get buildingCoralCitadelDescription =>
      'Fortaleza de coral maciza que levanta una muralla para defender tu base. Durante una incursión, recibe los golpes en lugar de las unidades apostadas.';

  @override
  String get buildingOreExtractorName => 'Extractor de mineral';

  @override
  String get buildingOreExtractorDescription =>
      'Perfora las profundidades para extraer mineral oceánico.';

  @override
  String get buildingSolarPanelName => 'Panel solar';

  @override
  String get buildingSolarPanelDescription =>
      'Capta la energía solar para alimentar tus instalaciones.';

  @override
  String get buildingLaboratoryName => 'Laboratorio';

  @override
  String get buildingLaboratoryDescription =>
      'Centro de investigación submarino para desarrollar nuevas tecnologías.';

  @override
  String get buildingBarracksName => 'Cuartel';

  @override
  String get buildingBarracksDescription =>
      'Forma y entrena a tus unidades militares submarinas.';

  @override
  String get buildingDescentModuleName => 'Módulo de Descenso';

  @override
  String get buildingDescentModuleDescription =>
      'Módulo especializado para asaltar las fallas abisales.';

  @override
  String get buildingPressureCapsuleName => 'Cápsula Presurizada';

  @override
  String get buildingPressureCapsuleDescription =>
      'Cápsula de alta presión para asaltar las chimeneas hidrotermales.';

  @override
  String get buildingVolcanicKernelName => 'Núcleo Volcánico';

  @override
  String get buildingVolcanicKernelDescription =>
      'El corazón ardiente del abismo. Constrúyelo hasta el nivel 10 para lograr la victoria. Su guarnición se gestiona aquí, o desde su casilla en el mapa.';

  @override
  String get unitScoutName => 'Explorador';

  @override
  String get unitScoutRole => 'Explorador';

  @override
  String get unitScoutRoleEffect =>
      'Huye en lugar de morir: siempre vuelve herido.';

  @override
  String get unitHarpoonistName => 'Arponero';

  @override
  String get unitHarpoonistRole => 'DPS';

  @override
  String get unitHarpoonistRoleEffect => 'Daño constante, sin regla especial.';

  @override
  String get unitGuardianName => 'Guardián';

  @override
  String get unitGuardianRole => 'Tanque';

  @override
  String get unitGuardianRoleEffect =>
      'Provoca: los monstruos lo atacan primero.';

  @override
  String get unitDomeBreakerName => 'Rompedor';

  @override
  String get unitDomeBreakerRole => 'Asedio';

  @override
  String get unitDomeBreakerRoleEffect =>
      'Inflige el doble de daño a los jefes.';

  @override
  String get unitAbyssAdmiralName => 'Almirante del Abismo';

  @override
  String get unitAbyssAdmiralRole => 'Almirante';

  @override
  String get unitAbyssAdmiralRoleEffect => 'Dirige los asaltos sin combatir.';

  @override
  String get unitSaboteurName => 'Saboteador';

  @override
  String get unitSaboteurRole => 'Cañón de cristal';

  @override
  String get unitSaboteurRoleEffect => 'Ignora la defensa de su objetivo.';

  @override
  String unitScoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exploradores',
      one: '$count explorador',
    );
    return '$_temp0';
  }

  @override
  String unitHarpoonistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arponeros',
      one: '$count arponero',
    );
    return '$_temp0';
  }

  @override
  String unitGuardianCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guardianes',
      one: '$count guardián',
    );
    return '$_temp0';
  }

  @override
  String unitDomeBreakerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rompedores',
      one: '$count rompedor',
    );
    return '$_temp0';
  }

  @override
  String unitAbyssAdmiralCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count almirantes del abismo',
      one: '$count almirante del abismo',
    );
    return '$_temp0';
  }

  @override
  String unitSaboteurCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saboteadores',
      one: '$count saboteador',
    );
    return '$_temp0';
  }

  @override
  String get resourceAlgaeName => 'Algas';

  @override
  String get resourceAlgaeFlavor =>
      'Alimento cultivado en las granjas submarinas para alimentar a tus unidades.';

  @override
  String get resourceCoralName => 'Coral';

  @override
  String get resourceCoralFlavor =>
      'Material de construcción recogido en los arrecifes para levantar tu base.';

  @override
  String get resourceOreName => 'Mineral';

  @override
  String get resourceOreFlavor =>
      'Metal extraído de las profundidades para forjar equipo avanzado.';

  @override
  String get resourceEnergyName => 'Energía';

  @override
  String get resourceEnergyFlavor =>
      'Energía captada para alimentar tus edificios y máquinas.';

  @override
  String get resourcePearlName => 'Perlas';

  @override
  String get resourcePearlFlavor =>
      'Gemas raras halladas en ruinas y guaridas, y recogidas cada turno en las fallas y chimeneas capturadas.';

  @override
  String get monsterFamilyGenericLabel => 'Merodeadores';

  @override
  String get monsterFamilySwarmLabel => 'Enjambre';

  @override
  String get monsterFamilyArmouredLabel => 'Caparazones';

  @override
  String get monsterFamilyHunterLabel => 'Cazadores';

  @override
  String get monsterFamilyColossusLabel => 'Colosos';

  @override
  String get monsterFamilyKrakenLabel => 'Kraken';

  @override
  String monsterFamilyGenericCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monstruos',
      one: '$count monstruo',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilySwarmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dientes de vidrio',
      one: '$count Diente de vidrio',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyArmouredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Isópodos acorazados',
      one: '$count Isópodo acorazado',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyHunterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Calamares cazadores',
      one: '$count Calamar cazador',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyColossusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tiburones dormilones',
      one: '$count Tiburón dormilón',
    );
    return '$_temp0';
  }

  @override
  String monsterFamilyKrakenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Krakens',
      one: '$count Kraken',
    );
    return '$_temp0';
  }

  @override
  String get monsterFamilySwarmRule =>
      'Enjambre: un golpe de Arponero alcanza a dos peces.';

  @override
  String get monsterFamilyArmouredRule =>
      'Coraza: solo los Saboteadores ignoran su DEF.';

  @override
  String get monsterFamilyHunterRule =>
      'Acecho: van a por la unidad más frágil y golpean el doble de fuerte, salvo si un Guardián o la muralla los provoca.';

  @override
  String get monsterFamilyColossusRule =>
      'Gigantes: todos son jefes, y los Rompedores les golpean el doble.';

  @override
  String get monsterFamilyKrakenRule =>
      'Abrazo: cada golpe de tentáculo alcanza también a un segundo defensor. Son jefes, y los Rompedores les golpean el doble.';

  @override
  String get monsterFamilySwarmWeakness => 'Arponeros';

  @override
  String get monsterFamilyArmouredWeakness => 'Saboteadores';

  @override
  String get monsterFamilyHunterWeakness => 'Guardianes';

  @override
  String get monsterFamilyColossusWeakness => 'Rompedores de cúpulas';

  @override
  String monsterLairGroupsAnd(String first, String second) {
    return '$first y $second';
  }

  @override
  String monsterLairWave(String monsters, int level) {
    return '$monsters niv. $level';
  }

  @override
  String monsterLairWeakAgainst(String units) {
    return 'Débiles contra: $units';
  }

  @override
  String get monsterDifficultyEasy => 'Fácil';

  @override
  String get monsterDifficultyMedium => 'Medio';

  @override
  String get monsterDifficultyHard => 'Difícil';

  @override
  String get randomEventWarmCurrentLabel => 'Corriente cálida';

  @override
  String get randomEventWreckLabel => 'Pecio';

  @override
  String get randomEventPredatorsLabel => 'Banco de depredadores';

  @override
  String get randomEventStormLabel => 'Tormenta';

  @override
  String get randomEventSurvivorsLabel => 'Supervivientes';

  @override
  String get randomEventCaravanLabel => 'Caravana de tortugas';

  @override
  String get randomEventColdCurrentLabel => 'Corriente fría';

  @override
  String eventCountdown(String label, int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'quedan $turns turnos',
      one: 'queda $turns turno',
    );
    return '$label: $_temp0';
  }

  @override
  String eventColdCurrentHeated(String label) {
    return '$label (invernaderos caldeados)';
  }

  @override
  String get techBranchMilitaryName => 'Militar';

  @override
  String get techBranchMilitaryDescription =>
      'Mejora el ataque y la defensa de todas las unidades.';

  @override
  String get techBranchResourcesName => 'Recursos';

  @override
  String get techBranchResourcesDescription =>
      'Mejora la producción de todos los recursos.';

  @override
  String get techBranchExplorerName => 'Exploración';

  @override
  String get techBranchExplorerDescription =>
      'Mejora el alcance de exploración del mapa.';

  @override
  String get techTierEffect => '+20 % ATK y DEF';

  @override
  String get techProductionEffect => '+20 % de producción';

  @override
  String techExploredAreaEffect(int size) {
    return 'Zona explorada $size×$size';
  }

  @override
  String get techMilitary1Name => 'Tridente afilado';

  @override
  String get techMilitary2aName => 'Hojas de coral';

  @override
  String get techMilitary2aEffect => '+35 % ATK';

  @override
  String get techMilitary2bName => 'Caparazón de nácar';

  @override
  String get techMilitary2bEffect => '+35 % PV';

  @override
  String get techMilitary3Name => 'Disciplina abisal';

  @override
  String get techMilitary4aName => 'Muralla viviente';

  @override
  String get techMilitary4aEffect => '+35 % DEF al defender la base';

  @override
  String get techMilitary4bName => 'Asalto de las profundidades';

  @override
  String get techMilitary4bEffect =>
      '+35 % ATK contra guaridas, bases y el Núcleo';

  @override
  String get techMilitary5Name => 'Legión abisal';

  @override
  String get techResources1Name => 'Bancos fértiles';

  @override
  String get techResources2aName => 'Cultivo intensivo';

  @override
  String get techResources2aEffect => '+35 % de algas y coral';

  @override
  String get techResources2bName => 'Perforación profunda';

  @override
  String get techResources2bEffect => '+35 % de mineral y energía';

  @override
  String get techResources3Name => 'Corrientes nutritivas';

  @override
  String get techResources4aName => 'Cofres sellados';

  @override
  String get techResources4aEffect =>
      'Una incursión perdida saquea el 15 % en lugar del 30 %';

  @override
  String get techResources4bName => 'Obras ahorradoras';

  @override
  String get techResources4bEffect => 'Mejoras un 15 % más baratas';

  @override
  String get techResources5Name => 'Abundancia de las profundidades';

  @override
  String get techExplorer1Name => 'Linterna bioluminiscente';

  @override
  String get techExplorer2aName => 'Sonar profundo';

  @override
  String get techExplorer2aEffect => 'Zona explorada 2 más amplia';

  @override
  String get techExplorer2bName => 'Nado silencioso';

  @override
  String get techExplorer2bEffect => 'Explorar y combatir ya no hacen ruido';

  @override
  String get techExplorer3Name => 'Cartografía de corrientes';

  @override
  String get techExplorer4aName => 'Saqueadores de pecios';

  @override
  String get techExplorer4aEffect =>
      '+50 % de botín (guaridas, tesoros, incursiones repelidas)';

  @override
  String get techExplorer4bName => 'Centinelas';

  @override
  String get techExplorer4bEffect =>
      'Incursiones anunciadas con 4 turnos de antelación en lugar de 2';

  @override
  String get techExplorer5Name => 'Ojo del abismo';

  @override
  String get terrainPlain => 'Llanura';

  @override
  String get cellContentEmpty => 'Vacío';

  @override
  String get cellContentResourceBonus => 'Recursos';

  @override
  String get cellContentRuins => 'Ruinas';

  @override
  String get cellContentMonsterLair => 'Guarida';

  @override
  String get cellContentPassage => 'Paso';

  @override
  String get transitionBaseFailleName => 'Falla abisal';

  @override
  String get transitionBaseFailleDescription => 'Paso hacia las profundidades';

  @override
  String get transitionBaseChemineeName => 'Chimenea del Núcleo';

  @override
  String get transitionBaseChemineeDescription => 'Paso hacia el núcleo';

  @override
  String get difficultyEasyName => 'Fácil';

  @override
  String get difficultyEasyDescription => 'Más recursos, menos monstruos.';

  @override
  String get difficultyNormalName => 'Normal';

  @override
  String get difficultyNormalDescription =>
      'El equilibrio pensado para el abismo.';

  @override
  String get difficultyHardName => 'Difícil';

  @override
  String get difficultyHardDescription => 'Menos recursos, más monstruos.';

  @override
  String get temporaryObjectiveWreckShort => 'Pecio';

  @override
  String get temporaryObjectivePredatorsShort => 'Depredadores';

  @override
  String temporaryObjectiveWreckTitle(int turn) {
    return 'Registra el pecio antes del final del turno $turn';
  }

  @override
  String get temporaryObjectivePredatorsTitle =>
      'Repele el banco de depredadores';

  @override
  String get historyCategoryCombat => 'Combate';

  @override
  String get historyCategoryBuilding => 'Construcción';

  @override
  String get historyCategoryResearch => 'Investigación';

  @override
  String get historyCategoryRecruit => 'Reclutamiento';

  @override
  String get historyCategoryExplore => 'Exploración';

  @override
  String get historyCategoryCollect => 'Recolección';

  @override
  String get historyCategoryTurnEnd => 'Fin de turno';

  @override
  String get historyCategoryCapture => 'Captura';

  @override
  String get historyCategoryDescent => 'Descenso';

  @override
  String get historyCategoryReinforcement => 'Refuerzos';

  @override
  String get historyCategoryRaid => 'Incursión';

  @override
  String get historyCategoryVolcano => 'Volcán';

  @override
  String get historyCategoryEvent => 'Evento';

  @override
  String get actionFailureUnknown => 'Acción imposible';

  @override
  String get actionFailureMapNotGenerated => 'Mapa no generado';

  @override
  String get actionFailureCellNotRevealed => 'Casilla no revelada';

  @override
  String get actionFailureCellNotEligible => 'Casilla no elegible';

  @override
  String get actionFailureAlreadyCollected => 'Ya recogido';

  @override
  String get actionFailureNothingToCollect => 'Nada que recoger';

  @override
  String get actionFailureStormBlocksExploration =>
      'Tormenta: exploración imposible';

  @override
  String get actionFailureNoScoutAvailable => 'Ningún explorador disponible';

  @override
  String get actionFailureNoMonsterHere => 'No hay ningún monstruo aquí';

  @override
  String get actionFailureLairAlreadyDefeated => 'Guarida ya derrotada';

  @override
  String get actionFailureLairEmpty => 'Guarida vacía';

  @override
  String get actionFailureNotEnoughUnits => 'Unidades insuficientes';

  @override
  String get actionFailureNoUnitSelected => 'Ninguna unidad seleccionada';

  @override
  String get actionFailureAdmiralRequired =>
      'Se necesita un Almirante del Abismo';

  @override
  String get actionFailureNoTransitionBaseHere =>
      'No hay ninguna base de transición aquí';

  @override
  String get actionFailureBaseNotFound => 'Base no encontrada';

  @override
  String get actionFailureBaseAlreadyCaptured => 'Base ya capturada';

  @override
  String get actionFailureBaseNotCaptured => 'Base no capturada';

  @override
  String get actionFailureTargetLevelNotExplored =>
      'Nivel de destino no explorado';

  @override
  String get actionFailureRequiredBuildingMissing =>
      'Falta el edificio necesario';

  @override
  String get actionFailureNoVolcanicKernelHere =>
      'No hay ningún Núcleo Volcánico aquí';

  @override
  String get actionFailureKernelAlreadyCaptured => 'Núcleo ya capturado';

  @override
  String get actionFailureKernelNotCaptured => 'Núcleo no capturado';

  @override
  String get actionFailureNoPendingEvent => 'Ningún evento pendiente';

  @override
  String get actionFailureNotThisChoiceTurn =>
      'Esta elección corresponde a otro turno';

  @override
  String get actionFailureNotEnoughStockToTrade =>
      'Reservas insuficientes para comerciar';

  @override
  String get actionFailureBranchNotFound => 'Rama no encontrada';

  @override
  String get actionFailureBranchLocked => 'Rama bloqueada';

  @override
  String get actionFailureBranchAlreadyUnlocked => 'Rama ya desbloqueada';

  @override
  String get actionFailureLaboratoryRequired => 'Se necesita un Laboratorio';

  @override
  String get actionFailureLaboratoryLevelTooLow =>
      'Nivel de laboratorio insuficiente';

  @override
  String get actionFailureResearchAlreadyStarted =>
      'Investigación ya iniciada este turno';

  @override
  String get actionFailureBuildingNotFound => 'Edificio no encontrado';

  @override
  String get actionFailureWorksitesBusy => 'Obras ocupadas este turno';

  @override
  String get actionFailureMaxLevelReached => 'Nivel máximo alcanzado';

  @override
  String get actionFailureNotEnoughResources => 'Recursos insuficientes';

  @override
  String get actionFailureUnitLocked => 'Unidad bloqueada';

  @override
  String get actionFailureRecruitmentAlreadyDone => 'Ya se reclutó este turno';

  @override
  String get actionFailureInvalidQuantity => 'Cantidad no válida';

  @override
  String get actionFailureGameOver => 'Partida terminada';

  @override
  String historyBuildingTitle(String building, int level) {
    return '$building niv. $level';
  }

  @override
  String historyResearchUnlocked(String branch) {
    return '$branch desbloqueada';
  }

  @override
  String historyResearchLevel(String branch, int level) {
    return '$branch niv. $level';
  }

  @override
  String historyResearchImproved(String branch) {
    return '$branch mejorada';
  }

  @override
  String historyRecruitTitle(int count, String units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$units reclutados',
      one: '$units reclutado',
    );
    return '$_temp0';
  }

  @override
  String historyExploreTitle(int x, int y) {
    return 'Exploración ($x, $y)';
  }

  @override
  String historyCollectTitle(int x, int y) {
    return 'Tesoro recogido ($x, $y)';
  }

  @override
  String historyCombatVictory(int level) {
    return 'Victoria contra Guarida niv. $level';
  }

  @override
  String historyCombatDefeat(int level) {
    return 'Derrota contra Guarida niv. $level';
  }

  @override
  String historyTurnEndTitle(int turn) {
    return 'Turno $turn terminado';
  }

  @override
  String historyCaptureTitle(String name) {
    return 'Captura: $name';
  }

  @override
  String historyCaptureVictory(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'Victoria en $turns turnos',
      one: 'Victoria en $turns turno',
    );
    return '$_temp0';
  }

  @override
  String historyDescentTitle(int level) {
    return 'Descenso al Nivel $level';
  }

  @override
  String historyDescentUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unidades enviadas',
      one: '$count unidad enviada',
    );
    return '$_temp0';
  }

  @override
  String historyReinforcementTitle(int level) {
    return 'Refuerzos hacia el Nivel $level';
  }

  @override
  String historyReinforcementUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unidades en tránsito',
      one: '$count unidad en tránsito',
    );
    return '$_temp0';
  }

  @override
  String get historyRaidRepelled => 'Incursión repelida';

  @override
  String get historyRaidLost => 'Base saqueada por una incursión';

  @override
  String get historyPredatorsRepelled => 'Banco de depredadores repelido';

  @override
  String get historyPredatorsLost =>
      'Base saqueada por un banco de depredadores';

  @override
  String get historyVolcanoRepelled => 'Oleada repelida en el Núcleo';

  @override
  String get historyVolcanoLost => 'El Núcleo perdió un nivel';

  @override
  String get historyEventAccepted => 'Aceptado';

  @override
  String get historyEventRefused => 'Rechazado';

  @override
  String get historyEventDefaulted => 'Opción prudente, sin elección';
}
