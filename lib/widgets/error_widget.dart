import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({
    super.key,
    this.onRefresh,
    required this.errorMessage,
    this.subErrorMessage,
  });
  final void Function()? onRefresh;
  final String errorMessage;
  final String? subErrorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //   Center(
          //   child: Text(
          //     errorMessage.isEmpty
          //         ? S.of(context).opps
          //         : errorMessage,
          //     style: AppTextStyle.InterF24W5Primary,
          //   ),
          // ),
          Center(
            child: Text(
              errorMessage.isEmpty
                  ? S.of(context).somethingWentWrong
                  : errorMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(),
            ),
          ),
          if ((subErrorMessage ?? "").isNotEmpty)
            SizedBox(
              height: 12.h,
            ),
          if ((subErrorMessage ?? "").isNotEmpty)
            Center(
              child: Text(
                subErrorMessage ?? "",
                textAlign: TextAlign.center,
                style: AppTextStyles.baseStyle(),
              ),
            ),

          if (onRefresh != null)
            SizedBox(
              height: 24.h,
            ),
          if (onRefresh != null)
            CustomButton(
              onPressed: onRefresh!,
              child: Text(
                S.of(context).refresh,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(),
              ),
            )
        ],
      ),
    );
  }
}
