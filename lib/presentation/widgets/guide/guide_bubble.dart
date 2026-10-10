import 'package:flutter/material.dart';

import '../../../domain/objective/guide/guide_advice.dart';
import '../../extensions/guide_message_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

/// The guide of the tutorial, the octopus archivist, and what it says, at
/// the bottom of the game screen. Its button hides it until the advice
/// changes. Shows nothing without [advice].
class GuideBubble extends StatefulWidget {
  static const portraitPath = 'assets/icons/guide/octopus_archivist.svg';
  static const portraitSize = 64.0;

  final GuideAdvice? advice;

  const GuideBubble({super.key, required this.advice});

  @override
  State<GuideBubble> createState() => _GuideBubbleState();
}

class _GuideBubbleState extends State<GuideBubble> {
  bool _dismissed = false;

  @override
  void didUpdateWidget(GuideBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.advice?.message != widget.advice?.message) {
      _dismissed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final advice = widget.advice;
    if (advice == null || _dismissed) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
      decoration: BoxDecoration(
        color: AbyssColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AbyssColors.biolumCyan.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AbyssColors.biolumCyan.withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RasterSvg(
            assetPath: GuideBubble.portraitPath,
            size: GuideBubble.portraitSize,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advice.message.text(context.l10n),
                  style: text.bodyMedium?.copyWith(
                    color: AbyssColors.onSurface,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _dismissed = true),
                    child: Text(context.l10n.commonGotIt),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
