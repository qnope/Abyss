import 'package:flutter/material.dart';

import '../../../domain/history/history_entry.dart';
import '../../screens/game/fight/base_assault_summary_screen.dart';

/// Opens the report of a [BaseAssaultEntry], read from the side of the
/// player whose history it is.
Future<void> openAssaultSummaryFromEntry(
  BuildContext context,
  BaseAssaultEntry entry,
) => BaseAssaultSummaryScreen.open(context, entry);
