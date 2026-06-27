import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const kDarkGrey = Color(0xff545766);
const kGrey = Color(0xff81899b);
const kLightGrey = Color(0xffc7cbd7);
const kBlue = Color(0xff4b75b1);
const kWhite = Color(0xfff3f0e0);
const kDarkWhite = Color(0xffeff4fa);
const kRed = Color(0xffb23c38);
const kLightGreen = Color(0xffc7dc70);
const kGreen = Color(0xff6ca100);
const kDarkGreen = Color(0xff005400);
const kOrange = Color(0xfff56707);
const kLightBlue = Color(0xff32b1e1);
const kDarkBlue = Color(0xff5c75b8);
const kPurple = Color(0xff7951a4);

final kTextStyle = TextStyle(
    color: kBlue,
    fontWeight: FontWeight.bold,
    fontSize: 24.sp,
);


final textFieldDecoration = InputDecoration(
    hintStyle: kTextStyle,
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kBlue)
    ),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kBlue)
    ),
    focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kRed)
    ),
    errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kRed)
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
        borderSide: BorderSide(color: kRed)
    ),
    errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kRed)
    ),
);
