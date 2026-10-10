import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final kTextStyle = TextStyle(
  color: kLine,
  fontWeight: FontWeight.bold,
  fontSize: 12.sp,
);

final kBigTextStyle = TextStyle(
  color: kLine,
  fontWeight: FontWeight.bold,
  fontSize: 15.sp,
);

// Outline UI palette (recipe screen + bottom bar).
const kBg = Color(0xFFDCE4EC);
const kLine = Color(0xFF16171B);
const kGlow = Color(0xFFB4C2E0);
const kLineWidth = 2.5;

/// Tile with a thick dark outline and a soft glow, the base of this UI
/// (same look as the bottom bar). Fill defaults to the screen background.
BoxDecoration outlineDecoration({
  double radius = 28,
  Color color = kBg,
  bool circle = false,
}) => BoxDecoration(
  color: color,
  shape: circle ? BoxShape.circle : BoxShape.rectangle,
  borderRadius: circle ? null : BorderRadius.circular(radius),
  border: Border.all(color: kLine, width: kLineWidth),
  boxShadow: [
    BoxShadow(
      color: kGlow.withValues(alpha: 0.8),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

final textFieldDecoration = InputDecoration(
  hintStyle: kTextStyle,
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
  ),
  focusedErrorBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
  ),
  errorBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
  ),
);

/// Black-on-glow slider look shared by the screens.
SliderThemeData outlineSliderTheme() => SliderThemeData(
  trackHeight: 8,
  thumbColor: kLine,
  rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 11),
  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
  activeTrackColor: kLine,
  inactiveTrackColor: kGlow,
  rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
  tickMarkShape: SliderTickMarkShape.noTickMark,
  activeTickMarkColor: Colors.transparent,
  inactiveTickMarkColor: Colors.transparent,
  valueIndicatorColor: kLine,
  showValueIndicator: ShowValueIndicator.onDrag,
  overlayColor: kLine.withValues(alpha: 0.12),
);

/// Soft glow under icons, same as the bottom bar's.
const kIconShadow = [Shadow(color: kGlow, blurRadius: 6, offset: Offset(2, 4))];
