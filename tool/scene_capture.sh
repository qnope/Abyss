#!/usr/bin/env bash
# Renders the 3D prototype, the app's screens and the UI kit for review, as a
# phone held upright shows them (390 x 844 points at 2x):
#   tool/scene_capture.sh [out dir] [scene | app | base | army | map | fight | turn | tech | threat | event | post | faction | guide | kit]
# With no scene, it writes default.png, rotated.png, close.png and top.png from
# the views of godot/tool/scene/capture.gd, then app_menu_empty.png,
# app_menu.png, app_new_game.png, app_saves.png, app_story.png, app_game.png,
# app_game_settings.png, app_game_resource.png and app_game_tech.png
# from godot/tool/scene/app_capture.gd, then base_standins.png, base_close.png,
# base_models.png and base_sheet_upgrade.png, _degraded.png, _citadel.png and
# _locked.png from godot/tool/scene/base_capture.gd, then army_parade.png,
# army_places.png, army_close.png, army_sheet_unit.png, _recruit.png and
# _locked.png, army_reinforcement.png, army_picker.png and
# army_barracks_empty.png from godot/tool/scene/army_capture.gd, then map_level1.png, _level2.png, _level3.png,
# map_close.png, map_exploration_sheet.png, _storm.png, map_treasure_sheet.png, map_found.png and
# map_visited.png from godot/tool/scene/map_capture.gd, then fight_lair_sheet.png, fight_lair_generic.png,
# fight_selection.png, fight_selection_en.png, fight_refused.png, fight_report_won.png, fight_report_won_end.png,
# fight_map_beaten.png and fight_report_lost.png from godot/tool/scene/fight_capture.gd, then kit_a.png, kit_b.png, kit_b_en.png,
# kit_dialog.png, kit_sheet.png and kit_page.png from
# godot/tool/scene/kit_capture.gd, then turn_confirm.png, turn_summary.png,
# turn_summary_en.png, turn_victory.png and turn_defeat.png from
# godot/tool/scene/turn_capture.gd, then tech_new.png, tech_tree.png,
# tech_tree_en.png, tech_node.png, tech_choice.png, tech_done.png,
# tech_blocked.png and tech_branch.png from godot/tool/scene/tech_capture.gd, then
# threat_bars.png, _bars_raid, _confirm, _summary, _summary_announced, _raid_report,
# _raid_report_end, _predators_report, _raid_report_won, _wave_report and _wave_report_en from
# godot/tool/scene/threat_capture.gd, then
# event_strip.png, event_card.png, _en.png and _trade.png, history_settings.png, history_all.png,
# _combat.png and _en.png, export_dialog.png, _copied.png and _old.png from
# godot/tool/scene/event_capture.gd, then post_sheet_guarded.png, _selection, _report, _report_end,
# _sheet_held, _sheet_held_en, _descent, _descent_done, _rival, post_kernel_guarded, _kernel_report,
# _kernel_held, post_garrison_picker and post_kernel_garrisoned from godot/tool/scene/post_capture.gd,
# faction_sheet.png, _sheet_intel, _selection, _report_won, _report_lost, _ranking and _attack_summary
# from godot/tool/scene/faction_capture.gd, then guide_first.png, _tab, _tech, _cell, _tip, _objectives,
# _summary and _summary_en from godot/tool/scene/guide_capture.gd,
# and prints each view's draw calls and primitives. With a scene (res://...tscn) only the first, on that scene; with
# `app` only the second; with `base` only the third; with `army` only the army tab's; with `map` only the map's; with `fight` only the fights of the lairs; with `kit` only the kit's;
# with `turn` only the end of a turn and of a game; with `tech` only the research; with `threat` only the raid, guardians and kraken wave; with `event` only the events, the history and the replay export; with `post` only the posts and the Volcanic Kernel; with `faction` only the rival factions; with `guide` only the tutorial. The out dir defaults to
# /tmp/scene_capture: never write the renders in the repo. Godot draws with
# its Compatibility renderer (the web's) in a virtual X display (xvfb-run), in
# software: its frame rate means nothing. GODOT names the engine binary.
set -euo pipefail
cd "$(dirname "$0")/.."
out="${1:-/tmp/scene_capture}"
[[ $out == /* ]] || out="$PWD/$out"
which="${2:-}"
godot="${GODOT:-godot}"
"$godot" --headless --path godot --import > /dev/null 2>&1

# capture <script> [scene]: runs a capture script in the virtual display, and
# stops it after GODOT_CAPTURE_TIMEOUT seconds (120 by default).
limit=()
if command -v timeout > /dev/null; then
  limit=(timeout --kill-after=10 "${GODOT_CAPTURE_TIMEOUT:-120}")
fi
capture() {
  ${limit[@]+"${limit[@]}"} xvfb-run -a -s "-screen 0 1280x1800x24" "$godot" --path godot --audio-driver Dummy \
    --rendering-method gl_compatibility --rendering-driver opengl3 --resolution 780x1688 \
    --script "$1" -- "$out" ${2:+"$2"} 2>&1 | grep -vE "^(Godot Engine|OpenGL API|$)" || true
}

if [[ $which != kit && $which != app && $which != base && $which != army && $which != map && $which != fight && $which != turn && $which != tech && $which != threat && $which != event && $which != post && $which != faction && $which != guide ]]; then
  capture res://tool/scene/capture.gd "$which"
  [[ -f $out/default.png ]] || { echo "The scene did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == app ]]; then
  capture res://tool/scene/app_capture.gd
  [[ -f $out/app_game_tech.png ]] || { echo "The app did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == base ]]; then
  capture res://tool/scene/base_capture.gd
  [[ -f $out/base_sheet_locked.png ]] || { echo "The base did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == army ]]; then
  capture res://tool/scene/army_capture.gd
  [[ -f $out/army_barracks_empty.png ]] || { echo "The army tab did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == map ]]; then
  capture res://tool/scene/map_capture.gd
  [[ -f $out/map_visited.png ]] || { echo "The map did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == fight ]]; then
  capture res://tool/scene/fight_capture.gd
  [[ -f $out/fight_report_lost.png ]] || { echo "The fights did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == kit ]]; then
  capture res://tool/scene/kit_capture.gd
  [[ -f $out/kit_page.png ]] || { echo "The UI kit did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == turn ]]; then
  capture res://tool/scene/turn_capture.gd
  [[ -f $out/turn_defeat.png ]] || { echo "The end of a turn did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == tech ]]; then
  capture res://tool/scene/tech_capture.gd
  [[ -f $out/tech_branch.png ]] || { echo "The research did not render." >&2; exit 1; }
fi
if [[ -z $which || $which == threat ]]; then
  capture res://tool/scene/threat_capture.gd
  [[ -f $out/threat_wave_report_en.png ]] || { echo "The threats did not render." >&2; exit 1; }
fi

if [[ -z $which || $which == event ]]; then
  capture res://tool/scene/event_capture.gd
  [[ -f $out/export_old.png ]] || { echo "The events did not render." >&2; exit 1; }
fi

if [[ -z $which || $which == post ]]; then
  capture res://tool/scene/post_capture.gd
  [[ -f $out/post_kernel_garrisoned.png ]] || { echo "The posts did not render." >&2; exit 1; }
fi

if [[ -z $which || $which == faction ]]; then
  capture res://tool/scene/faction_capture.gd
  [[ -f $out/faction_attack_summary.png ]] || { echo "The factions did not render." >&2; exit 1; }
fi

if [[ -z $which || $which == guide ]]; then
  capture res://tool/scene/guide_capture.gd
  [[ -f $out/guide_summary_en.png ]] || { echo "The tutorial did not render." >&2; exit 1; }
fi
