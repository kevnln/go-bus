import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomChatAppBar - A reusable AppBar component designed for chat interfaces
 * 
 * Features:
 * - Back navigation with customizable icon
 * - Profile image display with circular styling
 * - Title and subtitle text with custom styling
 * - Bottom border decoration
 * - Responsive design with SizeUtils
 * - Theme-aware color handling
 * 
 * @param title - Main heading text (required)
 * @param subtitle - Secondary status text (optional)
 * @param profileImage - Path to profile/avatar image (optional)
 * @param backIcon - Path to back navigation icon (optional)
 * @param onBackPressed - Callback function for back button tap (optional)
 * @param showSubtitle - Controls subtitle visibility (optional)
 * @param titleColor - Color for the main title text (optional)
 * @param subtitleColor - Color for the subtitle text (optional)
 * @param backgroundColor - AppBar background color (optional)
 * @param borderColor - Bottom border color (optional)
 */
class CustomChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomChatAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.profileImage,
    this.backIcon,
    this.onBackPressed,
    this.showSubtitle,
    this.titleColor,
    this.subtitleColor,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  /// Main heading text displayed in the AppBar
  final String title;

  /// Secondary status text shown below the title
  final String? subtitle;

  /// Path to the profile/avatar image
  final String? profileImage;

  /// Path to the back navigation icon
  final String? backIcon;

  /// Callback function triggered when back button is tapped
  final VoidCallback? onBackPressed;

  /// Controls whether to show the subtitle
  final bool? showSubtitle;

  /// Color for the main title text
  final Color? titleColor;

  /// Color for the subtitle text
  final Color? subtitleColor;

  /// Background color of the AppBar
  final Color? backgroundColor;

  /// Color for the bottom border
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? appTheme.whiteCustom,
      elevation: 0,
      toolbarHeight: 56.h,
      title: _buildAppBarContent(context),
      titleSpacing: 0,
      bottom: _buildBottomBorder(),
    );
  }

  Widget _buildAppBarContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 6.h),
      child: Row(
        children: [
          _buildBackButton(context),
          SizedBox(width: 12.h),
          _buildProfileImage(),
          SizedBox(width: 8.h),
          _buildTextContent(),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
      child: CustomImageView(
        imagePath: backIcon ?? ImageConstant.imgIconChevronLeft,
        height: 24.h,
        width: 24.h,
      ),
    );
  }

  Widget _buildProfileImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.h),
      child: CustomImageView(
        imagePath: profileImage ?? ImageConstant.imgProfileImage,
        height: 32.h,
        width: 32.h,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTextContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyleHelper.instance.title16SemiBoldInter
                .copyWith(color: titleColor ?? Color(0xFF000000), height: 1.25),
            overflow: TextOverflow.ellipsis,
          ),
          if ((showSubtitle ?? true) && subtitle != null) ...[
            SizedBox(height: 3.h),
            Text(
              subtitle!,
              style: TextStyleHelper.instance.body12RegularInter.copyWith(
                  color: subtitleColor ?? Color(0x7F000000), height: 1.25),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  PreferredSizeWidget _buildBottomBorder() {
    return PreferredSize(
      preferredSize: Size.fromHeight(1.h),
      child: Container(
        height: 1.h,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: borderColor ?? Color(0xFFE6E6E6),
              width: 1.h,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h + 1.h);
}
