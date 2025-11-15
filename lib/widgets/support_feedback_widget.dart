import 'package:flutter/material.dart';

import '../core/app_export.dart';

class SupportFeedbackWidget extends StatelessWidget {
  final String messageId;
  final Function(String messageId, bool isHelpful) onFeedbackTap;

  const SupportFeedbackWidget({
    Key? key,
    required this.messageId,
    required this.onFeedbackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          Text(
            'Was this helpful?',
            style: TextStyleHelper.instance.body12RegularInter
                .copyWith(color: appTheme.gray_600),
          ),
          SizedBox(width: 12.h),
          _buildFeedbackButton(
            context,
            icon: Icons.thumb_up_outlined,
            isPositive: true,
            onTap: () => onFeedbackTap(messageId, true),
          ),
          SizedBox(width: 8.h),
          _buildFeedbackButton(
            context,
            icon: Icons.thumb_down_outlined,
            isPositive: false,
            onTap: () => onFeedbackTap(messageId, false),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(
    BuildContext context, {
    required IconData icon,
    required bool isPositive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
        decoration: BoxDecoration(
          color: appTheme.grey100,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: appTheme.gray_300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.h,
              color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
            ),
            SizedBox(width: 4.h),
            Text(
              isPositive ? 'Yes' : 'No',
              style: TextStyleHelper.instance.body12RegularInter.copyWith(
                color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}