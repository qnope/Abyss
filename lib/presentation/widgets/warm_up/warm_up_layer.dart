import 'package:flutter/widgets.dart';

/// Paints [pages] once each, hidden under [child], after [load] completes.
///
/// The first time something is drawn the engine compiles its shaders,
/// rasterizes its glyphs and builds the mipmaps of its images: a visible
/// hitch. Drawing samples behind the opaque screen in front of them pays
/// those costs up front, so the real screens are smooth from their first
/// frame. Each page is painted for one frame, then the layer is removed.
class WarmUpLayer extends StatefulWidget {
  final Future<void> Function() load;
  final List<WidgetBuilder> pages;
  final Widget child;

  const WarmUpLayer({
    super.key,
    required this.load,
    required this.pages,
    required this.child,
  });

  @override
  State<WarmUpLayer> createState() => _WarmUpLayerState();
}

class _WarmUpLayerState extends State<WarmUpLayer> {
  /// Index of the page painted this frame; null before loading or once done.
  int? _page;

  @override
  void initState() {
    super.initState();
    // Starts after the first frame so the visible screen shows at once.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    try {
      await widget.load();
    } catch (_) {
      return; // Screens then load their art lazily.
    }
    if (mounted && widget.pages.isNotEmpty) _show(0);
  }

  void _show(int page) {
    setState(() => _page = page < widget.pages.length ? page : null);
    if (_page == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _show(page + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        if (page != null)
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: Builder(builder: widget.pages[page]),
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}
