import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class NotchNavItem {
  const NotchNavItem({required this.icon, required this.activeIcon});

  final IconData icon;
  final IconData activeIcon;
}

/// Outlined floating bar with a circular notch that flows under the selected
/// item like a wave, carrying an outlined ring with the item's icon.
class NotchNavBar extends StatefulWidget {
  const NotchNavBar({
    super.key,
    required this.items,
    required this.position,
    required this.onSelected,
  });

  final List<NotchNavItem> items;

  /// Fractional tab position (e.g. a [PageController]'s page), so the notch
  /// follows swipes and page animations frame by frame.
  final ValueListenable<double> position;
  final ValueChanged<int> onSelected;

  static const double barHeight = 51;
  static const double lift = 24;
  static const double bubble = 44;
  static const double bubbleCenterY = 0;
  static const double notchRadius = 28;
  static const double cornerRadius = 18;
  // Keeps the notch clear of the rounded corners on the first/last tab.
  static const double edgeInset = 24;
  // Pushes the outer tabs this far towards the edges of the bar.
  static const double edgeShift = 10;

  @override
  State<NotchNavBar> createState() => _NotchNavBarState();
}

class _NotchNavBarState extends State<NotchNavBar> {
  double _lastT = 0;
  double _dir = 1;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, NotchNavBar.lift + 8, 10, 12),
          child: SizedBox(
            height: NotchNavBar.barHeight,
            child: LayoutBuilder(
              builder: (context, box) {
                final mid = (items.length - 1) / 2;
                double shift(double pos) =>
                    mid == 0 ? 0 : (pos - mid) / mid * NotchNavBar.edgeShift;
                final itemW =
                    (box.maxWidth - 2 * NotchNavBar.edgeInset) / items.length;
                return AnimatedBuilder(
                  animation: widget.position,
                  builder: (context, _) {
                    final t = widget.position.value.clamp(
                      0.0,
                      items.length - 1.0,
                    );
                    if ((t - _lastT).abs() > 1e-4) {
                      _dir = (t - _lastT).sign;
                      _lastT = t;
                    }
                    final cx =
                        NotchNavBar.edgeInset + itemW * (t + 0.5) + shift(t);
                    // 0 on a tab, 1 halfway between two tabs.
                    final wave = math.sin(math.pi * (t - t.floorToDouble()));
                    final dir = _dir;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _BarPainter(cx, wave, dir),
                          ),
                        ),
                        for (var i = 0; i < items.length; i++)
                          Positioned(
                            left:
                                NotchNavBar.edgeInset +
                                itemW * i +
                                shift(i.toDouble()),
                            width: itemW,
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => widget.onSelected(i),
                              child: Opacity(
                                opacity: (t - i).abs().clamp(0.0, 1.0),
                                child: Icon(
                                  items[i].icon,
                                  color: kLine,
                                  size: 28,
                                  shadows: kIconShadow,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: cx - NotchNavBar.bubble / 2,
                          top:
                              NotchNavBar.bubbleCenterY -
                              NotchNavBar.bubble / 2 -
                              3 * wave,
                          child: IgnorePointer(
                            child: Container(
                              width: NotchNavBar.bubble,
                              height: NotchNavBar.bubble,
                              decoration: BoxDecoration(
                                color: kBg,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: kLine,
                                  width: kLineWidth,
                                ),
                              ),
                              child: Icon(
                                items[t.round().clamp(0, items.length - 1)]
                                    .activeIcon,
                                color: kLine,
                                size: 28,
                                shadows: kIconShadow,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.cx, this.wave, this.dir);

  final double cx;
  final double wave;
  final double dir;

  @override
  void paint(Canvas canvas, Size size) {
    const phi = -0.35; // where the arc hands over to the soft shoulder
    const baseFillet = 16.0;
    final cy = NotchNavBar.bubbleCenterY;
    // The circle stretches sideways and flattens while it travels.
    final rx = NotchNavBar.notchRadius * (1 + 0.3 * wave);
    final ry = NotchNavBar.notchRadius * (1 - 0.1 * wave);
    // The trailing shoulder is dragged out into a long, smooth tail.
    var left = baseFillet * (dir > 0 ? 1 + 3 * wave : 1 - 0.3 * wave);
    var right = baseFillet * (dir < 0 ? 1 + 3 * wave : 1 - 0.3 * wave);

    final pl = Offset(
      cx + rx * math.cos(math.pi + phi),
      cy + ry * math.sin(math.pi + phi),
    );
    final pr = Offset(cx + rx * math.cos(-phi), cy + ry * math.sin(-phi));
    final k = pl.dy / (ry * math.cos(phi));
    final ctrlL = Offset(pl.dx + rx * math.sin(phi) * k, 0);
    final ctrlR = Offset(pr.dx - rx * math.sin(phi) * k, 0);

    // Never let the shoulders run into the rounded corners of the bar.
    // Keep a short straight stretch between the corner and the shoulder.
    const edge = NotchNavBar.cornerRadius + 8;
    left = left.clamp(0.0, math.max(0.0, ctrlL.dx - edge));
    right = right.clamp(0.0, math.max(0.0, size.width - edge - ctrlR.dx));

    final notch = Path()
      ..moveTo(ctrlL.dx - left, -10)
      ..lineTo(ctrlL.dx - left, 0)
      ..quadraticBezierTo(ctrlL.dx, 0, pl.dx, pl.dy)
      ..arcTo(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        math.pi + phi,
        -(math.pi + 2 * phi),
        false,
      )
      ..quadraticBezierTo(ctrlR.dx, 0, ctrlR.dx + right, 0)
      ..lineTo(ctrlR.dx + right, -10)
      ..close();

    final bar = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(NotchNavBar.cornerRadius),
        ),
      );
    final shape = Path.combine(PathOperation.difference, bar, notch);
    // Keep the glow outside of the bar.
    canvas.save();
    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(
          Rect.fromLTWH(-100, -100, size.width + 200, size.height + 300),
        ),
        shape,
      ),
    );
    canvas.drawPath(
      shape.shift(const Offset(0, 4)),
      Paint()
        ..color = kGlow.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();
    canvas.drawPath(shape, Paint()..color = kBg);
    canvas.drawPath(
      shape,
      Paint()
        ..color = kLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = kLineWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.cx != cx || old.wave != wave || old.dir != dir;
}
