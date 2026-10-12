import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

/// Ingredients drop one after another into a pot that hops on every landing,
/// with a status line that rotates underneath.
class CookingLoader extends StatefulWidget {
  const CookingLoader({super.key});

  @override
  State<CookingLoader> createState() => _CookingLoaderState();
}

class _CookingLoaderState extends State<CookingLoader>
    with SingleTickerProviderStateMixin {
  static const _ingredients = ['🥕', '🍅', '🧀', '🥬'];
  static const _xOffsets = [-30.0, 20.0, -8.0, 30.0];
  static const _steps = ['loadingStep1', 'loadingStep2', 'loadingStep3'];
  static const _gap = 0.22; // cycle fraction between two drops
  static const _fall = 0.26; // cycle fraction one drop takes

  /// Black-and-white emoji with a bit of extra contrast, to match the outline UI.
  static const _grayscale = ColorFilter.matrix([
    0.39, 0.77, 0.08, 0, -20, //
    0.39, 0.77, 0.08, 0, -20,
    0.39, 0.77, 0.08, 0, -20,
    0, 0, 0, 1, 0,
  ]);

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();
  late final Timer _stepTimer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _stepTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (mounted) setState(() => _step = (_step + 1) % _steps.length);
    });
  }

  @override
  void dispose() {
    _stepTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Pot squash/stretch: a short bump after each landing.
  double _bump(double t) {
    var bump = 0.0;
    for (var i = 0; i < _ingredients.length; i++) {
      final since = t - (i * _gap + _fall);
      if (since >= 0 && since < 0.08) {
        bump += math.sin(since / 0.08 * math.pi);
      }
    }
    return bump.clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        SizedBox(
          width: 160,
          height: 180,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final bump = _bump(t);
              return Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // Behind the pot, so landed ingredients vanish into it.
                  for (var i = 0; i < _ingredients.length; i++) _drop(i, t),
                  Positioned(
                    bottom: 0,
                    child: Transform.translate(
                      offset: Offset(0, -10 * bump),
                      child: Transform.scale(
                        scale: 1 + 0.06 * bump,
                        alignment: Alignment.bottomCenter,
                        child: CustomPaint(
                          size: const Size(118, 106),
                          painter: const _PotPainter(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Text(
            _steps[_step].tr(),
            key: ValueKey(_step),
            style: kBigTextStyle.copyWith(shadows: kIconShadow),
          ),
        ),
      ],
    );
  }

  Widget _drop(int i, double t) {
    final p = ((t - i * _gap) / _fall).clamp(0.0, 1.0);
    if (t < i * _gap || p >= 1) return const SizedBox.shrink();
    final eased = Curves.easeIn.transform(p);
    // From above the box down behind the pot, shrinking as it sinks in.
    final y = -10 + eased * 115;
    final scale = p < 0.8 ? 1.0 : 1 - (p - 0.8) / 0.2 * 0.7;
    return Positioned(
      top: y,
      child: Transform.translate(
        offset: Offset(_xOffsets[i] * (1 - eased * 0.8), 0),
        child: Transform.rotate(
          angle: (i.isEven ? -1 : 1) * eased * 0.6,
          child: Transform.scale(
            scale: scale,
            child: ColorFiltered(
              colorFilter: _grayscale,
              child: Text(
                _ingredients[i],
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined pot with a soft glow.
class _PotPainter extends CustomPainter {
  const _PotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(4, 0); // room for the glow around the handles
    final body = RRect.fromLTRBAndCorners(
      16,
      18,
      94,
      84,
      bottomLeft: const Radius.circular(30),
      bottomRight: const Radius.circular(30),
    );
    final rim = RRect.fromLTRBR(8, 10, 102, 24, const Radius.circular(7));
    final handles = [
      RRect.fromLTRBR(0, 30, 17, 42, const Radius.circular(6)),
      RRect.fromLTRBR(93, 30, 110, 42, const Radius.circular(6)),
    ];
    final shape = Path()
      ..addRRect(body)
      ..addRRect(rim);
    for (final h in handles) {
      shape.addRRect(h);
    }
    canvas.drawPath(
      shape.shift(const Offset(2, 4)),
      Paint()
        ..color = kShadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final line = Paint()..color = kLine;
    for (final h in handles) {
      canvas.drawRRect(h, line);
    }
    final stroke = Paint()
      ..color = kLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = kLineWidth + 1
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = Colors.white;
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);
    canvas.drawRRect(rim, fill);
    canvas.drawRRect(rim, stroke);
  }

  @override
  bool shouldRepaint(_PotPainter old) => false;
}
