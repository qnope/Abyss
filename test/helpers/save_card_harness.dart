import 'package:abyss/domain/game/save_summary.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/save/save_card.dart';
import 'package:flutter/material.dart';

/// The time save cards under test tell their dates against.
final saveCardNow = DateTime(2026, 10, 10, 10);

/// A single save card of [summary] on a themed page.
Widget saveCardApp(
  SaveSummary summary, {
  bool highlighted = false,
  VoidCallback? onTap,
  VoidCallback? onDelete,
}) => MaterialApp(
  theme: AbyssTheme.create(),
  home: Scaffold(
    body: SaveCard(
      summary: summary,
      now: saveCardNow,
      highlighted: highlighted,
      onTap: onTap ?? () {},
      onDelete: onDelete ?? () {},
    ),
  ),
);
