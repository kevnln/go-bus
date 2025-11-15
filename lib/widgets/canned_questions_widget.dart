import 'package:flutter/material.dart';

import '../core/app_export.dart';

class CannedQuestionsWidget extends StatelessWidget {
  final Map<String, List<String>> categorizedQuestions;
  final Function(String) onQuestionTap;
  final VoidCallback onClose;

  const CannedQuestionsWidget({
    Key? key,
    required this.categorizedQuestions,
    required this.onQuestionTap,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.h),
          topRight: Radius.circular(20.h),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.black_900.withAlpha(26),
            blurRadius: 10.h,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildQuestionsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: appTheme.gray_300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Suggested Questions',
              style: TextStyleHelper.instance.title16SemiBoldInter
                  .copyWith(color: appTheme.black_900),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(8.h),
              child: Icon(
                Icons.close,
                size: 20.h,
                color: appTheme.gray_600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categorizedQuestions.entries.map((category) {
          return _buildCategory(context, category.key, category.value);
        }).toList(),
      ),
    );
  }

  Widget _buildCategory(
      BuildContext context, String categoryName, List<String> questions) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
            style: TextStyleHelper.instance.body14MediumInter
                .copyWith(color: appTheme.black_900),
          ),
          SizedBox(height: 12.h),
          ...questions.map((question) {
            return _buildQuestionItem(context, question);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(BuildContext context, String question) {
    return GestureDetector(
      onTap: () => onQuestionTap(question),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.h),
        decoration: BoxDecoration(
          color: appTheme.grey200,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(
            color: appTheme.gray_300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: TextStyleHelper.instance.body14RegularInter
                    .copyWith(color: appTheme.black_900),
              ),
            ),
            SizedBox(width: 8.h),
            Icon(
              Icons.arrow_forward_ios,
              size: 12.h,
              color: appTheme.gray_600,
            ),
          ],
        ),
      ),
    );
  }
}