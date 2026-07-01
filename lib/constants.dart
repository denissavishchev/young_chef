import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const kWhite = Color(0xfff6f6f6);
const kDarkBlue = Color(0xff2d435d);
const kLightBlue = Color(0xffafb9d8);
const kBlack = Color(0xff03142c);
const kOrange = Color(0xfff67f5c);

final kTextStyle = TextStyle(
    color: kDarkBlue,
    fontWeight: FontWeight.bold,
    fontSize: 24.sp,
);


final textFieldDecoration = InputDecoration(
    hintStyle: kTextStyle,
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kDarkBlue)
    ),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kDarkBlue)
    ),
    focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kOrange)
    ),
    errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kOrange)
    ),
);


final textFieldDecorationOnboarding = InputDecoration(
    hintStyle: kTextStyle,
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kOrange)
    ),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kOrange)
    ),
    focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kOrange)
    ),
    errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kOrange)
    ),
);
