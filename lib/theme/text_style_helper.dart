import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      );

  TextStyle get title16SemiBoldInter => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14MediumInter => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: appTheme.white_A700,
      );

  TextStyle get body14RegularInter => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: appTheme.black_900,
      );

  TextStyle get body12RegularInter => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      );
}
