import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/appbar.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/text_fields.dart';

class ReportUserPage extends StatefulWidget {
  const ReportUserPage({super.key, required this.onReport});
  final Function(String, String) onReport;
  @override
  State<ReportUserPage> createState() => _ReportUserPageState();
}

class _ReportUserPageState extends State<ReportUserPage> {
  String selectedReason = "";
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reportReasons = [
      {"key": "Spam", "label": S.of(context).reportReasonSpam},
      {"key": "Harassment", "label": S.of(context).reportReasonHarassment},
      {
        "key": "Inappropriate Content",
        "label": S.of(context).reportReasonInappropriateContent
      },
      {"key": "Fake Profile", "label": S.of(context).reportReasonFakeProfile},
      {"key": "Scam or Fraud", "label": S.of(context).reportReasonScamOrFraud},
      {
        "key": "Violence or Threats",
        "label": S.of(context).reportReasonViolenceOrThreats
      },
      {"key": "Hate Speech", "label": S.of(context).reportReasonHateSpeech},
      {"key": "other", "label": S.of(context).other}
    ];
    return Scaffold(
      appBar: CommonAppBar(
        isActionsShow: false,
        isBackShow: true,
        title: S.of(context).reportUserTitle,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            S.of(context).reportUserReasonLabel,
            style: AppTextStyles.medium(),
          ),
          16.h.s, Divider(height: 1.h, color: AppColors.darkInputFill),
          16.h.s,
          ...reportReasons.map((reason) => RadioListTile<String>(
                enableFeedback: true,
                title: Text(
                  reason["label"]!,
                  style: AppTextStyles.medium(),
                ),
                value: reason["key"]!,
                splashRadius: 0.0,
                groupValue: selectedReason,
                hoverColor: Colors.transparent,
                activeColor: AppColors.buttonColor,
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      selectedReason = value;
                    }
                  });
                },
              )),

          SizedBox(height: 16.h),
          Divider(height: 1.h, color: AppColors.darkInputFill),
          SizedBox(height: 16.h),

          // Description Field
          Text(
            S.of(context).reportUserDescriptionLabel,
            style: AppTextStyles.medium(),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: descriptionController,
            maxLines: 4,
            label: S.of(context).reportUserDescriptionHint,
            textInputAction: TextInputAction.done,
            maxLength: 300,
          ),

          SizedBox(height: 16.h),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBarButton(
      //   title: S.of(context).submit,
      //   onPressed: () async {
      //     await languageProvider.changeLocale();
      //   },
      // ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            left: 32.w, right: 32.w, bottom: Platform.isIOS ? 32.h : 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 16.h,
            ),
            CustomButton(
                onPressed: () async {
                  if (selectedReason.isNotEmpty) {
                    widget.onReport(
                        selectedReason, descriptionController.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  S.of(context).reportUserButton,
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                    color: AppColors.white,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
