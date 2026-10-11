import 'package:flutter/material.dart';

import '../../../domain/objective/tip/tip.dart';
import '../../extensions/tip_id_extensions.dart';
import '../../extensions/tip_texts.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/illustrated_card.dart';

/// Opens [tips] as one stack of cards; completes once it is closed.
Future<void> showTipStack(BuildContext context, List<Tip> tips) =>
    showDialog<void>(context: context, builder: (_) => TipStack(tips: tips));

/// Dialog of the « première fois » tips that arrive together: the card on
/// top is read while the next ones peek out behind it. « Suivant » or a
/// swipe goes through them, the last card closes the stack.
class TipStack extends StatefulWidget {
  final List<Tip> tips;

  const TipStack({super.key, required this.tips});

  @override
  State<TipStack> createState() => _TipStackState();
}

class _TipStackState extends State<TipStack> {
  static const double _peek = 10;
  static const double _swipeSpeed = 200;
  int _index = 0;

  int get _last => widget.tips.length - 1;

  void _go(int index) {
    if (index < 0 || index > _last) return;
    setState(() => _index = index);
  }

  void _onSwipe(DragEndDetails details) {
    final speed = details.primaryVelocity ?? 0;
    if (speed <= -_swipeSpeed) _go(_index + 1);
    if (speed >= _swipeSpeed) _go(_index - 1);
  }

  @override
  Widget build(BuildContext context) {
    final behind = _last - _index;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GestureDetector(
        onHorizontalDragEnd: _onSwipe,
        child: Padding(
          padding: EdgeInsets.only(top: _peek * behind.clamp(0, 2)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var k = behind.clamp(0, 2); k >= 1; k--) _behind(k),
              _front(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _behind(int depth) => Positioned.fill(
    top: -_peek * depth,
    left: _peek * depth,
    right: _peek * depth,
    child: DecoratedBox(
      key: const ValueKey('tip-stack-behind'),
      decoration: BoxDecoration(
        color: depth == 1 ? AbyssColors.oceanFloor : AbyssColors.trench,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AbyssColors.biolumCyan.withValues(alpha: 0.2),
        ),
      ),
    ),
  );

  Widget _front(BuildContext context) {
    final l10n = context.l10n;
    final text = widget.tips[_index].id.text(l10n);
    final lone = widget.tips.length == 1;
    final closes = _index == _last;
    return Material(
      color:
          Theme.of(context).dialogTheme.backgroundColor ??
          Theme.of(context).colorScheme.surface,
      shape: Theme.of(context).dialogTheme.shape,
      clipBehavior: Clip.antiAlias,
      child: IllustratedCardBody(
        illustration: widget.tips[_index].id.illustration,
        title: text.title,
        lines: text.lines,
        actions: [
          if (!lone)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_index + 1} / ${widget.tips.length}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
              ),
            ),
          ElevatedButton(
            onPressed:
                closes ? () => Navigator.pop(context) : () => _go(_index + 1),
            child: Text(closes ? l10n.commonGotIt : l10n.commonNext),
          ),
        ],
      ),
    );
  }
}
