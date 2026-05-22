class AppConstants {
  static const String inviteLinkForAndroid =
      "Hey! Check out this amazing app: https://play.google.com/store/apps/details?id=com.freshcodes.twoonetwomessenger";
  static const String inviteLinkForIos =
      "Hey! Check out this amazing app: https://apps.apple.com/app/";
  static const String appName = '212 Messenger';
  static const String messenger = 'Messenger';
  static const String iosGiphyApiKey = "U0uXHjc7ykXaDDWYknZywVTktrXsqIJA";
  static const String androidGiphyApiKey = "5XYDsKh9Eny3SmjmRMUr3mnWmMmWjFIC";

  //Socket Event
  static const socketUserOnline = 'user-online-success';
  static const archiveChat = 'archiveChat';
  static const unArchiveChat = 'unarchiveChat';
  static const onUnArchiveChat = 'chatUnarchived';
  static const onArchiveChat = 'chatArchived';
  static const errorMessage = 'error_message';
  static const emitUserOnlinestatus = 'user-online-status';
  static const emitMessageReadStatus = 'mark_message_as_read';
  static const socketJoinChat = 'joinChat';
  static const emitEndCall = 'end-call';
  static const onEndCall = "call-ended";
  static const socketReceiveMessage = 'receive_message';
  static const receiveSystemMessage = 'receive_system_message';
  static const deleteMessageEveryone = 'delete_message_everyone';
  static const socketReceiveGroupMessage = 'receive_group_message';
  static const socketStoryUploaded = 'storyUploaded';
  static const sendMessage = 'send_message';
  static const updateMessageAutoDeleteTime = 'updateMessageAutoDeleteTime';
  static const sendSavedMessage = 'sendSavedMessages';
  static const sendTyping = 'typing';
  static const receivedTypingStatus = 'typing_status';
  static const updateMessageStatus = 'message_status';
  static const userBlockedyou = 'userBlocked';
  static const removeFromGroup = 'removed_from_group';
  static const addtoGroupGroup = 'added_to_group';
  static const onAssignOrRemoveFromAdminToGroup = 'admin_add_removed';
  static const receiveCall = 'receiver-agora-token-generated';
  static const onMessageSaved = 'messageSaved';
  static const getUnreadNotificationCount =
      "unread-notification-count-response";
  static const setUnreadNotificationCount = "unread-notification-count";
  static const onEditMessage = "receive_edit_message";
  static const onEditSavedMessage = "receive_saved_edit_message";
  static const pinedMessage = "pinMessage";
  static const pinedSavedMessage = "pin_saved_message";
  static const unPinedMessage = "unpinMessage";
  static const unPinedSavedMessage = "saved_message_unpin";
  static const onUnPinedMessage = "messageUnPinned";
  static const onUnPinedSasvedMessage = "saved_message_unpin";
  static const onPinedMessage = "messagePinned";
  static const onPinnedSavedMessage = "saved_message_pinned";
  static const editMessageEvent = "editMessage";
  static const editSavedMessageEvent = "edit_saved_message";
  static const reactMessageEvent = "reactMessage";
  static const reactSavedMessageEvent = "react_saved_message";
  static const onReactMessageEvent = "receive_react_message";
  static const onReactSavedMessageEvent = "react_saved_message";
  static const forwardMessage = "forwardMessage";
  static const forwardSavedMessage = "saved_forward_message";
  static const chatClosed = "chatClosed";
  static const joinCall = "join-call";
  static const logout = "logout";
  static const heartBeat = "set_user_is_online";
  static const pinUnpinConversation = "pinUnpinConversation";
  static const pinConvesation = "pinConvesation";

  static const muteUnmuteConversation = "muteUnmuteConversation";
  static const muteConvesation = "muteConvesation";

  static const markMessageAsUnread = "mark_message_as_unread";
  

// static const markAsReadEmit  = "mark_message_as_read";
  //Error
  // static const String pleaseTryAgainTxt = 'Please try again!';
  // static const somethingWentWrong = 'Something went wrong!';

  // //Login
  // static const String lblLoginText = '212 Private Messenger\nWelcomes You!';
  // static const String lblLoginSubtitleText =
  //     'Please fill the details to Log In';

  // static const String loginButtonTextRe = 'Retry';
  // static const String loginButtonTextSubTitle =
  //     'Login to your registered account';
  // static const String password = 'Password';
  // static const String emailPlaceHolder = 'Enter Email Address';
  // static const String phonePlaceholder = '000 000 0000';
  // static const String emailError = 'Email cannot be empty';
  // static const String phoneError = 'Phone number cannot be empty';
  // static const String or = 'OR';
  // static const String googleText = 'Google';
  // static const String facebookText = 'Facebook';
  // static const String searchCountry = 'Search country';

  // // Otp

  // static const String otpError = 'Enter a valid otp';
  // static const String otpNotReceivedText = 'Didn\'t receive the otp?';
  // static const String submitButtonText = 'Submit';
  // static const String resendOtpText = 'Resend Otp';
  // static const String verifyPhoneNumberError = 'Please verify phone number';
  // static const String otpVerifySuccess = 'Otp verify successfully';

  // //side menu
  // static const String menu = 'Menu';
  // static const String sManager = 'Manager';
  // static const String sHr = 'HR';

  // static const String sProfile = 'My Profile';

  // static const String sContacts = 'Contacts';

  // static const String sSavedMessages = 'Saved Messages';
  // static const String sSettings = 'Settings';
  // static const String sInviteFriends = 'Invite Friends';
  // static const String sDcr = 'DCR';

  // //Home

  // static const String userNotFound = 'User not found';
  // static const String refresh = 'Refresh';

  // static const String lblAlertSubtitle =
  //     "Are you sure you want to exit from the Application?";
  // static const String lblAlert = "Alert";
  // static const String lblNo = "No";
  // static const String lblExit = "Exit";

  // //Profile

  // static const String userNameError = "Username can not be empty";
  // static const String userIDError = "Userid can not be empty";
  // static const String aboutYouError = "About you can not be empty";
  // static const String updateBtnTxt = "Update";

  // static const String pleaseSelectProfileImage = "Please select profile image";
  // static const String lblCreateProfile = "Create Profile";
  // static const String info = 'Info';
  // static const String phoneNumber = 'Phone Number';
  // static const String account = "Account";

  // //Edit profile
  // static const String lblEditProfile = "Edit Profile";
  // static const String lblUpdateProfile = 'Profile update successfully';
  // static const String btnVerifyTxt = 'Verify';
  // static const String stopNotifications = 'Stop Notifications';
  // static const String muteNotification = 'Mute Notifications';
  // // Search
  // static const String lblNoDataFound = "No data found";
  // // New Group
  // static const String lblNewGroup = 'New Group';
  // static const String createGroupBtn = 'Create Group';
  // static const String createChannelBtn = 'Create Channel';
  // static const String groupNamePlaceholder = "Enter group name";
  // static const String channelNamePlaceholder = "Enter channel name";
  // static const String groupNameError = "Group name can not be empty";
  // static const String channelNameError = "Channel name can not be empty";
  // static const String group = "Group";
  // static const String channel = "Channel";

  // static const String lblShowProfilePhoto = "Show Profile photo";

  // static const String upTo200000Members = "Up to 200000 Members";

  // static const String pleaseSelectGroupImage = "Please select group image";
  // static const String pleaseSelectChannelImage = "Please select channel image";
  // static const String groupMembersLimitrichMessage =
  //     "You can not add more then 2,00,000 members";
  // static const String notificationsSettings = "Notifications Settings";
  // static const String privacyAndSecurity = "Privacy and Security";
  // static const String upgradeToPremium = "Upgrade To Premium";
  // // Stories

  // static const String camera = 'Camera';
  // static const String gallery = 'Gallery';
  // static const String video = 'Video';
  // static const String image = 'Image';
  // static const String next = 'Next';
  // static const String writeCaptionHere = 'Write caption here';
  // static const String lblDeleteStories = 'Delete Story';
  // static const String lblDeleteStoriesSubTitle =
  //     'Are you sure that you want to remove the Story?';
  // static const String cancel = 'Cancel';
  // static const String delete = 'Delete';
  // static const String clear = 'Clear';

  // //Chat
  // static const String recording = "Recording";
  // static const String recording2 = "Recording...";
  // static const String tapToStartRecord = "Tap Start to record";
  // static const String restartRecording = "Restart Recoding...";
  // static const String pause = "Pause";
  // static const String start = "Start";
  // static const String restart = "Restart";
  // static const String stop = "Stop";
  // static const String send = "Send";
  // static const String lblDeleteMessageSubTitle =
  //     "Are you sure you want to delete this message?";
  // static const String lblClearChatSubTitle =
  //     "Are you sure you want to clear chat?";
  // static const String accept = 'Accept';
  // static const String reject = 'Reject';
  // static const String endCall = 'End Call';
  // static const String groupCreatedEmptyChatMsg =
  //     "has created a new group, so you can start the conversation!";
  // static const String channelCreatedEmptyChatMsg = "has created a new channel";

  // //Saved message
  // static const String yourCloudStorage = "Your Cloud Storage";
  // static const String forwardMessageHereToSaveThem =
  //     "Forward Message here to save them";
  // static const String sendMediaAndFilesToStoreThem =
  //     "Send Media and Files to store them";
  // static const String accessThisCharFromAnyDevice =
  //     "Access this char from any Device";
  // static const String useSearchToQuicklyFindThings =
  //     "Use search to quickly find things";

// //Contacts

//   static const String sSearchContacts = "Search contacts...";
//   static const String sortedByLastSeenTime = "Sorted by Last seen time";

// //Groups

//   static const String deleteGroup = "Delete Group";
//   static const String deleteChannel = "Delete Channel";
//   static const String leaveGroup = "Leave Group";
//   static const String leaveChannel = "Leave Channel";
//   static const String addMembers = "Add Members";
//   static const String lblDeleteGroupSubTitle =
//       "Are you sure you want to delete this Group?";
//   static const String lblLeaveGroupSubTitle =
//       "Are you sure you want to leave from this Group?";
//   static const String lblDeleteChannelSubTitle =
//       "Are you sure you want to delete this Channel?";
//   static const String lblLeaveChannelSubTitle =
//       "Are you sure you want to leave from this Channel?";
// //Invite Friends
//   static const String selectContactToInviteThem =
//       "Select contacts to invite them to 212 Private Messenger";
//   static const String notifications = 'Notifications';
//   static const String sSearchNotifications = "Search notifications...";
//   static const String yes = "Yes";
//   static const String no = "No";
//   static const String update = "Update";

// //Calls
//   static const String noCallHistoryFound = "No Call History Found";
//   static const String noNotificationsFound = "No Notifications Found";
}

