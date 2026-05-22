// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(userName) =>
      "${userName} will no longer be able to call or send you messages.";

  static String m1(userName) => "you blocked ${userName} successfully";

  static String m2(userName) =>
      "You can\'t send messages to ${userName} because you have blocked them.";

  static String m3(value) => "${value} selected";

  static String m4(userName, days) =>
      "${userName} uses the default timer for disappearing messages in new chats. New messages will disappear from this chat in ${days} days after they\'re sent, except when kept.\nTap to set your own default timer.";

  static String m5(value) => "Edit ${value}";

  static String m6(groupOrChannel) => "${groupOrChannel} updated successfully!";

  static String m7(value) => "Is \'${value}\' still your email address?";

  static String m8(value) => "Is \'${value}\' still your Number?";

  static String m9(value) => "Please enter the OTP received at ${value}";

  static String m10(MemberName, group) =>
      "${MemberName} has been removed from the ${group}.";

  static String m11(value) => "${value} Members";

  static String m12(value) => "${value} Subscriber";

  static String m13(number) => "${number} archived chats available";

  static String m14(name) =>
      "You can\'t send messages because you are no longer a member of the ${name}.";

  static String m15(userName) =>
      "You will be able to receive messages and calls from ${userName} again.";

  static String m16(userName) => "You unblocked ${userName} successfully";

  static String m17(userName) =>
      "${userName} is Blocked you so you can\'t send messages to them.";

  static String m18(name) => "You have successfully reported user ${name}.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutYouError": MessageLookupByLibrary.simpleMessage(
      "About you can not be empty",
    ),
    "aboutYouPlaceholder": MessageLookupByLibrary.simpleMessage("About you"),
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "accessThisCharFromAnyDevice": MessageLookupByLibrary.simpleMessage(
      "Access this char from any Device",
    ),
    "accessThisChatFromAnyDevice": MessageLookupByLibrary.simpleMessage(
      "Access this chat from any device",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "activeNickName": MessageLookupByLibrary.simpleMessage("Active Nick Name"),
    "adFreeUserMessage": MessageLookupByLibrary.simpleMessage(
      "You\'re an Ad-Free user! Enjoy using our app without ads. Upgrade to Premium for even more exclusive features.",
    ),
    "addFewWordsAboutYourself": MessageLookupByLibrary.simpleMessage(
      "Add a few words about yourself in Profile Settings.",
    ),
    "addMembers": MessageLookupByLibrary.simpleMessage("Add Members"),
    "addMessage": MessageLookupByLibrary.simpleMessage("Add a message..."),
    "addSubscribers": MessageLookupByLibrary.simpleMessage("Add Subscribers"),
    "admin": MessageLookupByLibrary.simpleMessage("Admin"),
    "allowMembersToSendMessage": MessageLookupByLibrary.simpleMessage(
      "Allow members to send message",
    ),
    "archive": MessageLookupByLibrary.simpleMessage("Archive"),
    "archiveChats": MessageLookupByLibrary.simpleMessage("Archive Chats"),
    "areYouSureToWantToArchiveThisChat": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to archive this chat?",
    ),
    "areYouSureToWantToUnArchiveThisChat": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to unarchive this chat?",
    ),
    "askContactPermission": MessageLookupByLibrary.simpleMessage(
      "We use your contacts to help you connect with friends on the app. Please enable contact access in Settings.",
    ),
    "bio": MessageLookupByLibrary.simpleMessage("Bio"),
    "block": MessageLookupByLibrary.simpleMessage("Block"),
    "blockUser": MessageLookupByLibrary.simpleMessage("Block user"),
    "blockUserSubtitle": m0,
    "blockUserSuccessfully": m1,
    "blockUserTitle": MessageLookupByLibrary.simpleMessage("Block User?"),
    "blockedContacts": MessageLookupByLibrary.simpleMessage("Blocked contacts"),
    "blockedUserCannotSendMessage": m2,
    "btnVerifyTxt": MessageLookupByLibrary.simpleMessage("Verify"),
    "buyAdFree": MessageLookupByLibrary.simpleMessage("Buy Ad-Free"),
    "buyPremium": MessageLookupByLibrary.simpleMessage("Buy Premium"),
    "call": MessageLookupByLibrary.simpleMessage("Call"),
    "callHistory": MessageLookupByLibrary.simpleMessage("Call History"),
    "calls": MessageLookupByLibrary.simpleMessage("Call"),
    "camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotSendMessageToDeletedUser": MessageLookupByLibrary.simpleMessage(
      "You cannot send messages to this user because their account has been deleted.",
    ),
    "channel": MessageLookupByLibrary.simpleMessage("Channel"),
    "channelCreatedEmptyChatMsg": MessageLookupByLibrary.simpleMessage(
      "has created a new channel",
    ),
    "channelNameError": MessageLookupByLibrary.simpleMessage(
      "Channel name can not be empty",
    ),
    "channelNamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Enter channel name",
    ),
    "channelPermission": MessageLookupByLibrary.simpleMessage(
      "Channel Permission",
    ),
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearCallLog": MessageLookupByLibrary.simpleMessage("Clear call logs"),
    "clearChat": MessageLookupByLibrary.simpleMessage("Clear Chat"),
    "clearNotification": MessageLookupByLibrary.simpleMessage(
      "Clear All Notifications",
    ),
    "clearNotificationSubTitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all notifications?",
    ),
    "clear_all_calls_subtitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete all call history? This action cannot be undone.",
    ),
    "clear_all_calls_title": MessageLookupByLibrary.simpleMessage(
      "Clear Call History",
    ),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
    "contactUseDescription": MessageLookupByLibrary.simpleMessage(
      "To help you connect with friends already using the app, we can upload your contact list to our server. This is only used to match contacts — we never share your data.",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Copied to clipboard!",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "countSelected": m3,
    "createChannelBtn": MessageLookupByLibrary.simpleMessage("Create Channel"),
    "createGroupBtn": MessageLookupByLibrary.simpleMessage("Create Group"),
    "customContactUploadConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Upload Contacts?",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete Account"),
    "deleteAccountSlogen": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete your account? This action is irreversible, and all your messages, contacts, and data will be permanently lost.",
    ),
    "deleteChannel": MessageLookupByLibrary.simpleMessage("Delete Channel"),
    "deleteChatSubtitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this chat? This action cannot be undone, and all messages will be permanently removed from your device.",
    ),
    "deleteForMe": MessageLookupByLibrary.simpleMessage("Delete for me"),
    "deleteGroup": MessageLookupByLibrary.simpleMessage("Delete Group"),
    "deleteGroupAuthority": MessageLookupByLibrary.simpleMessage(
      "Only the group creator can delete the group.",
    ),
    "deleteMessageForEveryone": MessageLookupByLibrary.simpleMessage(
      "Delete for everyone",
    ),
    "deleteSelected": MessageLookupByLibrary.simpleMessage("Delete Selected"),
    "deleteThisChat": MessageLookupByLibrary.simpleMessage("Delete this chat?"),
    "delete_selected_calls_subtitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete the selected calls? This action cannot be undone.",
    ),
    "delete_selected_calls_title": MessageLookupByLibrary.simpleMessage(
      "Delete Selected Calls",
    ),
    "disableVideo": MessageLookupByLibrary.simpleMessage("Disable Video"),
    "disappearingMessage": MessageLookupByLibrary.simpleMessage(
      "Disappearing messages",
    ),
    "disappearingMessageDescription": MessageLookupByLibrary.simpleMessage(
      "When turned on, all new individual chats will start with disappearing messages set to the duration you select. This setting will not affect your existing chats.",
    ),
    "disappearingMessageInfo": m4,
    "disappearingMessageTitle": MessageLookupByLibrary.simpleMessage(
      "Start new chat with disappearing message timer set to",
    ),
    "document": MessageLookupByLibrary.simpleMessage("Document"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editImage": MessageLookupByLibrary.simpleMessage("Edit Image"),
    "editMessage": MessageLookupByLibrary.simpleMessage("Edit Message"),
    "editPhoneOrEmail": m5,
    "edited": MessageLookupByLibrary.simpleMessage("Edited"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailAddressIsAlreadyUpdated": MessageLookupByLibrary.simpleMessage(
      "Please change email address before the update",
    ),
    "emailAddressIsInvalid": MessageLookupByLibrary.simpleMessage(
      "Email address is invalid",
    ),
    "emailAdress": MessageLookupByLibrary.simpleMessage("Email Adrress"),
    "emailChangeSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Email adrress change successfully",
    ),
    "emailError": MessageLookupByLibrary.simpleMessage("Email cannot be empty"),
    "emailPlaceHolder": MessageLookupByLibrary.simpleMessage(
      "Enter Email Address",
    ),
    "emailVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Email address verified successfully",
    ),
    "enableVideo": MessageLookupByLibrary.simpleMessage("Enable Video"),
    "endCall": MessageLookupByLibrary.simpleMessage("End Call"),
    "enterValidUsername": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid username.",
    ),
    "errorCannotRemoveEmail": MessageLookupByLibrary.simpleMessage(
      "You cannot remove the email because your phone number is not registered or verified in your account.",
    ),
    "errorCannotRemovePhone": MessageLookupByLibrary.simpleMessage(
      "You cannot remove the phone number because your email is not registered or verified in your account.",
    ),
    "errorMessageForChatScreen": MessageLookupByLibrary.simpleMessage(
      "Something Went wrong!, while loading Messages. please try again",
    ),
    "facebookText": MessageLookupByLibrary.simpleMessage("Facebook"),
    "forward": MessageLookupByLibrary.simpleMessage("Forward"),
    "forwardMessageHereToSaveThem": MessageLookupByLibrary.simpleMessage(
      "Forward Message here to save them",
    ),
    "forwardMessageLimitText": MessageLookupByLibrary.simpleMessage(
      "You can forward messages to up to 5 members or groups.",
    ),
    "forwardTo": MessageLookupByLibrary.simpleMessage("Forward To"),
    "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "giftsCommingSoon": MessageLookupByLibrary.simpleMessage(
      "Gifts Coming Soon!",
    ),
    "giftsCommingSoonMessage": MessageLookupByLibrary.simpleMessage(
      "We’re working hard to bring you a fun new way to send gifts. Stay tuned, and keep an eye out for this feature in the next update!",
    ),
    "googleText": MessageLookupByLibrary.simpleMessage("Google"),
    "group": MessageLookupByLibrary.simpleMessage("Group"),
    "groupCreatedEmptyChatMsg": MessageLookupByLibrary.simpleMessage(
      "has created a new group, so you can start the conversation!",
    ),
    "groupMembers": MessageLookupByLibrary.simpleMessage("Group Members"),
    "groupMembersLimitrichMessage": MessageLookupByLibrary.simpleMessage(
      "You can not add more than 200,000 members",
    ),
    "groupNameError": MessageLookupByLibrary.simpleMessage(
      "Group name can not be empty",
    ),
    "groupNamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Enter group name",
    ),
    "groupOrChannelUpdateSuccessfully": m6,
    "groupPermission": MessageLookupByLibrary.simpleMessage("Group Permission"),
    "image": MessageLookupByLibrary.simpleMessage("Image"),
    "info": MessageLookupByLibrary.simpleMessage("Info"),
    "invalid_phone_number": MessageLookupByLibrary.simpleMessage(
      "The phone number is invalid. Please check and try again.",
    ),
    "inviteFriend": MessageLookupByLibrary.simpleMessage("Invite Friend"),
    "inviteToChannel": MessageLookupByLibrary.simpleMessage(
      "Invite To Channel",
    ),
    "inviteToGroup": MessageLookupByLibrary.simpleMessage("Invite To Group"),
    "isStillYourEmailAddress": m7,
    "isStillYourNumber": m8,
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languages": MessageLookupByLibrary.simpleMessage("Languages"),
    "lblAlert": MessageLookupByLibrary.simpleMessage("Alert"),
    "lblAlertSubtitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit from the Application?",
    ),
    "lblChannelInfo": MessageLookupByLibrary.simpleMessage("Channel Info"),
    "lblClearChatSubTitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear chat?",
    ),
    "lblContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "lblCreateProfile": MessageLookupByLibrary.simpleMessage("Create Profile"),
    "lblDeleteChannelSubTitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this Channel?",
    ),
    "lblDeleteGroupSubTitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this Group?",
    ),
    "lblDeleteMessage": MessageLookupByLibrary.simpleMessage("Delete Message"),
    "lblDeleteMessageSubTitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this message?",
    ),
    "lblDeleteStories": MessageLookupByLibrary.simpleMessage("Delete Story"),
    "lblDeleteStoriesSubTitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure that you want to remove the Story?",
    ),
    "lblEditProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "lblEmailChangeTxt": MessageLookupByLibrary.simpleMessage(
      "Tap to change the Email Adrress",
    ),
    "lblExit": MessageLookupByLibrary.simpleMessage("Exit"),
    "lblGroupInfo": MessageLookupByLibrary.simpleMessage("Group Info"),
    "lblKeepYourEmailAddressUptoDate": MessageLookupByLibrary.simpleMessage(
      "Keep your email address up to date to ensure you can always log into 212 Private Messenger.",
    ),
    "lblKeepYourNumberUptoDate": MessageLookupByLibrary.simpleMessage(
      "Keep your number up to date to ensure you can always log into 212 Private Messenger.",
    ),
    "lblLeaveChannelSubTitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to leave from this Channel?",
    ),
    "lblLeaveGroupSubTitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to leave from this Group?",
    ),
    "lblLoginSubtitleText": MessageLookupByLibrary.simpleMessage(
      "Please fill the details to Log In",
    ),
    "lblLoginText": MessageLookupByLibrary.simpleMessage(
      "212 Private Messenger\nWelcomes You!",
    ),
    "lblNewGroup": MessageLookupByLibrary.simpleMessage("New Group"),
    "lblNo": MessageLookupByLibrary.simpleMessage("No"),
    "lblNoDataFound": MessageLookupByLibrary.simpleMessage("No data found"),
    "lblOtpSubtitleText": m9,
    "lblOtpText": MessageLookupByLibrary.simpleMessage(
      "Enter\nVerification Code",
    ),
    "lblPhoneChangeTxt": MessageLookupByLibrary.simpleMessage(
      "Tap to change the Phone Number",
    ),
    "lblSearchChat": MessageLookupByLibrary.simpleMessage("Search Chat"),
    "lblSearchUser": MessageLookupByLibrary.simpleMessage("Search User"),
    "lblShowProfilePhoto": MessageLookupByLibrary.simpleMessage(
      "Show Profile photo",
    ),
    "lblUpdateProfile": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully",
    ),
    "lblUploadMedias": MessageLookupByLibrary.simpleMessage(
      "Upload Media from",
    ),
    "lblUploadPhotos": MessageLookupByLibrary.simpleMessage(
      "Upload Photos from",
    ),
    "leaveChannel": MessageLookupByLibrary.simpleMessage("Leave Channel"),
    "leaveGroup": MessageLookupByLibrary.simpleMessage("Leave Group"),
    "logIn": MessageLookupByLibrary.simpleMessage("Log In"),
    "loginButtonTextRe": MessageLookupByLibrary.simpleMessage("Retry"),
    "loginButtonTextSubTitle": MessageLookupByLibrary.simpleMessage(
      "Login to your registered account",
    ),
    "makeProfilePrivate": MessageLookupByLibrary.simpleMessage(
      "Make Profile Private",
    ),
    "memberRemovedFromTheGroupOrChannel": m10,
    "menu": MessageLookupByLibrary.simpleMessage("Menu"),
    "message": MessageLookupByLibrary.simpleMessage("Message"),
    "messageEncryptionInfo": MessageLookupByLibrary.simpleMessage(
      "Messages are end-to-end encrypted. No one outside this chat, not even 212 Messenger, can read or listen to them.",
    ),
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "mute": MessageLookupByLibrary.simpleMessage("Mute"),
    "muteNotification": MessageLookupByLibrary.simpleMessage(
      "Mute Notifications",
    ),
    "nameError": MessageLookupByLibrary.simpleMessage(
      "Display name can not be empty",
    ),
    "namePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Enter Display Name",
    ),
    "network_request_failed": MessageLookupByLibrary.simpleMessage(
      "Network error. Please check your internet connection.",
    ),
    "newChannel": MessageLookupByLibrary.simpleMessage("New Channel"),
    "newContacts": MessageLookupByLibrary.simpleMessage("New Contacts"),
    "newGroup": MessageLookupByLibrary.simpleMessage("New Group"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "nickName": MessageLookupByLibrary.simpleMessage("Nick name"),
    "nickNameActiveSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Nick name stats change successfully",
    ),
    "nickNameSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Nick name set successfully",
    ),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noArchiveChatsFound": MessageLookupByLibrary.simpleMessage(
      "No Archive Chats Found",
    ),
    "noCallHistoryFound": MessageLookupByLibrary.simpleMessage(
      "No Call History Found",
    ),
    "noContactsFound": MessageLookupByLibrary.simpleMessage(
      "No registered contact available. Please invite a member",
    ),
    "noConversationsFound": MessageLookupByLibrary.simpleMessage(
      "No Conversations Found",
    ),
    "noEmailAddress": MessageLookupByLibrary.simpleMessage("No email address"),
    "noInternetConnection": MessageLookupByLibrary.simpleMessage(
      "No Internet Connection",
    ),
    "noMessage": MessageLookupByLibrary.simpleMessage("No message"),
    "noNotificationsFound": MessageLookupByLibrary.simpleMessage(
      "No Notifications Found",
    ),
    "noOfMember": m11,
    "noOfSubscriber": m12,
    "noPhoneNumber": MessageLookupByLibrary.simpleMessage("No phone number"),
    "noStories": MessageLookupByLibrary.simpleMessage("No Stories"),
    "noStoriesUploadedDescription": MessageLookupByLibrary.simpleMessage(
      "You haven\'t uploaded anything to your story yet. Please add stories by clicking the plus button below.",
    ),
    "noSubscriptionMessage": MessageLookupByLibrary.simpleMessage(
      "Upgrade to enhance your experience! Choose Ad-Free to remove ads or go Premium for the full set of exclusive features.",
    ),
    "noViewsYetForStories": MessageLookupByLibrary.simpleMessage(
      "No views yet. Your story hasn\'t been seen by anyone.",
    ),
    "notNow": MessageLookupByLibrary.simpleMessage("Not Now"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "notificationsSettings": MessageLookupByLibrary.simpleMessage(
      "Notifications Settings",
    ),
    "numberOfArchiveChats": m13,
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "online": MessageLookupByLibrary.simpleMessage("Online"),
    "onlyAdminsCanSendMessages": MessageLookupByLibrary.simpleMessage(
      "Only Admins can send messages",
    ),
    "openSetting": MessageLookupByLibrary.simpleMessage("Open Settings"),
    "or": MessageLookupByLibrary.simpleMessage("OR"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherUsers": MessageLookupByLibrary.simpleMessage("Other Users"),
    "otpError": MessageLookupByLibrary.simpleMessage("Enter a valid otp"),
    "otpIsInvalid": MessageLookupByLibrary.simpleMessage("Otp is invalid"),
    "otpNotReceivedText": MessageLookupByLibrary.simpleMessage(
      "Didn\'t receive the otp?",
    ),
    "otpVerifySuccess": MessageLookupByLibrary.simpleMessage(
      "Otp verified successfully",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "Permission Required",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "phoneError": MessageLookupByLibrary.simpleMessage(
      "Phone number cannot be empty",
    ),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "phonePlaceholder": MessageLookupByLibrary.simpleMessage("000 000 0000"),
    "phoneVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Phone number verified successfully",
    ),
    "pin": MessageLookupByLibrary.simpleMessage("Pin"),
    "pleaseChangePhoneNumberBeforeUpdate": MessageLookupByLibrary.simpleMessage(
      "Please change phone number before update",
    ),
    "pleaseCheckYournetworkSettings": MessageLookupByLibrary.simpleMessage(
      "Please check your network settings.",
    ),
    "pleaseEnterEmailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Please provide an email address OR phone number",
    ),
    "pleaseEnterNickName": MessageLookupByLibrary.simpleMessage(
      "Please enter nick name",
    ),
    "pleaseEnterYourEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Please enter your email address",
    ),
    "pleaseEnterYourOTP": MessageLookupByLibrary.simpleMessage(
      "Please enter your otp",
    ),
    "pleaseFillOnlyOneFieldEmailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Please fill only one field: Email or Phone.",
    ),
    "pleaseSelectChannelImage": MessageLookupByLibrary.simpleMessage(
      "Please select channel image",
    ),
    "pleaseSelectGroupImage": MessageLookupByLibrary.simpleMessage(
      "Please select group image",
    ),
    "pleaseSelectProfileImage": MessageLookupByLibrary.simpleMessage(
      "Please select profile image",
    ),
    "pleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Something went wrong!, please try again",
    ),
    "pleaseTryAgainTxt": MessageLookupByLibrary.simpleMessage(
      "Please try again!",
    ),
    "pleaseVerifyEmail": MessageLookupByLibrary.simpleMessage(
      "please verify your email",
    ),
    "premiumComingSoon": MessageLookupByLibrary.simpleMessage(
      "Premium is coming soon! Stay tuned for exclusive features.",
    ),
    "premiumScreenTitle": MessageLookupByLibrary.simpleMessage(
      "212 Messenger Premium",
    ),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage(
      "Privacy and Security",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy policy"),
    "privateProfileText": MessageLookupByLibrary.simpleMessage(
      "Your profile is private. Only known contacts can find you.",
    ),
    "publicProfileText": MessageLookupByLibrary.simpleMessage(
      "Your profile is visible to everyone.",
    ),
    "publicUsers": MessageLookupByLibrary.simpleMessage("Public Users"),
    "quota_exceeded": MessageLookupByLibrary.simpleMessage(
      "OTP request limit exceeded. Try again later.",
    ),
    "react": MessageLookupByLibrary.simpleMessage("React"),
    "read": MessageLookupByLibrary.simpleMessage("Read"),
    "recentMessage": MessageLookupByLibrary.simpleMessage("Recent Messages"),
    "recording": MessageLookupByLibrary.simpleMessage("Recording"),
    "recording2": MessageLookupByLibrary.simpleMessage("Recording..."),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "reject": MessageLookupByLibrary.simpleMessage("Reject"),
    "removeEmailSuccess": MessageLookupByLibrary.simpleMessage(
      "Email adress remove successfully",
    ),
    "removePhoneSuccess": MessageLookupByLibrary.simpleMessage(
      "Phone number remove successfully",
    ),
    "removedUserCannotSendMessage": m14,
    "reply": MessageLookupByLibrary.simpleMessage("Reply"),
    "replyingTo": MessageLookupByLibrary.simpleMessage("Replying to: "),
    "reportReasonFakeProfile": MessageLookupByLibrary.simpleMessage(
      "Fake Profile",
    ),
    "reportReasonHarassment": MessageLookupByLibrary.simpleMessage(
      "Harassment",
    ),
    "reportReasonHateSpeech": MessageLookupByLibrary.simpleMessage(
      "Hate Speech",
    ),
    "reportReasonInappropriateContent": MessageLookupByLibrary.simpleMessage(
      "Inappropriate Content",
    ),
    "reportReasonScamOrFraud": MessageLookupByLibrary.simpleMessage(
      "Scam or Fraud",
    ),
    "reportReasonSpam": MessageLookupByLibrary.simpleMessage("Spam"),
    "reportReasonViolenceOrThreats": MessageLookupByLibrary.simpleMessage(
      "Violence or Threats",
    ),
    "reportUser": MessageLookupByLibrary.simpleMessage("Report User"),
    "reportUserButton": MessageLookupByLibrary.simpleMessage("Report User"),
    "reportUserDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Describe the issue (up to 300 characters)...",
    ),
    "reportUserDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Additional Details (Optional)",
    ),
    "reportUserReasonLabel": MessageLookupByLibrary.simpleMessage(
      "Please select reason for report",
    ),
    "reportUserTitle": MessageLookupByLibrary.simpleMessage("Report User"),
    "resendOtpText": MessageLookupByLibrary.simpleMessage("Resend Otp"),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartRecording": MessageLookupByLibrary.simpleMessage(
      "Restart Recording...",
    ),
    "restorePurchase": MessageLookupByLibrary.simpleMessage(
      "Restore Purchases",
    ),
    "sCalls": MessageLookupByLibrary.simpleMessage("Calls"),
    "sContacts": MessageLookupByLibrary.simpleMessage("Contacts"),
    "sDcr": MessageLookupByLibrary.simpleMessage("DCR"),
    "sHr": MessageLookupByLibrary.simpleMessage("HR"),
    "sInviteFriends": MessageLookupByLibrary.simpleMessage("Invite Friends"),
    "sLastSeen": MessageLookupByLibrary.simpleMessage("Last seen "),
    "sLogout": MessageLookupByLibrary.simpleMessage("Logout"),
    "sLogoutMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure that you want to Logout the Application?",
    ),
    "sManager": MessageLookupByLibrary.simpleMessage("Manager"),
    "sProfile": MessageLookupByLibrary.simpleMessage("My Profile"),
    "sSavedMessages": MessageLookupByLibrary.simpleMessage("Saved Messages"),
    "sSearchContacts": MessageLookupByLibrary.simpleMessage(
      "Search contacts...",
    ),
    "sSearchNotifications": MessageLookupByLibrary.simpleMessage(
      "Search notifications...",
    ),
    "sSettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveMessage": MessageLookupByLibrary.simpleMessage("Save Message"),
    "searchConversations": MessageLookupByLibrary.simpleMessage(
      "Search conversations...",
    ),
    "searchCountry": MessageLookupByLibrary.simpleMessage("Search country"),
    "searchUsers": MessageLookupByLibrary.simpleMessage("Search Users"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select All"),
    "selectContactToInviteThem": MessageLookupByLibrary.simpleMessage(
      "Select contacts to invite them to 212 Private Messenger",
    ),
    "selectMedia": MessageLookupByLibrary.simpleMessage("Select Media"),
    "send": MessageLookupByLibrary.simpleMessage("Send"),
    "sendMediaAndFilesToStoreThem": MessageLookupByLibrary.simpleMessage(
      "Send Media and Files to store them",
    ),
    "sendMessage": MessageLookupByLibrary.simpleMessage("Send Message"),
    "setNickName": MessageLookupByLibrary.simpleMessage("Set nick name"),
    "setNicknameBeforeEnableNickName": MessageLookupByLibrary.simpleMessage(
      "Please set a nickname before enabling this option.",
    ),
    "shareYourContacts": MessageLookupByLibrary.simpleMessage(
      "Share Your Contacts?",
    ),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "Something went wrong!",
    ),
    "somethingWentWrongPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Please try again.",
    ),
    "sortedByLastSeenTime": MessageLookupByLibrary.simpleMessage(
      "Sorted by Last seen time",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopNotifications": MessageLookupByLibrary.simpleMessage(
      "Stop Notifications",
    ),
    "submitButtonText": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscribers": MessageLookupByLibrary.simpleMessage("Subscribers"),
    "tapToStartRecord": MessageLookupByLibrary.simpleMessage(
      "Tap Start to record",
    ),
    "timer24Hours": MessageLookupByLibrary.simpleMessage("24 Hours"),
    "timer7Days": MessageLookupByLibrary.simpleMessage("7 Days"),
    "timer90Days": MessageLookupByLibrary.simpleMessage("90 Days"),
    "timerOff": MessageLookupByLibrary.simpleMessage("Off"),
    "todayStories": MessageLookupByLibrary.simpleMessage("Today’s Stories"),
    "too_many_requests": MessageLookupByLibrary.simpleMessage(
      "Too many attempts. Please try again later.",
    ),
    "typeMessage": MessageLookupByLibrary.simpleMessage("Type Message"),
    "unArchive": MessageLookupByLibrary.simpleMessage("Unarchive"),
    "unBlockUser": MessageLookupByLibrary.simpleMessage("Unblock User"),
    "unPin": MessageLookupByLibrary.simpleMessage("Unpin"),
    "unblockUserSubtitle": m15,
    "unblockUserSuccessfully": m16,
    "unblockUserTitle": MessageLookupByLibrary.simpleMessage("Unblock User?"),
    "unmute": MessageLookupByLibrary.simpleMessage("UnMute"),
    "unread": MessageLookupByLibrary.simpleMessage("Unread"),
    "upTo200000Members": MessageLookupByLibrary.simpleMessage(
      "Up to 200000 Members",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateBtnTxt": MessageLookupByLibrary.simpleMessage("Update"),
    "upgradeToPremium": MessageLookupByLibrary.simpleMessage(
      "Upgrade to Premium",
    ),
    "uploadStory": MessageLookupByLibrary.simpleMessage("Upload Story"),
    "useSearchToQuicklyFindThings": MessageLookupByLibrary.simpleMessage(
      "Use search to quickly find things",
    ),
    "userBlockedYouSoCannotSendMessage": m17,
    "userIDError": MessageLookupByLibrary.simpleMessage(
      "Username cannot be empty.",
    ),
    "userNameError": MessageLookupByLibrary.simpleMessage(
      "Username can not be empty",
    ),
    "userNameIsAlreadyInUse": MessageLookupByLibrary.simpleMessage(
      "This username is already taken. Please choose a different one.",
    ),
    "userNotFound": MessageLookupByLibrary.simpleMessage("User not found"),
    "username": MessageLookupByLibrary.simpleMessage("User Name"),
    "usernameInvalidCharacters": MessageLookupByLibrary.simpleMessage(
      "Username contains invalid characters. Only letters, numbers, underscores (_), and hyphens (-) are allowed.",
    ),
    "usernamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Enter Username",
    ),
    "usernameValidationError": MessageLookupByLibrary.simpleMessage(
      "Username must not contain spaces. However, it may include underscores (_), letters, numbers, and hyphens (-).",
    ),
    "verificationOtp": MessageLookupByLibrary.simpleMessage("Verification Otp"),
    "verifyPhoneNumberError": MessageLookupByLibrary.simpleMessage(
      "Please verify phone number",
    ),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoCall": MessageLookupByLibrary.simpleMessage("Video Call"),
    "videoDurationIsMorethen30Sec": MessageLookupByLibrary.simpleMessage(
      "Video duration exceeds 30 seconds. Please select a shorter video.",
    ),
    "viewContact": MessageLookupByLibrary.simpleMessage("View contact"),
    "whoWouldYouLikeToAdd": MessageLookupByLibrary.simpleMessage(
      "Who would you like to add?",
    ),
    "writeCaptionHere": MessageLookupByLibrary.simpleMessage(
      "Write caption here",
    ),
    "wrongOtp": MessageLookupByLibrary.simpleMessage(
      "The OTP you entered is incorrect. Please try again.",
    ),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "you": MessageLookupByLibrary.simpleMessage("You"),
    "youCanAddAnEmailAddressInProfileSettings":
        MessageLookupByLibrary.simpleMessage(
          "You can add an email address in Profile Settings.",
        ),
    "youCanAddPhoneNumberInProfileSettings":
        MessageLookupByLibrary.simpleMessage(
          "You can add a phone number in Profile Settings.",
        ),
    "youHaveSuccesfullyRepoartuser": m18,
    "yourCloudStorage": MessageLookupByLibrary.simpleMessage(
      "Your Cloud Storage",
    ),
    "yourStories": MessageLookupByLibrary.simpleMessage("Your Stories"),
  };
}
