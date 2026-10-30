import 'package:flutter/widgets.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/unit/unit_type.dart';
import 'army_place_bar.dart';
import 'army_places.dart';
import 'army_view.dart';

/// The army on its parade ground ([ArmyView]) with, floating at the
/// bottom while it serves in more than one place, the bar of its places
/// ([ArmyPlaceBar]): « Toutes » stands the whole army on the ground, a
/// place only the units it holds, the other squads empty. The green
/// « + » of the [recruitable] types shows under « Toutes » and at the
/// [recruitPlace], where recruits arrive.
///
/// The place shown is the view's own, not saved, and back to « Toutes »
/// once it holds no unit. A squad touched calls [onUnitTap] with its
/// unit and how many serve at the place shown.
class ArmyPlacesView extends StatefulWidget {
  final Map<BuildingType, Building> buildings;
  final ArmyPlaces places;

  /// The types the player can recruit at least one of this turn.
  final Set<UnitType> recruitable;

  /// The place where recruits arrive.
  final int recruitPlace;

  /// Whether a missing prerequisite keeps the barracks from being built.
  final bool barracksLocked;

  final void Function(UnitType type, int count) onUnitTap;
  final void Function(Building barracks)? onBarracksTap;

  const ArmyPlacesView({
    super.key,
    required this.buildings,
    required this.places,
    required this.recruitPlace,
    required this.onUnitTap,
    this.recruitable = const {},
    this.barracksLocked = false,
    this.onBarracksTap,
  });

  @override
  State<ArmyPlacesView> createState() => _ArmyPlacesViewState();
}

class _ArmyPlacesViewState extends State<ArmyPlacesView> {
  int? _place = ArmyPlaces.all;

  @override
  void didUpdateWidget(ArmyPlacesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final places = widget.places;
    if (!places.isSplit || !places.held.contains(_place)) {
      _place = ArmyPlaces.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = widget.places, place = _place;
    final split = places.isSplit;
    final recruiting = place == ArmyPlaces.all || place == widget.recruitPlace;
    return Stack(
      fit: StackFit.expand,
      children: [
        ArmyView(
          buildings: widget.buildings,
          counts: places.countsAt(place),
          place: place,
          recruitable: recruiting ? widget.recruitable : const {},
          barracksLocked: widget.barracksLocked,
          bottomSpace: split ? ArmyPlaceBar.room : 0,
          onUnitTap:
              (type) => widget.onUnitTap(type, places.countOf(type, place)),
          onBarracksTap: widget.onBarracksTap,
        ),
        if (split)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ArmyPlaceBar(
              places: places,
              selected: place,
              onSelected: (place) => setState(() => _place = place),
            ),
          ),
      ],
    );
  }
}
