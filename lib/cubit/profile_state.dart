import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/user_name_check_res.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../models/update_profile.dart';

// abstract class ProfileState {}

// class ProfileInitial extends ProfileState {}

// class ProfileLoading extends ProfileState {}

// class ProfileSuccess extends ProfileState {
//   ProfileSuccess();
// }

// class ProfileError extends ProfileState {
//   final String message;
//   ProfileError(this.message);
// }

// class ProfileLoaded extends ProfileState {
//   final UpdateProfileResponse updateProfileResponse;
//   ProfileLoaded(this.updateProfileResponse);
// }

// class ProfileEmpty extends ProfileState {}

// class UpdatePhoneNumber extends ProfileState {
//   final PhoneNumber phoneNumber;
//   UpdatePhoneNumber(this.phoneNumber);
// }

// class UpdateCountry extends ProfileState {
//   final PhoneNumber phoneNumber;
//   UpdateCountry(this.phoneNumber);
// }

// abstract class ProfilePickState {}

// class ProfilePickInitial extends ProfilePickState {}

// class ProfilePickSuccess extends ProfilePickState {
//   final File file;
//   ProfilePickSuccess(this.file);
// }

// class ProfilePickError extends ProfilePickState {
//   final String message;
//   ProfilePickError(this.message);
// }

class ProfileState extends Equatable {
  // Loading states for different operations
  final LoadingState profileLoadingState;
  final LoadingState imagePickLoadingState;
  final LoadingState sendOtpLoadingState;
  final UserData? userData;
  // Profile data
  final UpdateProfileResponse? updateProfileResponse;
  final File? selectedFile;
  final bool isPhoneChanged;
  final bool isEmailChanged;
  final bool isPhoneVerified;
  final bool isPhoneReVerification;
  final bool isEmailReVerification;
  final PhoneNumber? phoneNumber;
  final PhoneAuthCredential? credential;
  final UserNameCheckRes? userNameCheckRes;
  // Text controllers
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController userIdController;
  final TextEditingController bioController;

  // Error messages
  final String? profileErrorMessage;
  final String? imagePickErrorMessage;
  final String? userIdErrorMessage;
  final String? nameErrorMessage;
  final String? profilePrivacy;

  ProfileState({
    this.profileLoadingState = LoadingState.success,
    this.imagePickLoadingState = LoadingState.success,
    this.sendOtpLoadingState = LoadingState.success,
    this.updateProfileResponse,
    this.selectedFile,
    this.isPhoneChanged = false,
    this.isEmailChanged = false,
    this.isPhoneVerified = true,
    this.phoneNumber,
    this.credential,
    this.profileErrorMessage,
    this.imagePickErrorMessage,
    this.userData,
    this.profilePrivacy,
    this.userNameCheckRes,
    this.userIdErrorMessage,
    this.nameErrorMessage,
    this.isPhoneReVerification = false,
    this.isEmailReVerification = false,
    TextEditingController? nameController,
    TextEditingController? emailController,
    TextEditingController? userIdController,
    TextEditingController? bioController,
    TextEditingController? phoneController,
  })  : nameController = nameController ?? TextEditingController(),
        userIdController = userIdController ?? TextEditingController(),
        emailController = emailController ?? TextEditingController(),
        phoneController = phoneController ?? TextEditingController(),
        bioController = bioController ?? TextEditingController();

  /// Initial state factory
  factory ProfileState.initial() {
    return ProfileState();
  }

  /// CopyWith method for immutability
  ProfileState copyWith({
    LoadingState? profileLoadingState,
    LoadingState? imagePickLoadingState,
    LoadingState? sendOtpLoadingState,
    UpdateProfileResponse? updateProfileResponse,
    File? selectedFile,
    bool? isPhoneChanged,
    bool? isEmailChanged,
    bool? isPhoneVerified,
    PhoneNumber? phoneNumber,
    PhoneAuthCredential? credential,
    String? profileErrorMessage,
    String? imagePickErrorMessage,
    String? nameErrorMessage,
    String? userIdErrorMessage,
    bool? resetUserIdError,
    bool? resetNameError,
    bool? isPhoneReVerification,
    bool? isEmailReVerification,
    String? profilePrivacy,
    UserData? userData,
    UserNameCheckRes? userNameCheckRes,
    bool clearSelectedFile = false, // Optional flag to clear selected file
    TextEditingController? nameController,
    TextEditingController? userIdController,
    TextEditingController? bioController,
    TextEditingController? emailController,
    TextEditingController? phoneController,
  }) {
    return ProfileState(
      profileLoadingState: profileLoadingState ?? this.profileLoadingState,
      sendOtpLoadingState: sendOtpLoadingState ?? this.sendOtpLoadingState,
      imagePickLoadingState:
          imagePickLoadingState ?? this.imagePickLoadingState,
      updateProfileResponse:
          updateProfileResponse ?? this.updateProfileResponse,
      selectedFile:
          clearSelectedFile ? null : selectedFile ?? this.selectedFile,
      isPhoneChanged: isPhoneChanged ?? this.isPhoneChanged,
      isEmailChanged: isEmailChanged ?? this.isEmailChanged,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isPhoneReVerification: sendOtpLoadingState == LoadingState.success
          ? false
          : isPhoneReVerification ?? this.isPhoneReVerification,
      isEmailReVerification: sendOtpLoadingState == LoadingState.success
          ? false
          : isEmailReVerification ?? this.isEmailReVerification,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePrivacy: profilePrivacy ?? this.profilePrivacy,
      credential: credential ?? this.credential,
      profileErrorMessage: profileErrorMessage ?? this.profileErrorMessage,
      userNameCheckRes: userNameCheckRes ?? this.userNameCheckRes,
      userIdErrorMessage: (resetUserIdError ?? false)
          ? null
          : userIdErrorMessage ?? this.userIdErrorMessage,
      nameErrorMessage: (resetNameError ?? false)
          ? null
          : nameErrorMessage ?? this.nameErrorMessage,
      imagePickErrorMessage:
          imagePickErrorMessage ?? this.imagePickErrorMessage,
      nameController: nameController ?? this.nameController,
      emailController: emailController ?? this.emailController,
      phoneController: phoneController ?? this.phoneController,
      userIdController: userIdController ?? this.userIdController,
      bioController: bioController ?? this.bioController,
      userData: userData ?? this.userData,
    );
  }

  @override
  List<Object?> get props => [
        profileLoadingState,
        imagePickLoadingState,
        sendOtpLoadingState,
        updateProfileResponse,
        selectedFile,
        userIdErrorMessage,
        isPhoneChanged,
        phoneNumber,
        credential,
        profileErrorMessage,
        imagePickErrorMessage,
        nameController,
        emailController,
        phoneController,
        userIdController,
        bioController,
        userData,
        nameErrorMessage,
        isPhoneVerified,
        profilePrivacy,
        isEmailChanged,
        userNameCheckRes,
      ];
}
