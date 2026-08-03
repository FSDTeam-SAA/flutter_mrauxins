import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/phone_number.dart';

import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/extensions.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/intl_widget.dart';

import '../cubit/send_otp_cubit.dart';
import '../cubit/send_otp_state.dart';
import '../database/local_db.dart';
import '../utils/colors.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/buttons.dart';
import '../widgets/keyboard_safe_scaffold.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';
import 'otp_verify_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _dbHelper.deleteLoginData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSafeScaffold(
      bottomNavigationBar: _buildBottomBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: 32.h),
                      _buildEmailField(context),
                      SizedBox(height: 22.h),
                      _buildOrDivider(context),
                      SizedBox(height: 22.h),
                      _buildPhoneField(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          S.of(context).logIn,
          style: AppTextStyles.medium(fontSize: 22.sp),
        ),
        SizedBox(height: 28.h),
        Text(
          S.of(context).lblLoginText,
          textAlign: TextAlign.center,
          style: AppTextStyles.bold(fontSize: 26.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          S.of(context).lblLoginSubtitleText,
          textAlign: TextAlign.center,
          style: AppTextStyles.regular(fontSize: 11.sp),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return BlocBuilder<SendOtpCubit, SendOtpState>(
      builder: (context, sendOtpState) {
        return CustomTextField(
          controller: _emailController,
          label: S.of(context).emailPlaceHolder,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          prefixIcon: SvgImage(
            source: SvgAssets.icEmail,
            fit: BoxFit.scaleDown,
            color: AppColors.white,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            context.read<SendOtpCubit>().setPhoneValid(value.isNotEmpty);
            context.read<SendOtpCubit>().updatePhoneNumber(null);
            _phoneController.clear();
          },
        );
      },
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(indent: 20.w, endIndent: 20.w, thickness: 1),
        ),
        Text(S.of(context).or, style: AppTextStyles.bold(fontSize: 12.sp)),
        Expanded(
          child: Divider(indent: 20.w, endIndent: 20.w, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return BlocBuilder<SendOtpCubit, SendOtpState>(
      builder: (context, sendOtpState) {
        return AppIntlPhoneField(
          controller: _phoneController,
          initialCountryCode: 'GB',
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.disabled,
          style: TextStyle(fontSize: 16.sp, color: AppColors.white),
          dropdownTextStyle: TextStyle(fontSize: 16.sp, color: AppColors.white),
          dropdownIcon: Icon(Icons.arrow_drop_down, color: AppColors.white),
          decoration: InputDecoration(
            hintText: S.of(context).phonePlaceholder,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textPlaceHolder,
            ),
          ),
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: AppColors.dialogBg,
            countryNameStyle: AppTextStyles.regular(),
            countryCodeStyle:
                AppTextStyles.regular().copyWith(fontWeight: FontWeight.bold),
            searchFieldInputDecoration: InputDecoration(
              hintText: S.of(context).searchCountry,
              hintStyle: TextStyle(color: AppColors.white),
              fillColor: AppColors.darkInputFill,
            ),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            context.read<SendOtpCubit>().updatePhoneNumber(value);
            _emailController.clear();
          },
          onCountryChanged: (value) {
            _emailController.clear();
            final phoneNumber = PhoneNumber(
              countryISOCode: value.code,
              countryCode: "+${value.dialCode}",
              number: sendOtpState.phoneNumber?.number ?? "",
            );
            context.read<SendOtpCubit>().updateCountry(value, phoneNumber);
          },
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 32.w,
        right: 32.w,
        bottom: Platform.isIOS ? 32.h : 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildConsentCheckbox(context),
          SizedBox(height: 10.h),
          _buildSubmitButton(context),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox(BuildContext context) {
    return BlocBuilder<SendOtpCubit, SendOtpState>(
      builder: (context, sendOtpState) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () =>
              sendOtpCubit.onAgreedToTerms(!sendOtpState.agreedToTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 22.h,
                  height: 22.h,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sendOtpState.agreedToTerms
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: sendOtpState.agreedToTerms
                          ? Colors.transparent
                          : AppColors.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: sendOtpState.agreedToTerms
                      ? const FittedBox(
                          child: Icon(Icons.check,
                              size: 22, color: AppColors.white),
                        )
                      : null,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "I understand my email/phone is used only for account setup. It will not be used for ads or shared with third parties.",
                  style: AppTextStyles.regular(fontSize: 10.sp),
                  softWrap: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<SendOtpCubit, SendOtpState>(
      builder: (context, sendOtpState) {
        return CustomButton(
          onPressed: () => _onSubmit(context, sendOtpState),
          child: _buildSubmitButtonLabel(context, sendOtpState),
        );
      },
    );
  }

  Widget _buildSubmitButtonLabel(
      BuildContext context, SendOtpState sendOtpState) {
    if (sendOtpState.sendOtpLoadingState == LoadingState.loading) {
      return const CustomLoadingWidget(color: AppColors.white);
    }
    return Text(
      sendOtpState.sendOtpLoadingState == LoadingState.error
          ? S.of(context).loginButtonTextRe
          : S.of(context).logIn,
      style: AppTextStyles.medium(fontSize: 16.sp, color: AppColors.white),
    );
  }

  Future<void> _onSubmit(
      BuildContext context, SendOtpState sendOtpState) async {
    if (!sendOtpState.agreedToTerms) {
      _showError(
          "You must accept that your information will only be used for account setup and not for advertising.");
      return;
    }

    final email = _emailController.text.trim();
    final phoneNumberState = context.read<SendOtpCubit>().state.phoneNumber;

    if (email.isNotEmpty &&
        phoneNumberState != null &&
        phoneNumberState.number.isNotEmpty) {
      _showError(S.of(context).pleaseFillOnlyOneFieldEmailOrPhone);
      return;
    }

    if (email.isEmpty &&
        phoneNumberState == null &&
        (phoneNumberState?.number ?? "").isEmpty) {
      _showError(S.of(context).pleaseEnterEmailOrPhone);
      return;
    }

    if (email.isNotEmpty) {
      if (!email.isValidEmail((message) => _showError(message))) {
        return;
      }
      await context.read<SendOtpCubit>().sendOtp(
        email,
        context,
        callback: () async {
          await NavigationService().navigateTo(
            OtpVerifyScreen(email: email),
          );
        },
      );
    } else if (phoneNumberState != null && phoneNumberState.number.isNotEmpty) {
      final phoneNumber = phoneNumberState.number;
      final countryCode = phoneNumberState.countryCode;
      final countryISOCode = phoneNumberState.countryISOCode;
      await context.read<SendOtpCubit>().sendPhoneOtp(
        "$countryCode$phoneNumber",
        context,
        callback: (verificationId) async {
          if (verificationId.isNotEmpty) {
            await NavigationService().navigateTo(OtpVerifyScreen(
              phoneNumber: phoneNumber,
              countryISOCode: countryISOCode,
              countryCode: countryCode,
              verificationId: verificationId,
            ));
            context.read<SendOtpCubit>().setSuceessState();
          }
        },
      );
    }
  }

  void _showError(String message) {
    Utils.showSnackBar(context, message);
  }
}
