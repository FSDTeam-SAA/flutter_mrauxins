import 'dart:convert';

import '../utils/logger.dart';


class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final List<MenuOption> menuOptions;
  final UserProfile profile;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.menuOptions,
    required this.profile,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      menuOptions: (json['menu_options'] as List)
          .map((e) => MenuOption.fromJson(e))
          .toList(),
      profile: UserProfile.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "access_token": accessToken,
      "refresh_token": refreshToken,
      "menu_options": menuOptions.map((option) => option.toJson()),
      "profile": profile,
    };
  }
}

class MenuOption {
  final String menuTitle;
  final bool displayMenu;
  final List<SubmenuOption> submenuOptions;
  final List<String> access;
  final List<String> forbidden;

  MenuOption({
    required this.menuTitle,
    required this.displayMenu,
    required this.submenuOptions,
    required this.access,
    required this.forbidden,
  });

  factory MenuOption.fromJson(Map<String, dynamic> json) {
    return MenuOption(
      menuTitle: json['menu_title'],
      displayMenu: json['display_menu'],
      submenuOptions: (json['submenu_options'] as List)
          .map((e) => SubmenuOption.fromJson(e))
          .toList(),
      // access: List<String>.from(json['access']),
      // forbidden: List<String>.from(json['forbidden']),
      access: _parseList(json['access']),
      forbidden: _parseList(json['forbidden']),
    );
  }
  factory MenuOption.fromJsonGet(Map<String, dynamic> json) {
    return MenuOption(
      menuTitle: json['menu_title'],
      displayMenu: json['display_menu'],
      submenuOptions: (jsonDecode(json['submenu_options']) as List)
          .map((e) => SubmenuOption.fromJson(e))
          .toList(),
      // access: List<String>.from(json['access']),
      // forbidden: List<String>.from(json['forbidden']),
      access: _parseList(json['access']),
      forbidden: _parseList(json['forbidden']),
    );
  }

  /// Helper function to handle both List<String> and comma-separated String.
  static List<String> _parseList(dynamic data) {
    if (data is List) {
      return List<String>.from(data);
    } else if (data is String) {
      return data.split(',').map((e) => e.trim()).toList();
    } else {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "menu_title": menuTitle,
      "display_menu": displayMenu,
      "submenu_options": jsonEncode(submenuOptions),
      "access": jsonEncode(access),
      "forbidden": jsonEncode(forbidden),
    };
  }
}

class SubmenuOption {
  final String title;
  final bool display;

  SubmenuOption({required this.title, required this.display});

  factory SubmenuOption.fromJson(Map<String, dynamic> json) {
    return SubmenuOption(
      title: json['title'],
      display: json['display'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "display": display,
    };
  }
}

class UserProfile {
  final String login;
  final String empNo;
  final String name;
  final String slDivCd;
  final String allwdSlDivCd;
  final String email;
  final String? privAdmin;
  final String? mfa;
  final String? phone;
  final String? role;
  final String? picture;
  final String? activationCode;
  final String? active;
  final int? dcrBlk;
  final String? dcrBlkRsn;
  final int? tpBlk;
  final String? tpBlkRsn;
  final DateTime pswdLastUpdated;
  final DateTime? mfaLastUpdated;

  UserProfile({
    required this.login,
    required this.empNo,
    required this.name,
    required this.slDivCd,
    required this.allwdSlDivCd,
    required this.email,
    this.privAdmin,
    this.mfa,
    this.phone,
    this.role,
    this.picture,
    this.activationCode,
    this.active,
    this.dcrBlk,
    this.dcrBlkRsn,
    this.tpBlk,
    this.tpBlkRsn,
    required this.pswdLastUpdated,
    this.mfaLastUpdated,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      login: json['login'],
      empNo: json['EmpNo'],
      name: json['name'],
      slDivCd: json['SlDivCd'],
      allwdSlDivCd: json['AllwdSlDivCd'],
      email: json['email'],
      privAdmin: json['priv_admin'],
      mfa: json['mfa'],
      phone: json['phone'],
      role: json['role'],
      picture: json['picture'],
      activationCode: json['activation_code'],
      active: json['active'],
      dcrBlk: json['DCRBlk'],
      dcrBlkRsn: json['DCRBlkRsn'],
      tpBlk: json['TPBlk'],
      tpBlkRsn: json['TPBlkRsn'],
      pswdLastUpdated: _parseDate(json['pswd_last_updated'])!,
      mfaLastUpdated: _parseDate(json['mfa_last_updated']),
    );
  }
  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      AppLogger.logs('Invalid date format: $dateString'); // For debugging
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "login": login,
      "EmpNo": empNo,
      "name": name,
      "SlDivCd": slDivCd,
      "AllwdSlDivCd": allwdSlDivCd,
      "email": email,
      "priv_admin": privAdmin,
      "mfa": mfa,
      "phone": phone,
      "role": role,
      "picture": picture,
      "activation_code": activationCode,
      "active": active,
      "DCRBlk": dcrBlk,
      "DCRBlkRsn": dcrBlkRsn,
      "TPBlk": tpBlk,
      "TPBlkRsn": tpBlkRsn,
      "pswd_last_updated": pswdLastUpdated.toIso8601String(),
      "mfa_last_updated": mfaLastUpdated?.toIso8601String() ?? '',
    };
  }
}
