import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/services/language_change_provider.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/appbar.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';

class AppLanguagePage extends StatefulWidget {
  const AppLanguagePage({super.key});

  @override
  State<AppLanguagePage> createState() => _AppLanguagePageState();
}

class _AppLanguagePageState extends State<AppLanguagePage> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageChangeProvider>(context);
    final selectedLanguage = languageProvider.languagesType;

    return Scaffold(
      appBar: CommonAppBar(
        isActionsShow: false,
        isBackShow: true,
        title: S.of(context).languages,
      ),
      body: ListView.separated(
        // physics: physics,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final language = Languages.values[index];
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              languageProvider.selectLanguagesType(language);
            },
            child: Column(
              children: [
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      language.name,
                      style: AppTextStyles.medium(
                        fontSize: 18.sp,
                      ),
                    ),
                    Radio(
                      groupValue: selectedLanguage,
                      activeColor: AppColors.primaryColor,
                      value: language,
                      onChanged: (value) {
                        // if (value != null) {
                        //   languageProvider.selectLanguagesType(value);
                        // }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 17.h),
                Divider(
                  height: 0.h,
                  color: AppColors.darkInputFill,
                ),
              ],
            ),
          );

          // Container(
          //   child: CupertinoButton(
          //     onPressed: () {
          //       languageProvider.selectLanguagesType(language);
          //     },
          //     padding: EdgeInsets.zero,
          //     child: ListTile(
          //       title: Text(
          //         language.name,
          //       ),
          //       trailing: Radio(
          //         groupValue: selectedLanguage,
          //         activeColor: AppColors.primaryColor,
          //         value: language,
          //         onChanged: (value) {
          //           if (value != null) {
          //             languageProvider.selectLanguagesType(value);
          //           }
          //         },
          //       ),
          //     ),
          //   ),
          // );
        },
        separatorBuilder: (context, index) {
          return 17.s;
        },
        itemCount: Languages.values.length,
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
            CustomButton(
                onPressed: () async {
                  await languageProvider.changeLocale();
                },
                child: Text(
                  S.of(context).update,
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                    color: AppColors.white,
                  ),
                )),
            SizedBox(
              height: 16.h,
            ),
          ],
        ),
      ),
    );
  }
}
