part of 'guide_message.dart';

/// No Abyss Admiral to lead the assault on [target]: the barracks must
/// reach [barracksLevel] to recruit one.
class GuideAdmiralNeedsBarracks extends GuideMessage {
  final AssaultTarget target;
  final int barracksLevel;

  const GuideAdmiralNeedsBarracks(this.target, this.barracksLevel);

  @override
  List<Object> get _figures => [target, barracksLevel];
}

/// No Abyss Admiral to lead the assault on [target]: recruit one.
class GuideAdmiralToRecruit extends GuideMessage {
  final AssaultTarget target;

  const GuideAdmiralToRecruit(this.target);

  @override
  List<Object> get _figures => [target];
}

/// The Abyss Admiral must go down to [level] to assault [target].
class GuideAdmiralToSend extends GuideMessage {
  final AssaultTarget target;
  final int level;

  const GuideAdmiralToSend(this.target, this.level);

  @override
  List<Object> get _figures => [target, level];
}

/// No [target] in sight yet: explore to find one.
class GuidePostToFind extends GuideMessage {
  final AssaultTarget target;

  const GuidePostToFind(this.target);

  @override
  List<Object> get _figures => [target];
}

/// A [target] in sight: send the admiral, covered by Guardians, with at
/// least [harpoonists] Harpoonists; `null` when no number would do.
class GuidePostAssault extends GuideMessage {
  final AssaultTarget target;
  final int? harpoonists;

  const GuidePostAssault(this.target, {this.harpoonists});

  @override
  List<Object> get _figures => [target, harpoonists ?? -1];
}

/// An assault on [target] won this turn while the admiral fell: nothing
/// was taken.
class GuideAdmiralFell extends GuideMessage {
  final AssaultTarget target;

  const GuideAdmiralFell(this.target);

  @override
  List<Object> get _figures => [target];
}

/// The [passage] building needs the headquarters at [headquarters].
class GuidePassageNeedsHq extends GuideMessage {
  final BuildingType passage;
  final int headquarters;

  const GuidePassageNeedsHq(this.passage, this.headquarters);

  @override
  List<Object> get _figures => [passage, headquarters];
}

/// A post of [type] is held with nobody on [level], the only units that
/// defend it.
class GuidePostUndefended extends GuideMessage {
  final TransitionBaseType type;
  final int level;

  const GuidePostUndefended(this.type, this.level);

  @override
  List<Object> get _figures => [type, level];
}

/// A wave of [monsters] krakens comes to take the kernel back: at least
/// [needed] units must stand in its garrison; `null` when no number
/// would hold.
class GuideKernelWave extends GuideMessage {
  final int monsters;
  final int? needed;

  const GuideKernelWave(this.monsters, {this.needed});

  @override
  List<Object> get _figures => [monsters, needed ?? -1];
}
