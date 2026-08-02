// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `No Stories`
  String get noStories {
    return Intl.message('No Stories', name: 'noStories', desc: '', args: []);
  }

  /// `You haven't uploaded anything to your story yet. Please add stories by clicking the plus button below.`
  String get noStoriesUploadedDescription {
    return Intl.message(
      'You haven\'t uploaded anything to your story yet. Please add stories by clicking the plus button below.',
      name: 'noStoriesUploadedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong!, please try again`
  String get pleaseTryAgain {
    return Intl.message(
      'Something went wrong!, please try again',
      name: 'pleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure that you want to Logout the Application?`
  String get sLogoutMessage {
    return Intl.message(
      'Are you sure that you want to Logout the Application?',
      name: 'sLogoutMessage',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get logIn {
    return Intl.message('Log In', name: 'logIn', desc: '', args: []);
  }

  /// `Enter\nVerification Code`
  String get lblOtpText {
    return Intl.message(
      'Enter\nVerification Code',
      name: 'lblOtpText',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the OTP received at {value}`
  String lblOtpSubtitleText(Object value) {
    return Intl.message(
      'Please enter the OTP received at $value',
      name: 'lblOtpSubtitleText',
      desc: '',
      args: [value],
    );
  }

  /// `Online`
  String get online {
    return Intl.message('Online', name: 'online', desc: '', args: []);
  }

  /// `Offline`
  String get offline {
    return Intl.message('Offline', name: 'offline', desc: '', args: []);
  }

  /// `Please fill only one field: Email or Phone.`
  String get pleaseFillOnlyOneFieldEmailOrPhone {
    return Intl.message(
      'Please fill only one field: Email or Phone.',
      name: 'pleaseFillOnlyOneFieldEmailOrPhone',
      desc: '',
      args: [],
    );
  }

  /// `Please provide an email address OR phone number`
  String get pleaseEnterEmailOrPhone {
    return Intl.message(
      'Please provide an email address OR phone number',
      name: 'pleaseEnterEmailOrPhone',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email address`
  String get pleaseEnterYourEmailAddress {
    return Intl.message(
      'Please enter your email address',
      name: 'pleaseEnterYourEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Email address is invalid`
  String get emailAddressIsInvalid {
    return Intl.message(
      'Email address is invalid',
      name: 'emailAddressIsInvalid',
      desc: '',
      args: [],
    );
  }

  /// `please verify your email`
  String get pleaseVerifyEmail {
    return Intl.message(
      'please verify your email',
      name: 'pleaseVerifyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your otp`
  String get pleaseEnterYourOTP {
    return Intl.message(
      'Please enter your otp',
      name: 'pleaseEnterYourOTP',
      desc: '',
      args: [],
    );
  }

  /// `Otp is invalid`
  String get otpIsInvalid {
    return Intl.message(
      'Otp is invalid',
      name: 'otpIsInvalid',
      desc: '',
      args: [],
    );
  }

  /// `The phone number is invalid. Please check and try again.`
  String get invalid_phone_number {
    return Intl.message(
      'The phone number is invalid. Please check and try again.',
      name: 'invalid_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Too many attempts. Please try again later.`
  String get too_many_requests {
    return Intl.message(
      'Too many attempts. Please try again later.',
      name: 'too_many_requests',
      desc: '',
      args: [],
    );
  }

  /// `OTP request limit exceeded. Try again later.`
  String get quota_exceeded {
    return Intl.message(
      'OTP request limit exceeded. Try again later.',
      name: 'quota_exceeded',
      desc: '',
      args: [],
    );
  }

  /// `Network error. Please check your internet connection.`
  String get network_request_failed {
    return Intl.message(
      'Network error. Please check your internet connection.',
      name: 'network_request_failed',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get somethingWentWrongPleaseTryAgain {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'somethingWentWrongPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `The OTP you entered is incorrect. Please try again.`
  String get wrongOtp {
    return Intl.message(
      'The OTP you entered is incorrect. Please try again.',
      name: 'wrongOtp',
      desc: '',
      args: [],
    );
  }

  /// `Make Profile Private`
  String get makeProfilePrivate {
    return Intl.message(
      'Make Profile Private',
      name: 'makeProfilePrivate',
      desc: '',
      args: [],
    );
  }

  /// `Your profile is visible to everyone.`
  String get publicProfileText {
    return Intl.message(
      'Your profile is visible to everyone.',
      name: 'publicProfileText',
      desc: '',
      args: [],
    );
  }

  /// `Your profile is private. Only known contacts can find you.`
  String get privateProfileText {
    return Intl.message(
      'Your profile is private. Only known contacts can find you.',
      name: 'privateProfileText',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Edit {value}`
  String editPhoneOrEmail(Object value) {
    return Intl.message(
      'Edit $value',
      name: 'editPhoneOrEmail',
      desc: '',
      args: [value],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Email Adrress`
  String get emailAdress {
    return Intl.message(
      'Email Adrress',
      name: 'emailAdress',
      desc: '',
      args: [],
    );
  }

  /// `About you`
  String get aboutYouPlaceholder {
    return Intl.message(
      'About you',
      name: 'aboutYouPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Email adrress change successfully`
  String get emailChangeSuccessfully {
    return Intl.message(
      'Email adrress change successfully',
      name: 'emailChangeSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Email address verified successfully`
  String get emailVerifiedSuccessfully {
    return Intl.message(
      'Email address verified successfully',
      name: 'emailVerifiedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Phone number verified successfully`
  String get phoneVerifiedSuccessfully {
    return Intl.message(
      'Phone number verified successfully',
      name: 'phoneVerifiedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Otp verified successfully`
  String get otpVerifySuccess {
    return Intl.message(
      'Otp verified successfully',
      name: 'otpVerifySuccess',
      desc: '',
      args: [],
    );
  }

  /// `Tap to change the Phone Number`
  String get lblPhoneChangeTxt {
    return Intl.message(
      'Tap to change the Phone Number',
      name: 'lblPhoneChangeTxt',
      desc: '',
      args: [],
    );
  }

  /// `Tap to change the Email Adrress`
  String get lblEmailChangeTxt {
    return Intl.message(
      'Tap to change the Email Adrress',
      name: 'lblEmailChangeTxt',
      desc: '',
      args: [],
    );
  }

  /// `Please change phone number before update`
  String get pleaseChangePhoneNumberBeforeUpdate {
    return Intl.message(
      'Please change phone number before update',
      name: 'pleaseChangePhoneNumberBeforeUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Allow members to send message`
  String get allowMembersToSendMessage {
    return Intl.message(
      'Allow members to send message',
      name: 'allowMembersToSendMessage',
      desc: '',
      args: [],
    );
  }

  /// `Enter Username`
  String get usernamePlaceholder {
    return Intl.message(
      'Enter Username',
      name: 'usernamePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Enter Display Name`
  String get namePlaceholder {
    return Intl.message(
      'Enter Display Name',
      name: 'namePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Search Users`
  String get searchUsers {
    return Intl.message(
      'Search Users',
      name: 'searchUsers',
      desc: '',
      args: [],
    );
  }

  /// `No Conversations Found`
  String get noConversationsFound {
    return Intl.message(
      'No Conversations Found',
      name: 'noConversationsFound',
      desc: '',
      args: [],
    );
  }

  /// `Upload Story`
  String get uploadStory {
    return Intl.message(
      'Upload Story',
      name: 'uploadStory',
      desc: '',
      args: [],
    );
  }

  /// `Delete Message`
  String get lblDeleteMessage {
    return Intl.message(
      'Delete Message',
      name: 'lblDeleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete for me`
  String get deleteForMe {
    return Intl.message(
      'Delete for me',
      name: 'deleteForMe',
      desc: '',
      args: [],
    );
  }

  /// `Edit Message`
  String get editMessage {
    return Intl.message(
      'Edit Message',
      name: 'editMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Pin`
  String get pin {
    return Intl.message('Pin', name: 'pin', desc: '', args: []);
  }

  /// `Forward`
  String get forward {
    return Intl.message('Forward', name: 'forward', desc: '', args: []);
  }

  /// `Reply`
  String get reply {
    return Intl.message('Reply', name: 'reply', desc: '', args: []);
  }

  /// `Bio`
  String get bio {
    return Intl.message('Bio', name: 'bio', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `User Name`
  String get username {
    return Intl.message('User Name', name: 'username', desc: '', args: []);
  }

  /// `Delete for everyone`
  String get deleteMessageForEveryone {
    return Intl.message(
      'Delete for everyone',
      name: 'deleteMessageForEveryone',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard!`
  String get copiedToClipboard {
    return Intl.message(
      'Copied to clipboard!',
      name: 'copiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Save Message`
  String get saveMessage {
    return Intl.message(
      'Save Message',
      name: 'saveMessage',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Open Settings`
  String get openSetting {
    return Intl.message(
      'Open Settings',
      name: 'openSetting',
      desc: '',
      args: [],
    );
  }

  /// `Permission Required`
  String get permissionRequired {
    return Intl.message(
      'Permission Required',
      name: 'permissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `No phone number`
  String get noPhoneNumber {
    return Intl.message(
      'No phone number',
      name: 'noPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `No email address`
  String get noEmailAddress {
    return Intl.message(
      'No email address',
      name: 'noEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Verification Otp`
  String get verificationOtp {
    return Intl.message(
      'Verification Otp',
      name: 'verificationOtp',
      desc: '',
      args: [],
    );
  }

  /// `You can add a phone number in Profile Settings.`
  String get youCanAddPhoneNumberInProfileSettings {
    return Intl.message(
      'You can add a phone number in Profile Settings.',
      name: 'youCanAddPhoneNumberInProfileSettings',
      desc: '',
      args: [],
    );
  }

  /// `You can add an email address in Profile Settings.`
  String get youCanAddAnEmailAddressInProfileSettings {
    return Intl.message(
      'You can add an email address in Profile Settings.',
      name: 'youCanAddAnEmailAddressInProfileSettings',
      desc: '',
      args: [],
    );
  }

  /// `Add a few words about yourself in Profile Settings.`
  String get addFewWordsAboutYourself {
    return Intl.message(
      'Add a few words about yourself in Profile Settings.',
      name: 'addFewWordsAboutYourself',
      desc: '',
      args: [],
    );
  }

  /// `Is '{value}' still your Number?`
  String isStillYourNumber(Object value) {
    return Intl.message(
      'Is \'$value\' still your Number?',
      name: 'isStillYourNumber',
      desc: '',
      args: [value],
    );
  }

  /// `Is '{value}' still your email address?`
  String isStillYourEmailAddress(Object value) {
    return Intl.message(
      'Is \'$value\' still your email address?',
      name: 'isStillYourEmailAddress',
      desc: '',
      args: [value],
    );
  }

  /// `Keep your number up to date to ensure you can always log into 212 Private Messenger.`
  String get lblKeepYourNumberUptoDate {
    return Intl.message(
      'Keep your number up to date to ensure you can always log into 212 Private Messenger.',
      name: 'lblKeepYourNumberUptoDate',
      desc: '',
      args: [],
    );
  }

  /// `Keep your email address up to date to ensure you can always log into 212 Private Messenger.`
  String get lblKeepYourEmailAddressUptoDate {
    return Intl.message(
      'Keep your email address up to date to ensure you can always log into 212 Private Messenger.',
      name: 'lblKeepYourEmailAddressUptoDate',
      desc: '',
      args: [],
    );
  }

  /// `Gifts Coming Soon!`
  String get giftsCommingSoon {
    return Intl.message(
      'Gifts Coming Soon!',
      name: 'giftsCommingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Upload Photos from`
  String get lblUploadPhotos {
    return Intl.message(
      'Upload Photos from',
      name: 'lblUploadPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Upload Media from`
  String get lblUploadMedias {
    return Intl.message(
      'Upload Media from',
      name: 'lblUploadMedias',
      desc: '',
      args: [],
    );
  }

  /// `Select Media`
  String get selectMedia {
    return Intl.message(
      'Select Media',
      name: 'selectMedia',
      desc: '',
      args: [],
    );
  }

  /// `Messages are end-to-end encrypted. No one outside this chat, not even 212 Messenger, can read or listen to them.`
  String get messageEncryptionInfo {
    return Intl.message(
      'Messages are end-to-end encrypted. No one outside this chat, not even 212 Messenger, can read or listen to them.',
      name: 'messageEncryptionInfo',
      desc: '',
      args: [],
    );
  }

  /// `{userName} uses the default timer for disappearing messages in new chats. New messages will disappear from this chat in {days} days after they're sent, except when kept.\nTap to set your own default timer.`
  String disappearingMessageInfo(Object userName, Object days) {
    return Intl.message(
      '$userName uses the default timer for disappearing messages in new chats. New messages will disappear from this chat in $days days after they\'re sent, except when kept.\nTap to set your own default timer.',
      name: 'disappearingMessageInfo',
      desc: '',
      args: [userName, days],
    );
  }

  /// `We’re working hard to bring you a fun new way to send gifts. Stay tuned, and keep an eye out for this feature in the next update!`
  String get giftsCommingSoonMessage {
    return Intl.message(
      'We’re working hard to bring you a fun new way to send gifts. Stay tuned, and keep an eye out for this feature in the next update!',
      name: 'giftsCommingSoonMessage',
      desc: '',
      args: [],
    );
  }

  /// `Start new chat with disappearing message timer set to`
  String get disappearingMessageTitle {
    return Intl.message(
      'Start new chat with disappearing message timer set to',
      name: 'disappearingMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `24 Hours`
  String get timer24Hours {
    return Intl.message('24 Hours', name: 'timer24Hours', desc: '', args: []);
  }

  /// `7 Days`
  String get timer7Days {
    return Intl.message('7 Days', name: 'timer7Days', desc: '', args: []);
  }

  /// `90 Days`
  String get timer90Days {
    return Intl.message('90 Days', name: 'timer90Days', desc: '', args: []);
  }

  /// `Off`
  String get timerOff {
    return Intl.message('Off', name: 'timerOff', desc: '', args: []);
  }

  /// `View contact`
  String get viewContact {
    return Intl.message(
      'View contact',
      name: 'viewContact',
      desc: '',
      args: [],
    );
  }

  /// `Clear Chat`
  String get clearChat {
    return Intl.message('Clear Chat', name: 'clearChat', desc: '', args: []);
  }

  /// `Disappearing messages`
  String get disappearingMessage {
    return Intl.message(
      'Disappearing messages',
      name: 'disappearingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Group Info`
  String get lblGroupInfo {
    return Intl.message('Group Info', name: 'lblGroupInfo', desc: '', args: []);
  }

  /// `Call`
  String get calls {
    return Intl.message('Call', name: 'calls', desc: '', args: []);
  }

  /// `Calls`
  String get sCalls {
    return Intl.message('Calls', name: 'sCalls', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `Block user`
  String get blockUser {
    return Intl.message('Block user', name: 'blockUser', desc: '', args: []);
  }

  /// `Report User`
  String get reportUser {
    return Intl.message('Report User', name: 'reportUser', desc: '', args: []);
  }

  /// `Channel Info`
  String get lblChannelInfo {
    return Intl.message(
      'Channel Info',
      name: 'lblChannelInfo',
      desc: '',
      args: [],
    );
  }

  /// `Invite To Group`
  String get inviteToGroup {
    return Intl.message(
      'Invite To Group',
      name: 'inviteToGroup',
      desc: '',
      args: [],
    );
  }

  /// `Call History`
  String get callHistory {
    return Intl.message(
      'Call History',
      name: 'callHistory',
      desc: '',
      args: [],
    );
  }

  /// `Invite To Channel`
  String get inviteToChannel {
    return Intl.message(
      'Invite To Channel',
      name: 'inviteToChannel',
      desc: '',
      args: [],
    );
  }

  /// `{value} selected`
  String countSelected(Object value) {
    return Intl.message(
      '$value selected',
      name: 'countSelected',
      desc: '',
      args: [value],
    );
  }

  /// `Select All`
  String get selectAll {
    return Intl.message('Select All', name: 'selectAll', desc: '', args: []);
  }

  /// `Delete Selected`
  String get deleteSelected {
    return Intl.message(
      'Delete Selected',
      name: 'deleteSelected',
      desc: '',
      args: [],
    );
  }

  /// `Clear call logs`
  String get clearCallLog {
    return Intl.message(
      'Clear call logs',
      name: 'clearCallLog',
      desc: '',
      args: [],
    );
  }

  /// `Clear Call History`
  String get clear_all_calls_title {
    return Intl.message(
      'Clear Call History',
      name: 'clear_all_calls_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete all call history? This action cannot be undone.`
  String get clear_all_calls_subtitle {
    return Intl.message(
      'Are you sure you want to delete all call history? This action cannot be undone.',
      name: 'clear_all_calls_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Delete Selected Calls`
  String get delete_selected_calls_title {
    return Intl.message(
      'Delete Selected Calls',
      name: 'delete_selected_calls_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the selected calls? This action cannot be undone.`
  String get delete_selected_calls_subtitle {
    return Intl.message(
      'Are you sure you want to delete the selected calls? This action cannot be undone.',
      name: 'delete_selected_calls_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Block User?`
  String get blockUserTitle {
    return Intl.message(
      'Block User?',
      name: 'blockUserTitle',
      desc: '',
      args: [],
    );
  }

  /// `{userName} will no longer be able to call or send you messages.`
  String blockUserSubtitle(Object userName) {
    return Intl.message(
      '$userName will no longer be able to call or send you messages.',
      name: 'blockUserSubtitle',
      desc: '',
      args: [userName],
    );
  }

  /// `you blocked {userName} successfully`
  String blockUserSuccessfully(Object userName) {
    return Intl.message(
      'you blocked $userName successfully',
      name: 'blockUserSuccessfully',
      desc: '',
      args: [userName],
    );
  }

  /// `Unblock User?`
  String get unblockUserTitle {
    return Intl.message(
      'Unblock User?',
      name: 'unblockUserTitle',
      desc: '',
      args: [],
    );
  }

  /// `You will be able to receive messages and calls from {userName} again.`
  String unblockUserSubtitle(Object userName) {
    return Intl.message(
      'You will be able to receive messages and calls from $userName again.',
      name: 'unblockUserSubtitle',
      desc: '',
      args: [userName],
    );
  }

  /// `You unblocked {userName} successfully`
  String unblockUserSuccessfully(Object userName) {
    return Intl.message(
      'You unblocked $userName successfully',
      name: 'unblockUserSuccessfully',
      desc: '',
      args: [userName],
    );
  }

  /// `Blocked contacts`
  String get blockedContacts {
    return Intl.message(
      'Blocked contacts',
      name: 'blockedContacts',
      desc: '',
      args: [],
    );
  }

  /// `Block`
  String get block {
    return Intl.message('Block', name: 'block', desc: '', args: []);
  }

  /// `Unblock User`
  String get unBlockUser {
    return Intl.message(
      'Unblock User',
      name: 'unBlockUser',
      desc: '',
      args: [],
    );
  }

  /// `Only Admins can send messages`
  String get onlyAdminsCanSendMessages {
    return Intl.message(
      'Only Admins can send messages',
      name: 'onlyAdminsCanSendMessages',
      desc: '',
      args: [],
    );
  }

  /// `An administrator has disabled messages from group members.`
  String get adminDisabledGroupMessages {
    return Intl.message(
      'An administrator has disabled messages from group members.',
      name: 'adminDisabledGroupMessages',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Languages`
  String get languages {
    return Intl.message('Languages', name: 'languages', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `You can't send messages to {userName} because you have blocked them.`
  String blockedUserCannotSendMessage(Object userName) {
    return Intl.message(
      'You can\'t send messages to $userName because you have blocked them.',
      name: 'blockedUserCannotSendMessage',
      desc: '',
      args: [userName],
    );
  }

  /// `{userName} is Blocked you so you can't send messages to them.`
  String userBlockedYouSoCannotSendMessage(Object userName) {
    return Intl.message(
      '$userName is Blocked you so you can\'t send messages to them.',
      name: 'userBlockedYouSoCannotSendMessage',
      desc: '',
      args: [userName],
    );
  }

  /// `When turned on, all new individual chats will start with disappearing messages set to the duration you select. This setting will not affect your existing chats.`
  String get disappearingMessageDescription {
    return Intl.message(
      'When turned on, all new individual chats will start with disappearing messages set to the duration you select. This setting will not affect your existing chats.',
      name: 'disappearingMessageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `Report User`
  String get reportUserTitle {
    return Intl.message(
      'Report User',
      name: 'reportUserTitle',
      desc: '',
      args: [],
    );
  }

  /// `Additional Details (Optional)`
  String get reportUserDescriptionLabel {
    return Intl.message(
      'Additional Details (Optional)',
      name: 'reportUserDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please select reason for report`
  String get reportUserReasonLabel {
    return Intl.message(
      'Please select reason for report',
      name: 'reportUserReasonLabel',
      desc: '',
      args: [],
    );
  }

  /// `Describe the issue (up to 300 characters)...`
  String get reportUserDescriptionHint {
    return Intl.message(
      'Describe the issue (up to 300 characters)...',
      name: 'reportUserDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Report User`
  String get reportUserButton {
    return Intl.message(
      'Report User',
      name: 'reportUserButton',
      desc: '',
      args: [],
    );
  }

  /// `Spam`
  String get reportReasonSpam {
    return Intl.message('Spam', name: 'reportReasonSpam', desc: '', args: []);
  }

  /// `Harassment`
  String get reportReasonHarassment {
    return Intl.message(
      'Harassment',
      name: 'reportReasonHarassment',
      desc: '',
      args: [],
    );
  }

  /// `Inappropriate Content`
  String get reportReasonInappropriateContent {
    return Intl.message(
      'Inappropriate Content',
      name: 'reportReasonInappropriateContent',
      desc: '',
      args: [],
    );
  }

  /// `Fake Profile`
  String get reportReasonFakeProfile {
    return Intl.message(
      'Fake Profile',
      name: 'reportReasonFakeProfile',
      desc: '',
      args: [],
    );
  }

  /// `Scam or Fraud`
  String get reportReasonScamOrFraud {
    return Intl.message(
      'Scam or Fraud',
      name: 'reportReasonScamOrFraud',
      desc: '',
      args: [],
    );
  }

  /// `Violence or Threats`
  String get reportReasonViolenceOrThreats {
    return Intl.message(
      'Violence or Threats',
      name: 'reportReasonViolenceOrThreats',
      desc: '',
      args: [],
    );
  }

  /// `Hate Speech`
  String get reportReasonHateSpeech {
    return Intl.message(
      'Hate Speech',
      name: 'reportReasonHateSpeech',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully reported user {name}.`
  String youHaveSuccesfullyRepoartuser(Object name) {
    return Intl.message(
      'You have successfully reported user $name.',
      name: 'youHaveSuccesfullyRepoartuser',
      desc: '',
      args: [name],
    );
  }

  /// `212 Messenger Premium`
  String get premiumScreenTitle {
    return Intl.message(
      '212 Messenger Premium',
      name: 'premiumScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Premium is coming soon! Stay tuned for exclusive features.`
  String get premiumComingSoon {
    return Intl.message(
      'Premium is coming soon! Stay tuned for exclusive features.',
      name: 'premiumComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `You're an Ad-Free user! Enjoy using our app without ads. Upgrade to Premium for even more exclusive features.`
  String get adFreeUserMessage {
    return Intl.message(
      'You\'re an Ad-Free user! Enjoy using our app without ads. Upgrade to Premium for even more exclusive features.',
      name: 'adFreeUserMessage',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade to enhance your experience! Choose Ad-Free to remove ads or go Premium for the full set of exclusive features.`
  String get noSubscriptionMessage {
    return Intl.message(
      'Upgrade to enhance your experience! Choose Ad-Free to remove ads or go Premium for the full set of exclusive features.',
      name: 'noSubscriptionMessage',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade to Premium`
  String get upgradeToPremium {
    return Intl.message(
      'Upgrade to Premium',
      name: 'upgradeToPremium',
      desc: '',
      args: [],
    );
  }

  /// `Buy Ad-Free`
  String get buyAdFree {
    return Intl.message('Buy Ad-Free', name: 'buyAdFree', desc: '', args: []);
  }

  /// `Buy Premium`
  String get buyPremium {
    return Intl.message('Buy Premium', name: 'buyPremium', desc: '', args: []);
  }

  /// `Restore Purchases`
  String get restorePurchase {
    return Intl.message(
      'Restore Purchases',
      name: 'restorePurchase',
      desc: '',
      args: [],
    );
  }

  /// `New Group`
  String get newGroup {
    return Intl.message('New Group', name: 'newGroup', desc: '', args: []);
  }

  /// `New Channel`
  String get newChannel {
    return Intl.message('New Channel', name: 'newChannel', desc: '', args: []);
  }

  /// `New Contacts`
  String get newContacts {
    return Intl.message(
      'New Contacts',
      name: 'newContacts',
      desc: '',
      args: [],
    );
  }

  /// `Last seen `
  String get sLastSeen {
    return Intl.message('Last seen ', name: 'sLastSeen', desc: '', args: []);
  }

  /// `Invite Friend`
  String get inviteFriend {
    return Intl.message(
      'Invite Friend',
      name: 'inviteFriend',
      desc: '',
      args: [],
    );
  }

  /// `Search User`
  String get lblSearchUser {
    return Intl.message(
      'Search User',
      name: 'lblSearchUser',
      desc: '',
      args: [],
    );
  }

  /// `No message`
  String get noMessage {
    return Intl.message('No message', name: 'noMessage', desc: '', args: []);
  }

  /// `Other Users`
  String get otherUsers {
    return Intl.message('Other Users', name: 'otherUsers', desc: '', args: []);
  }

  /// `Document`
  String get document {
    return Intl.message('Document', name: 'document', desc: '', args: []);
  }

  /// `Replying to: `
  String get replyingTo {
    return Intl.message(
      'Replying to: ',
      name: 'replyingTo',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get you {
    return Intl.message('You', name: 'you', desc: '', args: []);
  }

  /// `Search Chat`
  String get lblSearchChat {
    return Intl.message(
      'Search Chat',
      name: 'lblSearchChat',
      desc: '',
      args: [],
    );
  }

  /// `Type Message`
  String get typeMessage {
    return Intl.message(
      'Type Message',
      name: 'typeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add a message...`
  String get addMessage {
    return Intl.message(
      'Add a message...',
      name: 'addMessage',
      desc: '',
      args: [],
    );
  }

  /// `React`
  String get react {
    return Intl.message('React', name: 'react', desc: '', args: []);
  }

  /// `Edit Image`
  String get editImage {
    return Intl.message('Edit Image', name: 'editImage', desc: '', args: []);
  }

  /// `Your Stories`
  String get yourStories {
    return Intl.message(
      'Your Stories',
      name: 'yourStories',
      desc: '',
      args: [],
    );
  }

  /// `Archive Chats`
  String get archiveChats {
    return Intl.message(
      'Archive Chats',
      name: 'archiveChats',
      desc: '',
      args: [],
    );
  }

  /// `{number} archived chats available`
  String numberOfArchiveChats(Object number) {
    return Intl.message(
      '$number archived chats available',
      name: 'numberOfArchiveChats',
      desc: '',
      args: [number],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Are you sure you want to archive this chat?`
  String get areYouSureToWantToArchiveThisChat {
    return Intl.message(
      'Are you sure you want to archive this chat?',
      name: 'areYouSureToWantToArchiveThisChat',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to unarchive this chat?`
  String get areYouSureToWantToUnArchiveThisChat {
    return Intl.message(
      'Are you sure you want to unarchive this chat?',
      name: 'areYouSureToWantToUnArchiveThisChat',
      desc: '',
      args: [],
    );
  }

  /// `You cannot remove the email because your phone number is not registered or verified in your account.`
  String get errorCannotRemoveEmail {
    return Intl.message(
      'You cannot remove the email because your phone number is not registered or verified in your account.',
      name: 'errorCannotRemoveEmail',
      desc: '',
      args: [],
    );
  }

  /// `You cannot remove the phone number because your email is not registered or verified in your account.`
  String get errorCannotRemovePhone {
    return Intl.message(
      'You cannot remove the phone number because your email is not registered or verified in your account.',
      name: 'errorCannotRemovePhone',
      desc: '',
      args: [],
    );
  }

  /// `Email adress remove successfully`
  String get removeEmailSuccess {
    return Intl.message(
      'Email adress remove successfully',
      name: 'removeEmailSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Phone number remove successfully`
  String get removePhoneSuccess {
    return Intl.message(
      'Phone number remove successfully',
      name: 'removePhoneSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Recent Messages`
  String get recentMessage {
    return Intl.message(
      'Recent Messages',
      name: 'recentMessage',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get sLogout {
    return Intl.message('Logout', name: 'sLogout', desc: '', args: []);
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action is irreversible, and all your messages, contacts, and data will be permanently lost.`
  String get deleteAccountSlogen {
    return Intl.message(
      'Are you sure you want to delete your account? This action is irreversible, and all your messages, contacts, and data will be permanently lost.',
      name: 'deleteAccountSlogen',
      desc: '',
      args: [],
    );
  }

  /// `Who would you like to add?`
  String get whoWouldYouLikeToAdd {
    return Intl.message(
      'Who would you like to add?',
      name: 'whoWouldYouLikeToAdd',
      desc: '',
      args: [],
    );
  }

  /// `Video duration exceeds 30 seconds. Please select a shorter video.`
  String get videoDurationIsMorethen30Sec {
    return Intl.message(
      'Video duration exceeds 30 seconds. Please select a shorter video.',
      name: 'videoDurationIsMorethen30Sec',
      desc: '',
      args: [],
    );
  }

  /// `Today’s Stories`
  String get todayStories {
    return Intl.message(
      'Today’s Stories',
      name: 'todayStories',
      desc: '',
      args: [],
    );
  }

  /// `Only the group creator can delete the group.`
  String get deleteGroupAuthority {
    return Intl.message(
      'Only the group creator can delete the group.',
      name: 'deleteGroupAuthority',
      desc: '',
      args: [],
    );
  }

  /// `Please change email address before the update`
  String get emailAddressIsAlreadyUpdated {
    return Intl.message(
      'Please change email address before the update',
      name: 'emailAddressIsAlreadyUpdated',
      desc: '',
      args: [],
    );
  }

  /// `No registered contact available. Please invite a member`
  String get noContactsFound {
    return Intl.message(
      'No registered contact available. Please invite a member',
      name: 'noContactsFound',
      desc: '',
      args: [],
    );
  }

  /// `Admin`
  String get admin {
    return Intl.message('Admin', name: 'admin', desc: '', args: []);
  }

  /// `{value, plural, one{{value} Member} other{{value} Members}}`
  String noOfMember(int value) {
    return Intl.plural(
      value,
      one: '$value Member',
      other: '$value Members',
      name: 'noOfMember',
      desc: '',
      args: [value],
    );
  }

  /// `{value, plural, one{{value} Subscriber} other{{value} Subscribers}}`
  String noOfSubscriber(int value) {
    return Intl.plural(
      value,
      one: '$value Subscriber',
      other: '$value Subscribers',
      name: 'noOfSubscriber',
      desc: '',
      args: [value],
    );
  }

  /// `Group Permission`
  String get groupPermission {
    return Intl.message(
      'Group Permission',
      name: 'groupPermission',
      desc: '',
      args: [],
    );
  }

  /// `Channel Permission`
  String get channelPermission {
    return Intl.message(
      'Channel Permission',
      name: 'channelPermission',
      desc: '',
      args: [],
    );
  }

  /// `Group Members`
  String get groupMembers {
    return Intl.message(
      'Group Members',
      name: 'groupMembers',
      desc: '',
      args: [],
    );
  }

  /// `Subscribers`
  String get subscribers {
    return Intl.message('Subscribers', name: 'subscribers', desc: '', args: []);
  }

  /// `Add Subscribers`
  String get addSubscribers {
    return Intl.message(
      'Add Subscribers',
      name: 'addSubscribers',
      desc: '',
      args: [],
    );
  }

  /// `Search conversations...`
  String get searchConversations {
    return Intl.message(
      'Search conversations...',
      name: 'searchConversations',
      desc: '',
      args: [],
    );
  }

  /// `No views yet. Your story hasn't been seen by anyone.`
  String get noViewsYetForStories {
    return Intl.message(
      'No views yet. Your story hasn\'t been seen by anyone.',
      name: 'noViewsYetForStories',
      desc: '',
      args: [],
    );
  }

  /// `Search contacts...`
  String get sSearchContacts {
    return Intl.message(
      'Search contacts...',
      name: 'sSearchContacts',
      desc: '',
      args: [],
    );
  }

  /// `Sorted by Last seen time`
  String get sortedByLastSeenTime {
    return Intl.message(
      'Sorted by Last seen time',
      name: 'sortedByLastSeenTime',
      desc: '',
      args: [],
    );
  }

  /// `Delete Group`
  String get deleteGroup {
    return Intl.message(
      'Delete Group',
      name: 'deleteGroup',
      desc: '',
      args: [],
    );
  }

  /// `Delete Channel`
  String get deleteChannel {
    return Intl.message(
      'Delete Channel',
      name: 'deleteChannel',
      desc: '',
      args: [],
    );
  }

  /// `Leave Group`
  String get leaveGroup {
    return Intl.message('Leave Group', name: 'leaveGroup', desc: '', args: []);
  }

  /// `Leave Channel`
  String get leaveChannel {
    return Intl.message(
      'Leave Channel',
      name: 'leaveChannel',
      desc: '',
      args: [],
    );
  }

  /// `Add Members`
  String get addMembers {
    return Intl.message('Add Members', name: 'addMembers', desc: '', args: []);
  }

  /// `Are you sure you want to delete this Group?`
  String get lblDeleteGroupSubTitle {
    return Intl.message(
      'Are you sure you want to delete this Group?',
      name: 'lblDeleteGroupSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave from this Group?`
  String get lblLeaveGroupSubTitle {
    return Intl.message(
      'Are you sure you want to leave from this Group?',
      name: 'lblLeaveGroupSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this Channel?`
  String get lblDeleteChannelSubTitle {
    return Intl.message(
      'Are you sure you want to delete this Channel?',
      name: 'lblDeleteChannelSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave from this Channel?`
  String get lblLeaveChannelSubTitle {
    return Intl.message(
      'Are you sure you want to leave from this Channel?',
      name: 'lblLeaveChannelSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select contacts to invite them to 212 Private Messenger`
  String get selectContactToInviteThem {
    return Intl.message(
      'Select contacts to invite them to 212 Private Messenger',
      name: 'selectContactToInviteThem',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Search notifications...`
  String get sSearchNotifications {
    return Intl.message(
      'Search notifications...',
      name: 'sSearchNotifications',
      desc: '',
      args: [],
    );
  }

  /// `No Call History Found`
  String get noCallHistoryFound {
    return Intl.message(
      'No Call History Found',
      name: 'noCallHistoryFound',
      desc: '',
      args: [],
    );
  }

  /// `No Notifications Found`
  String get noNotificationsFound {
    return Intl.message(
      'No Notifications Found',
      name: 'noNotificationsFound',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Video`
  String get video {
    return Intl.message('Video', name: 'video', desc: '', args: []);
  }

  /// `Image`
  String get image {
    return Intl.message('Image', name: 'image', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Write caption here`
  String get writeCaptionHere {
    return Intl.message(
      'Write caption here',
      name: 'writeCaptionHere',
      desc: '',
      args: [],
    );
  }

  /// `Delete Story`
  String get lblDeleteStories {
    return Intl.message(
      'Delete Story',
      name: 'lblDeleteStories',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure that you want to remove the Story?`
  String get lblDeleteStoriesSubTitle {
    return Intl.message(
      'Are you sure that you want to remove the Story?',
      name: 'lblDeleteStoriesSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `Recording`
  String get recording {
    return Intl.message('Recording', name: 'recording', desc: '', args: []);
  }

  /// `Recording...`
  String get recording2 {
    return Intl.message('Recording...', name: 'recording2', desc: '', args: []);
  }

  /// `Tap Start to record`
  String get tapToStartRecord {
    return Intl.message(
      'Tap Start to record',
      name: 'tapToStartRecord',
      desc: '',
      args: [],
    );
  }

  /// `Restart Recording...`
  String get restartRecording {
    return Intl.message(
      'Restart Recording...',
      name: 'restartRecording',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message('Pause', name: 'pause', desc: '', args: []);
  }

  /// `Start`
  String get start {
    return Intl.message('Start', name: 'start', desc: '', args: []);
  }

  /// `Restart`
  String get restart {
    return Intl.message('Restart', name: 'restart', desc: '', args: []);
  }

  /// `Stop`
  String get stop {
    return Intl.message('Stop', name: 'stop', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Are you sure you want to delete this message?`
  String get lblDeleteMessageSubTitle {
    return Intl.message(
      'Are you sure you want to delete this message?',
      name: 'lblDeleteMessageSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear chat?`
  String get lblClearChatSubTitle {
    return Intl.message(
      'Are you sure you want to clear chat?',
      name: 'lblClearChatSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `End Call`
  String get endCall {
    return Intl.message('End Call', name: 'endCall', desc: '', args: []);
  }

  /// `has created a new group, so you can start the conversation!`
  String get groupCreatedEmptyChatMsg {
    return Intl.message(
      'has created a new group, so you can start the conversation!',
      name: 'groupCreatedEmptyChatMsg',
      desc: '',
      args: [],
    );
  }

  /// `has created a new channel`
  String get channelCreatedEmptyChatMsg {
    return Intl.message(
      'has created a new channel',
      name: 'channelCreatedEmptyChatMsg',
      desc: '',
      args: [],
    );
  }

  /// `Your Cloud Storage`
  String get yourCloudStorage {
    return Intl.message(
      'Your Cloud Storage',
      name: 'yourCloudStorage',
      desc: '',
      args: [],
    );
  }

  /// `Forward Message here to save them`
  String get forwardMessageHereToSaveThem {
    return Intl.message(
      'Forward Message here to save them',
      name: 'forwardMessageHereToSaveThem',
      desc: '',
      args: [],
    );
  }

  /// `Send Media and Files to store them`
  String get sendMediaAndFilesToStoreThem {
    return Intl.message(
      'Send Media and Files to store them',
      name: 'sendMediaAndFilesToStoreThem',
      desc: '',
      args: [],
    );
  }

  /// `Access this chat from any device`
  String get accessThisChatFromAnyDevice {
    return Intl.message(
      'Access this chat from any device',
      name: 'accessThisChatFromAnyDevice',
      desc: '',
      args: [],
    );
  }

  /// `Use search to quickly find things`
  String get useSearchToQuicklyFindThings {
    return Intl.message(
      'Use search to quickly find things',
      name: 'useSearchToQuicklyFindThings',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get lblEditProfile {
    return Intl.message(
      'Edit Profile',
      name: 'lblEditProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully`
  String get lblUpdateProfile {
    return Intl.message(
      'Profile updated successfully',
      name: 'lblUpdateProfile',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get btnVerifyTxt {
    return Intl.message('Verify', name: 'btnVerifyTxt', desc: '', args: []);
  }

  /// `Stop Notifications`
  String get stopNotifications {
    return Intl.message(
      'Stop Notifications',
      name: 'stopNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Mute Notifications`
  String get muteNotification {
    return Intl.message(
      'Mute Notifications',
      name: 'muteNotification',
      desc: '',
      args: [],
    );
  }

  /// `No data found`
  String get lblNoDataFound {
    return Intl.message(
      'No data found',
      name: 'lblNoDataFound',
      desc: '',
      args: [],
    );
  }

  /// `New Group`
  String get lblNewGroup {
    return Intl.message('New Group', name: 'lblNewGroup', desc: '', args: []);
  }

  /// `Create Group`
  String get createGroupBtn {
    return Intl.message(
      'Create Group',
      name: 'createGroupBtn',
      desc: '',
      args: [],
    );
  }

  /// `Create Channel`
  String get createChannelBtn {
    return Intl.message(
      'Create Channel',
      name: 'createChannelBtn',
      desc: '',
      args: [],
    );
  }

  /// `Enter group name`
  String get groupNamePlaceholder {
    return Intl.message(
      'Enter group name',
      name: 'groupNamePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Enter channel name`
  String get channelNamePlaceholder {
    return Intl.message(
      'Enter channel name',
      name: 'channelNamePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Group name can not be empty`
  String get groupNameError {
    return Intl.message(
      'Group name can not be empty',
      name: 'groupNameError',
      desc: '',
      args: [],
    );
  }

  /// `Channel name can not be empty`
  String get channelNameError {
    return Intl.message(
      'Channel name can not be empty',
      name: 'channelNameError',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get group {
    return Intl.message('Group', name: 'group', desc: '', args: []);
  }

  /// `Channel`
  String get channel {
    return Intl.message('Channel', name: 'channel', desc: '', args: []);
  }

  /// `Show Profile photo`
  String get lblShowProfilePhoto {
    return Intl.message(
      'Show Profile photo',
      name: 'lblShowProfilePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Up to 200000 Members`
  String get upTo200000Members {
    return Intl.message(
      'Up to 200000 Members',
      name: 'upTo200000Members',
      desc: '',
      args: [],
    );
  }

  /// `Please select group image`
  String get pleaseSelectGroupImage {
    return Intl.message(
      'Please select group image',
      name: 'pleaseSelectGroupImage',
      desc: '',
      args: [],
    );
  }

  /// `Please select channel image`
  String get pleaseSelectChannelImage {
    return Intl.message(
      'Please select channel image',
      name: 'pleaseSelectChannelImage',
      desc: '',
      args: [],
    );
  }

  /// `You can not add more than 200,000 members`
  String get groupMembersLimitrichMessage {
    return Intl.message(
      'You can not add more than 200,000 members',
      name: 'groupMembersLimitrichMessage',
      desc: '',
      args: [],
    );
  }

  /// `Notifications Settings`
  String get notificationsSettings {
    return Intl.message(
      'Notifications Settings',
      name: 'notificationsSettings',
      desc: '',
      args: [],
    );
  }

  /// `Privacy and Security`
  String get privacyAndSecurity {
    return Intl.message(
      'Privacy and Security',
      name: 'privacyAndSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menu {
    return Intl.message('Menu', name: 'menu', desc: '', args: []);
  }

  /// `Manager`
  String get sManager {
    return Intl.message('Manager', name: 'sManager', desc: '', args: []);
  }

  /// `HR`
  String get sHr {
    return Intl.message('HR', name: 'sHr', desc: '', args: []);
  }

  /// `My Profile`
  String get sProfile {
    return Intl.message('My Profile', name: 'sProfile', desc: '', args: []);
  }

  /// `Contacts`
  String get sContacts {
    return Intl.message('Contacts', name: 'sContacts', desc: '', args: []);
  }

  /// `Saved Messages`
  String get sSavedMessages {
    return Intl.message(
      'Saved Messages',
      name: 'sSavedMessages',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get sSettings {
    return Intl.message('Settings', name: 'sSettings', desc: '', args: []);
  }

  /// `Invite Friends`
  String get sInviteFriends {
    return Intl.message(
      'Invite Friends',
      name: 'sInviteFriends',
      desc: '',
      args: [],
    );
  }

  /// `DCR`
  String get sDcr {
    return Intl.message('DCR', name: 'sDcr', desc: '', args: []);
  }

  /// `User not found`
  String get userNotFound {
    return Intl.message(
      'User not found',
      name: 'userNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit from the Application?`
  String get lblAlertSubtitle {
    return Intl.message(
      'Are you sure you want to exit from the Application?',
      name: 'lblAlertSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Alert`
  String get lblAlert {
    return Intl.message('Alert', name: 'lblAlert', desc: '', args: []);
  }

  /// `No`
  String get lblNo {
    return Intl.message('No', name: 'lblNo', desc: '', args: []);
  }

  /// `Exit`
  String get lblExit {
    return Intl.message('Exit', name: 'lblExit', desc: '', args: []);
  }

  /// `Username can not be empty`
  String get userNameError {
    return Intl.message(
      'Username can not be empty',
      name: 'userNameError',
      desc: '',
      args: [],
    );
  }

  /// `About you can not be empty`
  String get aboutYouError {
    return Intl.message(
      'About you can not be empty',
      name: 'aboutYouError',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get updateBtnTxt {
    return Intl.message('Update', name: 'updateBtnTxt', desc: '', args: []);
  }

  /// `Please select profile image`
  String get pleaseSelectProfileImage {
    return Intl.message(
      'Please select profile image',
      name: 'pleaseSelectProfileImage',
      desc: '',
      args: [],
    );
  }

  /// `Create Profile`
  String get lblCreateProfile {
    return Intl.message(
      'Create Profile',
      name: 'lblCreateProfile',
      desc: '',
      args: [],
    );
  }

  /// `Info`
  String get info {
    return Intl.message('Info', name: 'info', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Please try again!`
  String get pleaseTryAgainTxt {
    return Intl.message(
      'Please try again!',
      name: 'pleaseTryAgainTxt',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong!`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong!',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `212 Private Messenger\nWelcomes You!`
  String get lblLoginText {
    return Intl.message(
      '212 Private Messenger\nWelcomes You!',
      name: 'lblLoginText',
      desc: '',
      args: [],
    );
  }

  /// `Please fill the details to Log In`
  String get lblLoginSubtitleText {
    return Intl.message(
      'Please fill the details to Log In',
      name: 'lblLoginSubtitleText',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get loginButtonTextRe {
    return Intl.message('Retry', name: 'loginButtonTextRe', desc: '', args: []);
  }

  /// `Login to your registered account`
  String get loginButtonTextSubTitle {
    return Intl.message(
      'Login to your registered account',
      name: 'loginButtonTextSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Enter Email Address`
  String get emailPlaceHolder {
    return Intl.message(
      'Enter Email Address',
      name: 'emailPlaceHolder',
      desc: '',
      args: [],
    );
  }

  /// `000 000 0000`
  String get phonePlaceholder {
    return Intl.message(
      '000 000 0000',
      name: 'phonePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Email cannot be empty`
  String get emailError {
    return Intl.message(
      'Email cannot be empty',
      name: 'emailError',
      desc: '',
      args: [],
    );
  }

  /// `Phone number cannot be empty`
  String get phoneError {
    return Intl.message(
      'Phone number cannot be empty',
      name: 'phoneError',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message('OR', name: 'or', desc: '', args: []);
  }

  /// `Google`
  String get googleText {
    return Intl.message('Google', name: 'googleText', desc: '', args: []);
  }

  /// `Facebook`
  String get facebookText {
    return Intl.message('Facebook', name: 'facebookText', desc: '', args: []);
  }

  /// `Search country`
  String get searchCountry {
    return Intl.message(
      'Search country',
      name: 'searchCountry',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid otp`
  String get otpError {
    return Intl.message(
      'Enter a valid otp',
      name: 'otpError',
      desc: '',
      args: [],
    );
  }

  /// `Didn't receive the otp?`
  String get otpNotReceivedText {
    return Intl.message(
      'Didn\'t receive the otp?',
      name: 'otpNotReceivedText',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submitButtonText {
    return Intl.message('Submit', name: 'submitButtonText', desc: '', args: []);
  }

  /// `Resend Otp`
  String get resendOtpText {
    return Intl.message(
      'Resend Otp',
      name: 'resendOtpText',
      desc: '',
      args: [],
    );
  }

  /// `Please verify phone number`
  String get verifyPhoneNumberError {
    return Intl.message(
      'Please verify phone number',
      name: 'verifyPhoneNumberError',
      desc: '',
      args: [],
    );
  }

  /// `Access this char from any Device`
  String get accessThisCharFromAnyDevice {
    return Intl.message(
      'Access this char from any Device',
      name: 'accessThisCharFromAnyDevice',
      desc: '',
      args: [],
    );
  }

  /// `Display name can not be empty`
  String get nameError {
    return Intl.message(
      'Display name can not be empty',
      name: 'nameError',
      desc: '',
      args: [],
    );
  }

  /// `This username is already taken. Please choose a different one.`
  String get userNameIsAlreadyInUse {
    return Intl.message(
      'This username is already taken. Please choose a different one.',
      name: 'userNameIsAlreadyInUse',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get comingSoon {
    return Intl.message('Coming soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Username must not contain spaces. However, it may include underscores (_), letters, numbers, and hyphens (-).`
  String get usernameValidationError {
    return Intl.message(
      'Username must not contain spaces. However, it may include underscores (_), letters, numbers, and hyphens (-).',
      name: 'usernameValidationError',
      desc: '',
      args: [],
    );
  }

  /// `Username contains invalid characters. Only letters, numbers, underscores (_), and hyphens (-) are allowed.`
  String get usernameInvalidCharacters {
    return Intl.message(
      'Username contains invalid characters. Only letters, numbers, underscores (_), and hyphens (-) are allowed.',
      name: 'usernameInvalidCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid username.`
  String get enterValidUsername {
    return Intl.message(
      'Please enter a valid username.',
      name: 'enterValidUsername',
      desc: '',
      args: [],
    );
  }

  /// `Username cannot be empty.`
  String get userIDError {
    return Intl.message(
      'Username cannot be empty.',
      name: 'userIDError',
      desc: '',
      args: [],
    );
  }

  /// `Archive`
  String get archive {
    return Intl.message('Archive', name: 'archive', desc: '', args: []);
  }

  /// `Unarchive`
  String get unArchive {
    return Intl.message('Unarchive', name: 'unArchive', desc: '', args: []);
  }

  /// `Delete this chat?`
  String get deleteThisChat {
    return Intl.message(
      'Delete this chat?',
      name: 'deleteThisChat',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this chat? This action cannot be undone, and all messages will be permanently removed from your device.`
  String get deleteChatSubtitle {
    return Intl.message(
      'Are you sure you want to delete this chat? This action cannot be undone, and all messages will be permanently removed from your device.',
      name: 'deleteChatSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No Archive Chats Found`
  String get noArchiveChatsFound {
    return Intl.message(
      'No Archive Chats Found',
      name: 'noArchiveChatsFound',
      desc: '',
      args: [],
    );
  }

  /// `You can forward messages to up to 5 members or groups.`
  String get forwardMessageLimitText {
    return Intl.message(
      'You can forward messages to up to 5 members or groups.',
      name: 'forwardMessageLimitText',
      desc: '',
      args: [],
    );
  }

  /// `Forward To`
  String get forwardTo {
    return Intl.message('Forward To', name: 'forwardTo', desc: '', args: []);
  }

  /// `{MemberName} has been removed from the {group}.`
  String memberRemovedFromTheGroupOrChannel(Object MemberName, Object group) {
    return Intl.message(
      '$MemberName has been removed from the $group.',
      name: 'memberRemovedFromTheGroupOrChannel',
      desc: '',
      args: [MemberName, group],
    );
  }

  /// `Connecting...`
  String get connecting {
    return Intl.message(
      'Connecting...',
      name: 'connecting',
      desc: '',
      args: [],
    );
  }

  /// `Disable Video`
  String get disableVideo {
    return Intl.message(
      'Disable Video',
      name: 'disableVideo',
      desc: '',
      args: [],
    );
  }

  /// `Enable Video`
  String get enableVideo {
    return Intl.message(
      'Enable Video',
      name: 'enableVideo',
      desc: '',
      args: [],
    );
  }

  /// `Public Users`
  String get publicUsers {
    return Intl.message(
      'Public Users',
      name: 'publicUsers',
      desc: '',
      args: [],
    );
  }

  /// `{groupOrChannel} updated successfully!`
  String groupOrChannelUpdateSuccessfully(Object groupOrChannel) {
    return Intl.message(
      '$groupOrChannel updated successfully!',
      name: 'groupOrChannelUpdateSuccessfully',
      desc: '',
      args: [groupOrChannel],
    );
  }

  /// `Edited`
  String get edited {
    return Intl.message('Edited', name: 'edited', desc: '', args: []);
  }

  /// `Clear All Notifications`
  String get clearNotification {
    return Intl.message(
      'Clear All Notifications',
      name: 'clearNotification',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear all notifications?`
  String get clearNotificationSubTitle {
    return Intl.message(
      'Are you sure you want to clear all notifications?',
      name: 'clearNotificationSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `To help you connect with friends already using the app, we can upload your contact list to our server. This is only used to match contacts — we never share your data.`
  String get contactUseDescription {
    return Intl.message(
      'To help you connect with friends already using the app, we can upload your contact list to our server. This is only used to match contacts — we never share your data.',
      name: 'contactUseDescription',
      desc: '',
      args: [],
    );
  }

  /// `Not Now`
  String get notNow {
    return Intl.message('Not Now', name: 'notNow', desc: '', args: []);
  }

  /// `Share Your Contacts?`
  String get shareYourContacts {
    return Intl.message(
      'Share Your Contacts?',
      name: 'shareYourContacts',
      desc: '',
      args: [],
    );
  }

  /// `Upload Contacts?`
  String get customContactUploadConsentTitle {
    return Intl.message(
      'Upload Contacts?',
      name: 'customContactUploadConsentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get lblContinue {
    return Intl.message('Continue', name: 'lblContinue', desc: '', args: []);
  }

  /// `We use your contacts to help you connect with friends on the app. Please enable contact access in Settings.`
  String get askContactPermission {
    return Intl.message(
      'We use your contacts to help you connect with friends on the app. Please enable contact access in Settings.',
      name: 'askContactPermission',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get noInternetConnection {
    return Intl.message(
      'No Internet Connection',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Something Went wrong!, while loading Messages. please try again`
  String get errorMessageForChatScreen {
    return Intl.message(
      'Something Went wrong!, while loading Messages. please try again',
      name: 'errorMessageForChatScreen',
      desc: '',
      args: [],
    );
  }

  /// `You can't send messages because you are no longer a member of the {name}.`
  String removedUserCannotSendMessage(Object name) {
    return Intl.message(
      'You can\'t send messages because you are no longer a member of the $name.',
      name: 'removedUserCannotSendMessage',
      desc: '',
      args: [name],
    );
  }

  /// `Unpin`
  String get unPin {
    return Intl.message('Unpin', name: 'unPin', desc: '', args: []);
  }

  /// `You cannot send messages to this user because their account has been deleted.`
  String get cannotSendMessageToDeletedUser {
    return Intl.message(
      'You cannot send messages to this user because their account has been deleted.',
      name: 'cannotSendMessageToDeletedUser',
      desc: '',
      args: [],
    );
  }

  /// `Please check your network settings.`
  String get pleaseCheckYournetworkSettings {
    return Intl.message(
      'Please check your network settings.',
      name: 'pleaseCheckYournetworkSettings',
      desc: '',
      args: [],
    );
  }

  /// `Nick name`
  String get nickName {
    return Intl.message('Nick name', name: 'nickName', desc: '', args: []);
  }

  /// `Nick name set successfully`
  String get nickNameSuccessfully {
    return Intl.message(
      'Nick name set successfully',
      name: 'nickNameSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Active Nick Name`
  String get activeNickName {
    return Intl.message(
      'Active Nick Name',
      name: 'activeNickName',
      desc: '',
      args: [],
    );
  }

  /// `Nick name stats change successfully`
  String get nickNameActiveSuccessfully {
    return Intl.message(
      'Nick name stats change successfully',
      name: 'nickNameActiveSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Please enter nick name`
  String get pleaseEnterNickName {
    return Intl.message(
      'Please enter nick name',
      name: 'pleaseEnterNickName',
      desc: '',
      args: [],
    );
  }

  /// `Send Message`
  String get sendMessage {
    return Intl.message(
      'Send Message',
      name: 'sendMessage',
      desc: '',
      args: [],
    );
  }

  /// `Please set a nickname before enabling this option.`
  String get setNicknameBeforeEnableNickName {
    return Intl.message(
      'Please set a nickname before enabling this option.',
      name: 'setNicknameBeforeEnableNickName',
      desc: '',
      args: [],
    );
  }

  /// `Video Call`
  String get videoCall {
    return Intl.message('Video Call', name: 'videoCall', desc: '', args: []);
  }

  /// `Call`
  String get call {
    return Intl.message('Call', name: 'call', desc: '', args: []);
  }

  /// `Mute`
  String get mute {
    return Intl.message('Mute', name: 'mute', desc: '', args: []);
  }

  /// `UnMute`
  String get unmute {
    return Intl.message('UnMute', name: 'unmute', desc: '', args: []);
  }

  /// `Read`
  String get read {
    return Intl.message('Read', name: 'read', desc: '', args: []);
  }

  /// `Unread`
  String get unread {
    return Intl.message('Unread', name: 'unread', desc: '', args: []);
  }

  /// `Set nick name`
  String get setNickName {
    return Intl.message(
      'Set nick name',
      name: 'setNickName',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'nl'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
