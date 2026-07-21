import 'dart:io';

class Urls {
  static const String url = 'http://45.248.67.90:8029/sfa/app_login_en/';
  static const String swaggerDoc =
      'https://telegram-clone-4gd7.onrender.com/api-docs';

  // static const String baseURL = 'http://18.130.137.253:3001';
  static const String baseURL = 'http://10.0.2.2:3000';
  static const String mediaUrl =
      'https://telegrameclone.s3.eu-west-2.amazonaws.com/';
}

class APIS {
  static const String sendOtp = '/api/v1/auth/send-otp';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String verifyEmailChange = '/api/v1/verify-email-change';
  static const String checkUserName = '/api/v1/check-username';
  static const String requestEmailChange = '/api/v1/request-email-change';
  static const String login = '/api/auth/login';
  static const String deleteToken = '/api/v1/delete-token';
  static const String deleteAccount = '/api/v1/auth/account-delete';
  static const String user = '/api/v1/users';
  static const String profile = '/api/auth/profile';
  static const String refresh = '/api/auth/refresh';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String getConversation = '/api/v1/chat/conversations/list';
  static const String getConversationForForwadMessage =
      '/api/v1/chat/forward/list';
  static const String createConversation = '/api/v1/chat/create-chat';
  static const String chat = '/api/v1/chat/';
  static const String sentMessage = '/api/v1/chat/sent-message';
  static const String sentSaveMessage = '/api/v1/send/saved-messages';
  static const String createStories = '/api/v1/stories/create-stories';
  static const String stories = '/api/v1/stories/';
  static const String getCurrentUserStories =
      '/api/v1/getUserStoriesWithViewerDetails';
  static const String deleteChatMessage = '/api/v1/chat/delete-message';
  static const String clearChat = '/api/v1/chat/clear-chat';
  static const String clearNotification = '/api/v1/clear-notification';
  static const String savedMessages = '/api/v1/saved-messages';
  static const String requestCall = '/api/v1/generate-token/';
  static const String getAppIdForAgora = "/api/v1/get-app_id";
  static const String createGroup = "/api/v1/group/create-group";
  static const String updateGroup = "/api/v1/group/update/";
  static const String clearAllSavedMessage = "/api/v1/unsaved-message";
  static const String deleteSavedMessage = "/api/v1/unsaved-message";
  static const String getGroupInfobyId = "/api/v1/group/";
  static const String assignAdminToGroup = "/api/v1/group/assignAdminToGroup";
  static const String removeMemberToGroup = "/api/v1/group/remove-member";
  static const String addMemberToGroup = "/api/v1/group/add-members";
  static const String deleteGroup = "/api/v1/group/delete/";
  static const String deleteChat = "/api/v1/delete-chat";
  static const String leaveGroup = "/api/v1/group/leaveGroup/";
  static const String joinGroupByInvite = "/api/v1/group/join/";
  static const String searchPublicGroups = "/api/v1/group/search-public";
  static const String searchDatabase = "/api/v1/group/search-database";
  static const String revokeGroupInviteLink =
      "/api/v1/group/revoke-invite-link/";
  static const String checkGroupInviteName = "/api/v1/group/check-invite-name";
  static const String getCallsHistory = "/api/v1/get-callhistory";
  static const String getAllNotifications = "/api/v1/get-notifications";
  static const String getProfile = "/api/v1/find-one-user";
  static const String clearCallLogs = '/api/v1/clear-call-log';
  static const String syncContact = '/api/v1/sync-contact';
  static const String blockedUser = '/api/v1/block-user';
  static const String getBlockedUsers = '/api/v1/blocked-users';
  static const String unBlockedUser = '/api/v1/unblock-user';
  static const String reportUser = '/api/v1/report-user';
  static const String refreshToken = '/api/v1/refresh-token';
  static const String updateFcmToken = '/api/v1/replace-token';
  static const String getAdsConfig = '/api/v1/ads-config';
  static const String setNickname = '/api/v1/setNickname';
  static const String toggleNickname = '/api/v1/toggle-nickname';
}
