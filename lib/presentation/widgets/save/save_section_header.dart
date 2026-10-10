import 'package:flutter/widgets.dart';

import '../../theme/abyss_text_theme.dart';

/// Small spaced capitals above a group of saves, such as « EN COURS ».
class SaveSectionHeader extends StatelessWidget {
  final String label;

  const SaveSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Text(label.toUpperCase(), style: AbyssTextTheme.sectionLabel),
    );
  }
}
