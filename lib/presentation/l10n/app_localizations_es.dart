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
  String get buildingBarracksName => 'Barracones';

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

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonOk => 'OK';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonGotIt => 'Entendido';

  @override
  String get commonSend => 'Enviar';

  @override
  String get commonBackToBase => 'Volver a la base';

  @override
  String get commonBackToMap => 'Volver al mapa';

  @override
  String commonTurn(int turn) {
    return 'Turno $turn';
  }

  @override
  String get statHp => 'PV';

  @override
  String get statAttack => 'ATK';

  @override
  String get statDefense => 'DEF';

  @override
  String get fightVictory => 'VICTORIA';

  @override
  String get fightDefeat => 'DERROTA';

  @override
  String get fightKernelCaptured => 'NÚCLEO CAPTURADO';

  @override
  String get fightBaseCaptured => 'BASE CAPTURADA';

  @override
  String fightTurnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Combate en $count turnos',
      one: 'Combate en $count turno',
    );
    return '$_temp0';
  }

  @override
  String get fightYourUnits => 'Tus unidades';

  @override
  String fightUnitAccounting(int sent, int intact, int wounded, int dead) {
    return 'Enviadas: $sent / Intactas: $intact / Heridas: $wounded / Muertas: $dead';
  }

  @override
  String fightEnemiesKilled(int killed, int total) {
    return 'Enemigos abatidos: $killed/$total';
  }

  @override
  String fightGuardiansKilled(int killed, int total) {
    return 'Guardianes eliminados: $killed/$total';
  }

  @override
  String get fightLoot => 'Botín';

  @override
  String get fightNoLoot => 'Sin botín';

  @override
  String fightTitle(int x, int y) {
    return 'Combate ($x, $y)';
  }

  @override
  String fightAssaultTitle(int x, int y) {
    return 'Asalto ($x, $y)';
  }

  @override
  String fightAssaultOn(String target) {
    return 'Asalto: $target';
  }

  @override
  String get fightPrepare => 'Preparar el combate';

  @override
  String get fightLaunch => 'Iniciar el combate';

  @override
  String get fightLaunchAssault => 'Lanzar el asalto';

  @override
  String get fightAdmiralRequired =>
      'Se necesita un Almirante del Abismo para lanzar el asalto';

  @override
  String fightStock(int count) {
    return 'Reserva: $count';
  }

  @override
  String fightAlliesAlive(int count) {
    return 'Aliados vivos: $count';
  }

  @override
  String fightAlliesHp(int hp) {
    return 'PV aliados: $hp';
  }

  @override
  String fightDamageDealt(int damage) {
    return 'Daño infligido: $damage';
  }

  @override
  String fightEnemiesAlive(int count) {
    return 'Enemigos vivos: $count';
  }

  @override
  String fightEnemiesHp(int hp) {
    return 'PV enemigos: $hp';
  }

  @override
  String fightDamageTaken(int damage) {
    return 'Daño recibido: $damage';
  }

  @override
  String fightCriticalHits(int count) {
    return 'Golpes críticos: $count';
  }

  @override
  String fightMilitaryBonus(String bonuses) {
    return 'Bonificación militar: $bonuses';
  }

  @override
  String get fightMilitaryBonusNone => 'Bonificación militar: ninguna';

  @override
  String fightLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String fightWeakAgainst(String unit) {
    return 'Débil contra: $unit';
  }

  @override
  String get mapLevelSurface => 'Superficie';

  @override
  String get mapLevelDepths => 'Profundidades';

  @override
  String get mapLevelCore => 'Núcleo';

  @override
  String mapLevelChip(int level, String name) {
    return 'Niv $level: $name';
  }

  @override
  String get mapDifficulty => 'Dificultad';

  @override
  String get mapLevel => 'Nivel';

  @override
  String get mapUnits => 'Unidades';

  @override
  String get mapIncomeOnceCaptured => 'Ingresos una vez capturada';

  @override
  String mapPearlsPerTurn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count perlas por turno',
      one: '+$count perla por turno',
    );
    return '$_temp0';
  }

  @override
  String get mapGuardedNeutral => 'Neutral — Guardianes presentes';

  @override
  String get mapAssault => 'Asalto';

  @override
  String get mapCaptured => 'Capturada';

  @override
  String mapUnitsOnLevel(int count, int level) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unidades en el Nivel $level',
      one: '$count unidad en el Nivel $level',
    );
    return '$_temp0';
  }

  @override
  String mapBuildingRequired(String building) {
    return 'Edificio necesario para enviar unidades: $building';
  }

  @override
  String mapSendUnitsToLevel(int level) {
    return 'Enviar unidades al Nivel $level';
  }

  @override
  String mapExploreTitle(int x, int y) {
    return 'Explorar ($x, $y)';
  }

  @override
  String get mapCost => 'Coste';

  @override
  String get mapScoutsAvailable => 'Exploradores disponibles';

  @override
  String get mapRevealedArea => 'Zona revelada';

  @override
  String mapAreaCells(int side) {
    return '$side×$side casillas';
  }

  @override
  String get mapKernelUncaptured =>
      'El corazón ardiente del abismo está custodiado por poderosos guardianes.';

  @override
  String get mapKernelCaptured =>
      'Has capturado el Núcleo Volcánico. Súbelo al nivel 10 para ganar. Desde el nivel 1, el Kraken viene a recuperarlo cada turno: cada oleada que gana le quita un nivel.';

  @override
  String mapTreasureTitle(int x, int y) {
    return 'Tesoro ($x, $y)';
  }

  @override
  String get mapCollectTreasure => 'Recoger el tesoro';

  @override
  String get mapTreasureResourceBonus => 'Algas, coral y mineral';

  @override
  String get mapTreasureRuins => 'Coral, mineral y perlas';

  @override
  String get mapTreasureWreck => 'Coral, mineral y una perla';

  @override
  String get raidName => 'Incursión';

  @override
  String get raidPillage => 'Saqueo';

  @override
  String get raidNothingToLoot => 'Nada que saquear';

  @override
  String raidPredatorsTitle(int turn) {
    return 'Banco de depredadores (turno $turn)';
  }

  @override
  String raidTitle(int turn) {
    return 'Incursión en la base (turno $turn)';
  }

  @override
  String raidRampart(int level) {
    return 'Muralla de la Ciudadela niv. $level';
  }

  @override
  String get raidNoise => 'Ruido';

  @override
  String raidLostInARow(int lost, int limit) {
    return 'Incursiones perdidas seguidas: $lost/$limit';
  }

  @override
  String raidIncomingThisTurn(String wave) {
    return 'Incursión al final de este turno: $wave';
  }

  @override
  String raidIncomingOnTurn(int turn, String wave) {
    return 'Incursión al final del turno $turn: $wave';
  }

  @override
  String get raidBaseLooted => 'La base fue saqueada';

  @override
  String raidAnnounced(String wave, int turn) {
    return 'Se acerca una incursión: $wave, final del turno $turn';
  }

  @override
  String raidDueThisTurn(String attacker, String wave, String defenders) {
    return '$attacker este turno: $wave contra $defenders';
  }

  @override
  String raidDefenders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count defensores',
      one: '$count defensor',
      zero: 'ningún defensor',
    );
    return '$_temp0';
  }

  @override
  String get raidLastChance => 'Si pierdes esta incursión, la partida termina.';

  @override
  String volcanoWaveTitle(int turn) {
    return 'Oleada sobre el Núcleo (turno $turn)';
  }

  @override
  String volcanoKernelHolds(int level) {
    return 'El Núcleo resiste en el nivel $level';
  }

  @override
  String volcanoKernelDrops(int level) {
    return 'El Núcleo cae al nivel $level';
  }

  @override
  String volcanoMagmaRampart(String stats) {
    return 'Muralla de magma: $stats';
  }

  @override
  String volcanoKernelLevel(int level) {
    return 'Núcleo nivel $level';
  }

  @override
  String volcanoGarrison(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guarnición: $count unidades',
      one: 'Guarnición: $count unidad',
    );
    return '$_temp0';
  }

  @override
  String volcanoNextWave(String wave) {
    return 'Próxima oleada, al final del turno: $wave';
  }

  @override
  String volcanoLevelsLost(int count) {
    return 'Niveles perdidos ante las oleadas: $count';
  }

  @override
  String get volcanoGarrisonUnits => 'Poner en guarnición';

  @override
  String get volcanoWithdraw => 'Retirar';

  @override
  String volcanoDueWarning(String wave) {
    return 'Oleada sobre el Núcleo este turno: $wave, y sin guarnición. El Núcleo probablemente perderá un nivel.';
  }

  @override
  String volcanoStatus(int level, String wave, int size) {
    return 'Núcleo niv. $level, final del turno: $wave contra una guarnición de $size';
  }

  @override
  String volcanoRepelled(String losses) {
    return 'Volcán: oleada repelida, $losses';
  }

  @override
  String volcanoKernelFell(int level) {
    return 'Volcán: el Núcleo cae al nivel $level';
  }

  @override
  String volcanoWounded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heridos',
      one: '$count herido',
    );
    return '$_temp0';
  }

  @override
  String volcanoDead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count muertos',
      one: '$count muerto',
    );
    return '$_temp0';
  }

  @override
  String volcanoKrakenRises(String wave) {
    return 'El Kraken asciende: $wave el próximo turno';
  }

  @override
  String get eventCardWarmLine1 => 'Una corriente cálida atraviesa la base.';

  @override
  String get eventCardWarmLine2 =>
      'Impulsa la producción, pero su remolino hace ruido.';

  @override
  String get eventCardColdLine1 => 'Una corriente fría hiela los invernaderos.';

  @override
  String get eventCardColdLine2 => 'Sin calefacción, las algas crecen menos.';

  @override
  String get eventCardPredatorsLine1 =>
      'Un banco de depredadores merodea alrededor de la base.';

  @override
  String get eventCardPredatorsWatching => 'Acechan la base.';

  @override
  String eventCardPredatorsWave(String wave, String defenders) {
    return '$wave contra $defenders del nivel 1.';
  }

  @override
  String get eventCardSurvivorsLine1 =>
      'Una cápsula varada lanza una bengala de socorro.';

  @override
  String get eventCardSurvivorsLine2 =>
      'Sus supervivientes pueden unirse a la base, pero comerán algas.';

  @override
  String get eventCardCaravanLine1 =>
      'Una caravana de tortugas pasa cerca de la base.';

  @override
  String get eventCardCaravanLine2 =>
      'Su cangrejo mercader propone un intercambio.';

  @override
  String eventCardStormLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'Exploración imposible durante $turns turnos.',
      one: 'Exploración imposible durante $turns turno.',
    );
    return '$_temp0';
  }

  @override
  String eventCardStormLine2(int relief) {
    return 'La tormenta cubre el ruido: indicador −$relief.';
  }

  @override
  String get eventCardWreckLine1 =>
      'Un pecio se hundió al borde de la zona explorada.';

  @override
  String eventCardWreckLine2(int turns, int noise) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other:
          'Explóralo con un Explorador y regístralo antes de $turns turnos (+$noise ruido).',
      one:
          'Explóralo con un Explorador y regístralo antes de $turns turno (+$noise ruido).',
    );
    return '$_temp0';
  }

  @override
  String eventCardWarmAccept(int percent, int turns, int noise) {
    return 'Aprovechar (+$percent % algas, coral, mineral durante $turns turnos, +$noise ruido/turno)';
  }

  @override
  String get eventCardWarmRefuse => 'Dejarla pasar';

  @override
  String eventCardColdAccept(int energy, int turns) {
    return 'Calentar los invernaderos (−$energy energía/turno durante $turns turnos)';
  }

  @override
  String eventCardColdRefuse(int percent, int turns) {
    return 'Aguantar (−$percent % de algas durante $turns turnos)';
  }

  @override
  String eventCardPredatorsAccept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enfrentarlo ($count monstruos, final del turno)',
      one: 'Enfrentarlo ($count monstruo, final del turno)',
    );
    return '$_temp0';
  }

  @override
  String eventCardPredatorsRefuse(int algae) {
    return 'Atraerlo con cebo (−$algae algas)';
  }

  @override
  String eventCardSurvivorsAccept(String units) {
    return 'Acoger a $units';
  }

  @override
  String get eventCardRefuse => 'Rechazar';

  @override
  String eventCardTrade(int give, String from, int get, String to) {
    return 'Cambiar $give $from por $get $to';
  }

  @override
  String get eventCardLater => 'Más tarde';

  @override
  String eventCardPendingWarning(String event) {
    return '$event: sin elección, se aplicará la opción prudente';
  }

  @override
  String eventCardStatusPending(String event) {
    return 'Evento: $event — elegir';
  }

  @override
  String get techScreenUnlock => 'Desbloquear';

  @override
  String get techScreenResearch => 'Investigar';

  @override
  String techScreenChoiceTitle(String branch, int level) {
    return '$branch · Nivel $level · Elección';
  }

  @override
  String techScreenNodeSubtitle(String branch, int level, String effect) {
    return '$branch · Nivel $level · $effect';
  }

  @override
  String get techScreenChoiceWarning =>
      'Solo una opción por partida, la otra se perderá.';

  @override
  String get techScreenChoose => 'Elegir';

  @override
  String get techScreenChosen => 'Elegida ✓';

  @override
  String get techScreenDiscarded => 'Descartada';

  @override
  String get techScreenOr => 'o';

  @override
  String get techScreenAcquired => 'Adquirido ✓';

  @override
  String techScreenSurcharge(String factor) {
    return 'Todas las investigaciones costarán ×$factor una vez abierta esta rama.';
  }

  @override
  String get techScreenUnlockBranchFirst => 'Desbloquea primero la rama';

  @override
  String techScreenResearchPreviousFirst(int level) {
    return 'Investiga primero el nivel $level';
  }

  @override
  String techScreenLabRequired(int level) {
    return 'Laboratorio nivel $level necesario';
  }

  @override
  String get techScreenOneResearchPerTurn =>
      'Una investigación por turno: espera al próximo turno';

  @override
  String techScreenMedallionLevel(int level) {
    return 'Niv. $level';
  }

  @override
  String get objectiveSheetTitle => 'Objetivos';

  @override
  String get objectiveEventHeader => 'Objetivos de evento';

  @override
  String objectiveProgress(String title, int current, int target) {
    return '$title: $current/$target';
  }

  @override
  String objectiveCompleted(String title) {
    return 'Objetivo cumplido: $title';
  }

  @override
  String get objectiveMissed => '(fallido)';

  @override
  String objectiveRaiseHq(int level) {
    return 'Sube el Cuartel General al nivel $level';
  }

  @override
  String get objectiveAlgaeFarm => 'Construye la Granja de algas';

  @override
  String get objectiveMines =>
      'Construye la Mina de coral y el Extractor de mineral';

  @override
  String get objectiveSolarPanel => 'Construye el Panel solar';

  @override
  String objectiveBarracksAndScouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Exploradores',
      one: '$count Explorador',
    );
    return 'Construye los Barracones y recluta $_temp0';
  }

  @override
  String get objectiveExplore => 'Explora una casilla alrededor de la base';

  @override
  String get objectiveLaboratoryAndResearch =>
      'Construye el Laboratorio e inicia una investigación';

  @override
  String get objectiveFirstRaid => 'Repele la primera incursión';

  @override
  String get objectiveTakeLair => 'Toma una guarida';

  @override
  String get objectiveCoralCitadel => 'Construye la Ciudadela de coral';

  @override
  String get objectiveTakeFaille => 'Toma la Falla';

  @override
  String get objectiveDescentModule => 'Construye el Módulo de Descenso';

  @override
  String objectiveDescend(int level) {
    return 'Desciende al nivel $level';
  }

  @override
  String get objectiveTakeCheminee => 'Toma la Chimenea';

  @override
  String get objectivePressureCapsule => 'Construye la Cápsula Presurizada';

  @override
  String get objectiveTakeKernel => 'Toma el Núcleo Volcánico';

  @override
  String objectiveRaiseKernel(int level) {
    return 'Sube el Núcleo al nivel $level';
  }

  @override
  String get chapterInstallation => 'Instalación';

  @override
  String get chapterReef => 'El arrecife';

  @override
  String get chapterRift => 'La Falla';

  @override
  String get chapterChimney => 'La Chimenea';

  @override
  String get chapterKernel => 'El Núcleo';

  @override
  String get chapterAwakening => 'El despertar';

  @override
  String chapterNumbered(int number, String title) {
    return '$number. $title';
  }

  @override
  String get tipGuideTitle => 'Guía';

  @override
  String get tipCategoryBase => 'Base';

  @override
  String get tipCategoryThreats => 'Amenazas';

  @override
  String get tipCategoryMap => 'Mapa';

  @override
  String get tipCategoryEvents => 'Eventos';

  @override
  String get tipNoiseGaugeTitle => 'El medidor de ruido';

  @override
  String get tipNoiseGaugeLine1 =>
      'Cada obra, cada recluta y cada exploración hacen ruido, y tu base hace un poco cada turno.';

  @override
  String tipNoiseGaugeLine2(int threshold) {
    return 'Cuando el medidor llega a $threshold, los monstruos lo oyen: se anuncia una incursión.';
  }

  @override
  String get tipWorksitesTitle => 'Dos obras por turno';

  @override
  String tipWorksitesLine1(int level) {
    return 'Tu Cuartel General de nivel $level abre una segunda obra: suben dos edificios cada turno.';
  }

  @override
  String tipWorksitesLine2(int level) {
    return 'Con el nivel $level se abrirá una tercera. La investigación sigue siendo una por turno.';
  }

  @override
  String get tipTechChoiceTitle => 'Las elecciones de la investigación';

  @override
  String get tipTechChoiceLine1 =>
      'El próximo nodo de tu rama es una elección entre dos opciones.';

  @override
  String get tipTechChoiceLine2 =>
      'Esta elección es definitiva: la otra opción quedará cerrada toda la partida.';

  @override
  String get tipTechChoiceLine3 =>
      'Tómate tu tiempo para leer ambas antes de lanzar la investigación.';

  @override
  String get tipRaidAnnouncedTitle => 'Se acerca una incursión';

  @override
  String tipRaidAnnouncedLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turnos',
      one: '$turns turno',
    );
    return 'Tu ruido atrajo monstruos: atacarán tu base en $_temp0.';
  }

  @override
  String get tipRaidAnnouncedLine2 =>
      'Recluta defensores: los Arponeros están hechos para eso.';

  @override
  String get tipRaidAnnouncedLine3 =>
      'La muralla de la Ciudadela de coral también te ayudará a resistir.';

  @override
  String get tipRaidReportTitle => 'El informe de incursión';

  @override
  String get tipRaidReportLine1 =>
      'Tras cada incursión, el informe muestra el combate, tus pérdidas y el botín.';

  @override
  String get tipRaidReportLine2 =>
      'Una incursión perdida saquea parte de tus recursos.';

  @override
  String get tipRaidReportLine3 =>
      'Una incursión repelida borra tu racha de derrotas.';

  @override
  String get tipLastChanceTitle => 'Última oportunidad';

  @override
  String tipLastChanceLine1(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu base ha perdido $count incursiones seguidas.',
      one: 'Tu base ha perdido $count incursión.',
    );
    return '$_temp0';
  }

  @override
  String get tipLastChanceLine2 =>
      'Si la próxima incursión también se pierde, la partida termina.';

  @override
  String get tipLastChanceLine3 =>
      'Pon tus fuerzas en la defensa: una victoria borra la racha.';

  @override
  String get tipMonsterFamiliesTitle => 'Las familias de monstruos';

  @override
  String get tipMonsterFamiliesLine1 =>
      'Cada guarida alberga una familia, con su propia regla de combate.';

  @override
  String get tipMonsterFamiliesLine2 =>
      'Cada familia tiene su punto débil: una unidad que la contrarresta.';

  @override
  String get tipMonsterFamiliesLine3 =>
      'Toca la guarida en el Mapa para conocerla antes de atacar.';

  @override
  String get tipVolcanoWaveTitle => 'La oleada del Volcán';

  @override
  String get tipVolcanoWaveLine1 =>
      'El Volcán envía a sus Krakens a recuperar el Núcleo.';

  @override
  String get tipVolcanoWaveLine2 =>
      'La oleada golpea al final del próximo turno: mantén una guarnición en el Núcleo.';

  @override
  String get tipVolcanoWaveLine3 =>
      'Cada oleada perdida le quita un nivel al Núcleo.';

  @override
  String get tipLairTitle => 'Las guaridas';

  @override
  String get tipLairLine1 =>
      'En el Mapa, una guarida de monstruos protege su casilla: atácala con tu ejército.';

  @override
  String get tipLairLine2 =>
      'Vencidos, los monstruos dejan su botín, pero cada combate hace ruido.';

  @override
  String get tipLairLine3 => 'Mira cuántos son antes de elegir tus unidades.';

  @override
  String get tipChestAndRuinsTitle => 'Cofres y ruinas';

  @override
  String get tipChestAndRuinsLine1 =>
      'Un cofre o unas ruinas esconden recursos.';

  @override
  String get tipChestAndRuinsLine2 =>
      'Toca la casilla en el Mapa para registrarlos: es seguro y no hace ruido.';

  @override
  String get tipTransitionBaseTitle => 'Las bases de transición';

  @override
  String get tipTransitionBaseLine1 =>
      'Una base custodiada, en el Mapa, lleva a las profundidades.';

  @override
  String get tipTransitionBaseLine2 =>
      'Tomada al asalto, te da perlas cada turno.';

  @override
  String get tipTransitionBaseLine3 =>
      'También abre el camino al siguiente nivel.';

  @override
  String get tipDescentTitle => 'El descenso';

  @override
  String get tipDescentLine1 =>
      'Tu Módulo de Descenso envía unidades al nivel inferior, por la Falla.';

  @override
  String get tipDescentLine2 =>
      'Cuidado: una unidad que desciende ya no vuelve a subir.';

  @override
  String get tipDescentLine3 =>
      'Abajo te esperan otras guaridas, y el camino al Núcleo.';

  @override
  String get tipEventsTitle => 'Los eventos';

  @override
  String tipEventsLine1(int minGap, int maxGap) {
    return 'Cada $minGap a $maxGap turnos, un evento sacude los abismos.';
  }

  @override
  String get tipEventsLine2 =>
      'Tienes el turno siguiente para elegir tu respuesta en su carta.';

  @override
  String get tipEventsLine3 => 'Si no eliges, se aplica la opción prudente.';

  @override
  String tipWarmCurrentLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turnos',
      one: '$turns turno',
    );
    return 'Una corriente cálida impulsa tu producción durante $_temp0.';
  }

  @override
  String get tipWarmCurrentLine2 => 'Pero su remolino hace ruido cada turno.';

  @override
  String get tipWarmCurrentLine3 =>
      'Aprovéchala si tus defensas están listas para una incursión.';

  @override
  String tipWreckLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turnos',
      one: '$turns turno',
    );
    return 'Un galeón hundido permanece $_temp0 al borde de la zona explorada.';
  }

  @override
  String get tipWreckLine2 =>
      'Explora su casilla con un Explorador y luego regístrala para llevarte su botín.';

  @override
  String tipWreckLine3(int noise) {
    return 'Registrarlo hace ruido (+$noise): elige tu momento.';
  }

  @override
  String get tipPredatorsLine1 =>
      'Un gran tiburón y su banco merodean alrededor de tu base.';

  @override
  String get tipPredatorsLine2 =>
      'Enfréntate a ellos por su botín, o cede algas para alejarlos.';

  @override
  String get tipPredatorsLine3 =>
      'Perder contra ellos nunca termina la partida.';

  @override
  String tipStormLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turnos',
      one: '$turns turno',
    );
    return 'La tormenta cierra la exploración durante $_temp0.';
  }

  @override
  String tipStormLine2(int relief) {
    return 'A cambio, cubre tu ruido: el medidor baja $relief.';
  }

  @override
  String get tipSurvivorsLine1 => 'Una cápsula varada alberga supervivientes.';

  @override
  String get tipSurvivorsLine2 => 'Acogidos, se unen a tu base como Arponeros.';

  @override
  String get tipSurvivorsLine3 =>
      'Como todo tu ejército, comen algas cada turno.';

  @override
  String get tipCaravanLine1 =>
      'Una caravana de tortugas pasa cerca de tu base.';

  @override
  String get tipCaravanLine2 =>
      'Su cangrejo mercader cambia tu recurso más abundante por el más escaso.';

  @override
  String tipColdCurrentLine1(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turnos',
      one: '$turns turno',
    );
    return 'Una corriente fría frena tus algas durante $_temp0.';
  }

  @override
  String get tipColdCurrentLine2 =>
      'Calentar los invernaderos cuesta energía, pero salva la cosecha.';

  @override
  String get tipColdCurrentLine3 =>
      'Sin algas, tu ejército no aguanta: vigila tus reservas.';

  @override
  String get guideLessonHqLevel1 =>
      '¡Bienvenido a los abismos! Toca el Cuartel General para lanzar tu primera obra: solo una por turno para empezar. Luego pulsa «Siguiente turno».';

  @override
  String get guideLessonAlgaeFarm =>
      '¡Bien hecho con tu primera obra! Las algas alimentan a tu ejército: cada unidad come algas cada turno. Construye la Granja de algas.';

  @override
  String get guideLessonMines =>
      'El coral y el mineral lo pagan casi todo. Construye la Mina de coral y luego el Extractor de mineral, uno por turno. Fíjate bien: cada nivel cuesta más que el anterior.';

  @override
  String get guideLessonSolarPanel =>
      'El Extractor consume energía, y los Barracones también la consumirán. Sin energía, se detienen. Construye el Panel solar.';

  @override
  String guideLessonHqLevel2(int level) {
    return 'El Cuartel General de nivel $level desbloquea los Barracones y el Laboratorio. Pero cada obra hace ruido: vigila el medidor en lo alto de la pantalla, atrae a los monstruos.';
  }

  @override
  String guideLessonBarracksAndScouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Exploradores',
      one: '$count Explorador',
    );
    return 'Construye los Barracones y luego recluta $_temp0 en la pestaña Ejército. Cada unidad come algas cada turno, y cada recluta hace subir el ruido.';
  }

  @override
  String get guideLessonExplore =>
      'Alrededor de tu base, todo está en la niebla. En el Mapa, envía un Explorador a una casilla vecina: encontrarás guaridas de monstruos de distintas familias, y a veces cofres.';

  @override
  String get guideLessonLaboratoryAndResearch =>
      'Construye el Laboratorio, abre una rama en la pestaña Tecno e inicia una investigación. Solo una investigación por turno, y algunas elecciones son definitivas: tómate tu tiempo para leer.';

  @override
  String guideLessonFirstRaid(int turns) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: '$turns turnos',
      one: '$turns turno',
    );
    return 'El ruido siempre acaba atrayendo una incursión, anunciada con $_temp0 de antelación. Recluta Arponeros para defender tu base. Más adelante, la muralla de la Ciudadela también te ayudará.';
  }

  @override
  String get guideGoalMet =>
      '¡Bien hecho, ya está! Termina el turno para validar el objetivo y cobrar tu recompensa.';

  @override
  String get guideWorksiteTaken =>
      'La obra de este turno ya está ocupada. Termina el turno: construirás lo siguiente en el próximo.';

  @override
  String get guideAlreadyRecruited =>
      'Ya has reclutado estas unidades este turno. Termina el turno para reclutar más.';

  @override
  String get guideExploring =>
      'Tu Explorador está en camino. Termina el turno para descubrir qué esconde la casilla.';

  @override
  String guideStorm(int turn) {
    return 'Una tormenta cierra la exploración hasta el final del turno $turn. Ten paciencia: el objetivo te espera, termina el turno.';
  }

  @override
  String guideWreckWithoutBarracks(int turn) {
    return 'Un pecio se ha hundido cerca de tu base, visible hasta el final del turno $turn. Hace falta un Explorador para alcanzarlo, y por tanto unos Barracones: sigue con tu objetivo, ya llegará.';
  }

  @override
  String guideWreckWithoutScout(int turn) {
    return 'Un pecio se ha hundido cerca de tu base, visible hasta el final del turno $turn. Recluta un Explorador en la pestaña Ejército para ir a registrarlo.';
  }

  @override
  String guideRaidIntro(int turn, int monsters) {
    String _temp0 = intl.Intl.pluralLogic(
      monsters,
      locale: localeName,
      other: '$monsters monstruos',
      one: '$monsters monstruo',
    );
    return 'La incursión llega en el turno $turn con $_temp0.';
  }

  @override
  String get guideRaidOutOfReach =>
      'Recluta tantos Arponeros como puedas en la pestaña Ejército.';

  @override
  String get guideRaidHeld =>
      'Tu defensa debería repelerla: termina el turno para esperarla.';

  @override
  String guideRaidNeeded(int needed, int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      needed,
      locale: localeName,
      other: '$needed Arponeros',
      one: '$needed Arponero',
    );
    String _temp1 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'te faltan $missing',
      one: 'te falta $missing',
    );
    return 'Ten al menos $_temp0 en el nivel 1: $_temp1.';
  }

  @override
  String guideRaidRecruitNow(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Reclútalos en la pestaña Ejército.',
      one: 'Reclútalo en la pestaña Ejército.',
    );
    return '$_temp0';
  }

  @override
  String guideRaidRecruitNextTurn(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'reclútalos',
      one: 'reclútalo',
    );
    return 'Ya has reclutado este turno: $_temp0 en el próximo turno.';
  }

  @override
  String get guideRaidHoldOn =>
      'Ya has reclutado este turno: termínalo y aguanta.';

  @override
  String get tutorialGuideSwitch => 'Guía del tutorial';

  @override
  String get tutorialGuideSwitchHint =>
      'La guía te muestra qué hacer, objetivo tras objetivo';

  @override
  String get tutorialTipsSwitch => 'Consejos';

  @override
  String get tutorialTipsSwitchHint =>
      'Una ficha explica cada novedad la primera vez que aparece';

  @override
  String get tutorialReviewTips => 'Volver a ver las fichas';

  @override
  String get gameOverDefeatTitle => 'DERROTA';

  @override
  String gameOverDefeatSubtitle(int turn, int raids) {
    String _temp0 = intl.Intl.pluralLogic(
      raids,
      locale: localeName,
      other:
          'Tu base cayó al final del turno $turn, tras $raids incursiones perdidas seguidas.',
      one:
          'Tu base cayó al final del turno $turn, tras $raids incursión perdida seguida.',
    );
    return '$_temp0';
  }

  @override
  String get gameOverVictoryTitle => '¡VICTORIA!';

  @override
  String get gameOverVictorySubtitle => '¡Has conquistado el Núcleo Volcánico!';

  @override
  String get gameOverContinueFreePlay => 'Continuar en modo libre';

  @override
  String get gameOverBackToMenu => 'Volver al menú';

  @override
  String gameOverTurnsPlayed(int count) {
    return 'Turnos jugados: $count';
  }

  @override
  String gameOverMonstersDefeated(int count) {
    return 'Monstruos vencidos: $count';
  }

  @override
  String gameOverBasesCaptured(int count) {
    return 'Bases capturadas: $count';
  }

  @override
  String gameOverResourcesCollected(int count) {
    return 'Recursos recogidos: $count';
  }

  @override
  String gameOverRaidsRepelled(int count) {
    return 'Incursiones repelidas: $count';
  }

  @override
  String gameOverRaidsLost(int count) {
    return 'Incursiones perdidas: $count';
  }

  @override
  String get menuSubtitle => 'Las profundidades te esperan';

  @override
  String get menuContinue => 'CONTINUAR';

  @override
  String get menuNewGame => 'NUEVA PARTIDA';

  @override
  String get menuLoadGame => 'CARGAR PARTIDA';

  @override
  String menuBetaVersion(String version) {
    return 'Versión beta $version';
  }

  @override
  String get menuBetaWarning => 'las partidas guardadas pueden borrarse';

  @override
  String get saveLoadTitle => 'Cargar una partida';

  @override
  String get saveDeleteTitle => '¿Eliminar la partida?';

  @override
  String saveDeleteMessage(String name) {
    return 'La partida de $name se eliminará definitivamente.';
  }

  @override
  String get saveDelete => 'Eliminar';

  @override
  String get saveOptions => 'Opciones';

  @override
  String get saveEmptyTitle => 'Ninguna colonia detectada';

  @override
  String get saveEmptyMessage => 'Funda tu primera base en el abismo.';

  @override
  String get saveInProgress => 'En curso';

  @override
  String get saveFinished => 'Terminadas';

  @override
  String get saveVictoryBadge => '★ VICTORIA';

  @override
  String get saveDefeatBadge => 'DERROTA';

  @override
  String saveMetaInProgress(int turn, String depth, int level) {
    return 'Turno $turn · $depth · CG niv. $level';
  }

  @override
  String saveMetaWon(int turn, String depth, String difficulty) {
    return 'Turno $turn · $depth · $difficulty';
  }

  @override
  String saveMetaFallen(int turn, String depth, String difficulty) {
    return 'Caída en el turno $turn · $depth · $difficulty';
  }

  @override
  String get saveKernelConquered => 'Núcleo Volcánico conquistado';

  @override
  String get saveVictory => 'Victoria';

  @override
  String get saveSeeReport => 'Ver el balance de la partida';

  @override
  String saveResumeLabel(String name, int turn, String difficulty) {
    return '$name · Turno $turn · $difficulty';
  }

  @override
  String get saveJustNow => 'ahora mismo';

  @override
  String saveMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String saveHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String get saveYesterday => 'ayer';

  @override
  String saveShortDate(int day, String month) {
    return '$day $month';
  }

  @override
  String saveShortDateWithYear(int day, String month, int year) {
    return '$day $month $year';
  }

  @override
  String saveMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'ene',
      'feb': 'feb',
      'mar': 'mar',
      'apr': 'abr',
      'may': 'may',
      'jun': 'jun',
      'jul': 'jul',
      'aug': 'ago',
      'sep': 'sept',
      'oct': 'oct',
      'nov': 'nov',
      'other': 'dic',
    });
    return '$_temp0';
  }

  @override
  String get screenSettings => 'Ajustes';

  @override
  String get screenNextTurn => 'Siguiente turno';

  @override
  String get screenTabBase => 'Base';

  @override
  String get screenTabMap => 'Mapa';

  @override
  String get screenTabArmy => 'Ejército';

  @override
  String get screenTabTech => 'Tecno';

  @override
  String get screenComingSoon => 'Próximamente';

  @override
  String get screenGameInProgress => 'Partida en curso';

  @override
  String get screenViewHistory => 'Ver el historial';

  @override
  String get screenExportGame => 'Exportar la partida';

  @override
  String get screenSaveAndQuit => 'Guardar y salir';

  @override
  String get screenCopy => 'Copiar';

  @override
  String get screenShareFile => 'Compartir el archivo';

  @override
  String get screenReplayUnavailable =>
      'Esta partida empezó antes de que se grabaran las repeticiones: no se puede exportar. Las partidas nuevas sí.';

  @override
  String screenReplaySummary(String file, String actions, String turns) {
    return 'El archivo $file contiene $actions en $turns.';
  }

  @override
  String screenReplayActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acciones',
      one: '$count acción',
    );
    return '$_temp0';
  }

  @override
  String screenReplayTurns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count turnos jugados',
      one: '$count turno jugado',
    );
    return '$_temp0';
  }

  @override
  String get screenReplayExact =>
      'Los combates y las incursiones se repetirán de forma idéntica.';

  @override
  String get screenReplayInexact =>
      'Algunas tiradas de dados no se grabaron: algunos combates podrían desarrollarse de otra forma.';

  @override
  String get screenReplayCopied => 'Repetición copiada al portapapeles';

  @override
  String get screenReplayShareTitle => 'Repetición de Abysses';

  @override
  String get screenTreasureCollected => '¡Tesoro recogido!';

  @override
  String get screenRuinsSearched => '¡Ruinas registradas!';

  @override
  String get screenWreckSearched => '¡Pecio registrado!';

  @override
  String get screenCollectTitle => 'Recolección';

  @override
  String get screenRuinsEmpty => 'Las ruinas estaban vacías...';

  @override
  String get screenWreckEmpty => 'El pecio estaba vacío...';

  @override
  String get screenNothingToCollect => 'Nada que recoger aquí...';

  @override
  String screenEventChosen(String event, String choice) {
    return '$event: $choice';
  }

  @override
  String get screenGarrisonSendTitle => 'Poner en la guarnición';

  @override
  String get screenGarrisonWithdrawTitle => 'Retirar de la guarnición';

  @override
  String get screenGarrisonWithdraw => 'Retirar';

  @override
  String get screenGarrisonSendInfo =>
      'Solo la guarnición defiende el Núcleo contra las oleadas del Kraken.';

  @override
  String get screenGarrisonWithdrawInfo =>
      'Las unidades retiradas vuelven al nivel 3.';

  @override
  String screenGarrisonSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guarnición: $count unidades',
      one: 'Guarnición: $count unidad',
    );
    return '$_temp0';
  }

  @override
  String get screenAlreadyVisitedTitle => 'Ya visitado';

  @override
  String get screenAlreadyVisitedMessage => 'Ya has pasado por aquí';

  @override
  String get screenYourBaseTitle => 'Tu base';

  @override
  String get screenYourBaseMessage => 'Tu cuartel general';

  @override
  String screenPlainTitle(int x, int y) {
    return 'Llanura ($x, $y)';
  }

  @override
  String get screenNothingToSee => 'No hay nada que ver aquí';

  @override
  String screenPassageTitle(String name) {
    return 'Paso hacia $name';
  }

  @override
  String get screenUnknownPassage => 'paso desconocido';

  @override
  String get screenPassageMessage =>
      'Este lugar marca un paso hacia el nivel inferior.';

  @override
  String screenDescendThrough(String base) {
    return 'Bajar tropas por $base';
  }

  @override
  String screenDescentTitle(int level) {
    return 'Descenso al Nivel $level';
  }

  @override
  String get screenDescentWarning =>
      'Atención: el descenso es definitivo. Las unidades no podrán volver a subir.';

  @override
  String screenDescentConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descender ($count unidades)',
      one: 'Descender ($count unidad)',
    );
    return '$_temp0';
  }

  @override
  String screenDescentDone(int level) {
    return 'Descenso al Nivel $level completado';
  }

  @override
  String screenReinforcementTitle(int level) {
    return 'Refuerzos hacia el Nivel $level';
  }

  @override
  String get screenReinforcementInfo =>
      'Los refuerzos llegarán el próximo turno.';

  @override
  String screenReinforcementConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviar ($count unidades)',
      one: 'Enviar ($count unidad)',
    );
    return '$_temp0';
  }

  @override
  String screenReinforcementsSent(int count, int level) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unidades en tránsito hacia el Nivel $level',
      one: '$count unidad en tránsito hacia el Nivel $level',
    );
    return '$_temp0';
  }

  @override
  String get baseFailleAlpha => 'Falla Alfa';

  @override
  String get baseFailleBeta => 'Falla Beta';

  @override
  String get baseFailleGamma => 'Falla Gamma';

  @override
  String get baseFailleDelta => 'Falla Delta';

  @override
  String get baseChemineePrimary => 'Chimenea Primaria';

  @override
  String get baseChemineeSecondary => 'Chimenea Secundaria';

  @override
  String get baseChemineeTertiary => 'Chimenea Terciaria';

  @override
  String baseOtherName(String type, int number) {
    return '$type $number';
  }

  @override
  String baseLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String baseLevelShort(int level) {
    return 'Niv. $level';
  }

  @override
  String get baseNotBuilt => 'Sin construir';

  @override
  String get baseMaxLevel => 'Nivel máximo alcanzado';

  @override
  String baseUpgradeLevels(int from, int to) {
    return 'Nivel $from → $to';
  }

  @override
  String get baseWorksitesBusy => 'Obras ocupadas este turno';

  @override
  String get baseBuild => 'Construir';

  @override
  String get baseUpgrade => 'Mejorar';

  @override
  String baseCapturedBaseRequired(String base) {
    return '$base capturada requerida';
  }

  @override
  String get baseKernelRequired => 'Núcleo Volcánico capturado requerido';

  @override
  String baseWorksitesFree(int free, int total) {
    return 'Obras libres este turno: $free/$total';
  }

  @override
  String baseWorksitesNext(int level) {
    return '+1 en el CG $level';
  }

  @override
  String baseShield(String rampart) {
    return 'Muralla de la base: $rampart';
  }

  @override
  String baseRampartCurrent(String rampart) {
    return 'Muralla actual: $rampart';
  }

  @override
  String baseRampartNext(String rampart) {
    return 'Próximo nivel: $rampart';
  }

  @override
  String get baseRampartMax => 'Muralla en su apogeo';

  @override
  String get baseRampartHint =>
      'Durante una incursión, la muralla combate junto a los defensores del nivel 1 y atrae todos los ataques.';

  @override
  String get baseRampartNone => 'ninguna';

  @override
  String baseCoralRampartStats(int hp, int def) {
    return '$hp PV, DEF $def';
  }

  @override
  String baseMagmaRampartStats(int hp, int atk, int def) {
    return '$hp PV, ATK $atk, DEF $def';
  }

  @override
  String get unitRecruitDone => 'Reclutamiento ya realizado este turno';

  @override
  String get unitNotEnoughResources => 'Recursos insuficientes';

  @override
  String get unitRecruit => 'Reclutar';

  @override
  String unitTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unidades',
      one: '$count unidad',
    );
    return '$_temp0';
  }

  @override
  String get unitPlaceKernel => 'Núcleo';

  @override
  String get unitLocked => 'Bloqueado';

  @override
  String unitBarracksRequired(int level) {
    return 'Barracones de nivel $level requeridos para desbloquear';
  }

  @override
  String unitInService(int count) {
    return 'En servicio: $count';
  }

  @override
  String get unitNoneAvailable => 'No hay unidades disponibles.';

  @override
  String get resourceProduction => 'Producción';

  @override
  String get resourceMainBuilding => 'Edificio principal';

  @override
  String turnTransition(int from, int to) {
    return 'Turno $from → Turno $to';
  }

  @override
  String get turnNoProduction => 'Ninguna producción este turno.';

  @override
  String get turnNoChange => 'Ningún cambio este turno.';

  @override
  String get turnStorageFull => '(máx. alcanzado)';

  @override
  String get turnRecruitAvailable => 'Reclutamiento disponible';

  @override
  String turnPendingExplorations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exploraciones pendientes',
      one: '$count exploración pendiente',
    );
    return '$_temp0';
  }

  @override
  String get turnBuildingsDeactivated => 'Edificios desactivados';

  @override
  String get turnUnitsLost => 'Unidades perdidas';

  @override
  String get turnPredatorsLooted => 'El banco de depredadores saqueó la base';

  @override
  String turnEventDefaulted(String event) {
    return '$event: opción prudente aplicada';
  }

  @override
  String turnEventDrawn(String event) {
    return 'Evento: $event';
  }

  @override
  String turnExplorationTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exploración: $count casillas nuevas',
      one: 'Exploración: $count casilla nueva',
    );
    return '$_temp0';
  }

  @override
  String turnExplorationCells(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count casillas',
      one: '$count casilla',
    );
    return '$_temp0';
  }

  @override
  String get historyFilterAll => 'Todos';

  @override
  String get historyFilterCombat => 'Combates';

  @override
  String get historyFilterBuilding => 'Construcción';

  @override
  String get historyFilterResearch => 'Investigación';

  @override
  String get historyFilterEvent => 'Eventos';

  @override
  String get historyFilterOther => 'Otros';

  @override
  String get historyEmpty => 'Todavía no hay ninguna acción registrada.';

  @override
  String get historyEmptyFilter => 'Ninguna acción para este filtro.';
}
