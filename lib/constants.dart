import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const kWhite = Color(0xfff6f6f6);
const kDarkBlue = Color(0xff2d435d);
const kLightBlue = Color(0xffafb9d8);
const kOrange = Color(0xfff67f5c);

final kTextStyle = TextStyle(
    color: kDarkBlue,
    fontWeight: FontWeight.bold,
    fontSize: 12.sp,
);

final kBigTextStyle = TextStyle(
    color: kDarkBlue,
    fontWeight: FontWeight.bold,
    fontSize: 15.sp,
);

const kScreenBg = Color(0xFFF9F4F1);
const kCard = Colors.white;
const kAccent = Color(0xFFFF4D0F);
const kAccentSoft = Color(0xFFFFE6DC);
const kInk = Color(0xFF111111);
const kTrackMuted = Color(0xFFECE5E0);

final textFieldDecoration = InputDecoration(
    hintStyle: kTextStyle,
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent)
    ),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent)
    ),
    focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent)
    ),
    errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent)
    ),
);