class SvgAssets {
  static const String svgImage = "assets/svg/";
  static const String logo = '${svgImage}logo.svg';
  static const String menu = '${svgImage}menu.svg';

  static const String icLogout = '${svgImage}logout.svg';
  static const String icBrightness = '${svgImage}brightness.svg';
  static const String icSettings = '${svgImage}settings.svg';
  static const String icPerson = '${svgImage}person.svg';
  static const String icBookmarks = '${svgImage}bookmarks.svg';
  static const String icCalls = '${svgImage}calls.svg';
  static const String icContacts = '${svgImage}contacts.svg';
  static const String icInviteFriends = '${svgImage}invite_friends.svg';
  static const String icNewGroup = '${svgImage}new_group.svg';

  static const String icEmail = '${svgImage}email.svg';
  static const String icContact = '${svgImage}contact.svg';
  static const String icArrowBack = '${svgImage}arrow_back.svg';
  static const String icNotification = '${svgImage}notification.svg';
  static const String icSearch = '${svgImage}search.svg';
  static const String icDownArrow = '${svgImage}down_arrow.svg';
  static const String icEdit = '${svgImage}edit.svg';
  static const String icMoreDots = '${svgImage}menu_dots.svg';
  static const String icQrCode = '${svgImage}qr_code.svg';
  static const String icCamera = '${svgImage}camera.svg';
  static const String icGallery = '${svgImage}gallery.svg';
  static const String icVideo = '${svgImage}video.svg';
  static const String icImage = '${svgImage}image.svg';
  static const String icInfo = '${svgImage}info.svg';
  static const String icIdCard = '${svgImage}id_card.svg';
  static const String icPhone = '${svgImage}phone.svg';
  static const String icSend = '${svgImage}send.svg';
  static const String icAddRounded = '${svgImage}add_rounded.svg';
  static const String icEye = '${svgImage}eye.svg';
  static const String icTrash = '${svgImage}trash.svg';
  static const String icMicrophone = '${svgImage}microphone.svg';
  static const String icGalleryTwo = '${svgImage}gallery_two.svg';
  static const String icGif = '${svgImage}gif.svg';
  static const String icGiftCard = '${svgImage}gift_card.svg';
  static const String icSettingsOutline = '${svgImage}settings_outline.svg';
  static const String icVideoOutline = '${svgImage}video_outline.svg';
  static const String icDocumentOutline = '${svgImage}document_outline.svg';
  static const String messageDoubleTick = '${svgImage}messageDoubleTick.svg';
  static const String messageSingleTick = '${svgImage}messageSingleTick.svg';
  static const String circlePhone = '${svgImage}circle-phone.svg';
  static const String speacker = '${svgImage}speacker.svg';
  static const String cloudStorage = '${svgImage}cloud_storage.svg';
  static const String megaphone = '${svgImage}megaphone.svg';
  static const String person2 = '${svgImage}person2.svg';
  static const String checkIcon = '${svgImage}checkIcon.svg';
  static const String deleteUser = '${svgImage}deleteUser.svg';
  static const String adminUseralt = '${svgImage}adminalt.svg';
  static const String clearChat = '${svgImage}clearChat.svg';
  // static const String callCircleFill = '${svgImage}call_circle_fill.svg';
  static const String closeRed = '${svgImage}close_red.svg';
  static const String arrowLeftDown = '${svgImage}arrow-small-down.svg';
  static const String arrowGreenUp = '${svgImage}arrow-small-up.svg';
  static const String notificationFill = "${svgImage}notificationFill.svg";
  static const String language = "${svgImage}language.svg";
  static const String passwordLock = "${svgImage}password-lock.svg";
  static const String giftIcon = "${svgImage}gift.svg";
  static const String giftFillIcon = "${svgImage}giftfill.svg";
  static const String messageSentPendingIcon =
      "${svgImage}messageSentPending.svg";
}

class ImgAssets {
  static const String image = "assets/image/";
  static const String splashBg = '${image}splash_bg.png';
  static const String logo = '${image}logo.png';
  static const String icGoogle = '${image}google.png';
  static const String icFacebook = '${image}facebook.png';
}

class SoundAssets {
  static const String bellStandardCall = 'assets/sound/bell_standard_call.mp3';
  static const String sendBeep = 'assets/sound/send_beep.mp3';
}
