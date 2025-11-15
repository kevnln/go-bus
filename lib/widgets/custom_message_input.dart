import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomMessageInput - A reusable message input field component with microphone icon
 * 
 * This component provides a styled text input field specifically designed for messaging
 * interfaces. It includes a microphone icon on the right side and supports form validation.
 * 
 * @param placeholder - The hint text displayed when the field is empty
 * @param controller - TextEditingController for managing the input text
 * @param validator - Function for form validation
 * @param onChanged - Callback function triggered when text changes
 * @param keyboardType - The type of keyboard to display
 * @param enabled - Whether the input field is enabled or disabled
 * @param onMicTap - Callback function for microphone icon tap
 */
class CustomMessageInput extends StatelessWidget {
  CustomMessageInput({
    Key? key,
    this.placeholder,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.enabled,
    this.onMicTap,
  }) : super(key: key);

  /// The hint text displayed when the field is empty
  final String? placeholder;

  /// TextEditingController for managing the input text
  final TextEditingController? controller;

  /// Function for form validation
  final String? Function(String?)? validator;

  /// Callback function triggered when text changes
  final Function(String)? onChanged;

  /// The type of keyboard to display
  final TextInputType? keyboardType;

  /// Whether the input field is enabled or disabled
  final bool? enabled;

  /// Callback function for microphone icon tap
  final VoidCallback? onMicTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType ?? TextInputType.text,
        enabled: enabled ?? true,
        style: TextStyleHelper.instance.body14RegularInter,
        decoration: InputDecoration(
          hintText: placeholder ?? "Message...",
          hintStyle: TextStyleHelper.instance.body14RegularInter
              .copyWith(color: appTheme.gray_600),
          filled: true,
          fillColor: appTheme.white_A700,
          contentPadding: EdgeInsets.only(
            top: 10.h,
            bottom: 10.h,
            left: 16.h,
            right: 16.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.gray_300_01,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.gray_300_01,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.gray_300_01,
              width: 1,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.gray_300_01,
              width: 1,
            ),
          ),
          suffixIcon: GestureDetector(
            onTap: onMicTap,
            child: Container(
              padding: EdgeInsets.all(12.h),
              child: CustomImageView(
                imagePath: ImageConstant.imgIconMic,
                height: 24.h,
                width: 24.h,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
