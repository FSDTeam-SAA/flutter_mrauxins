import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/services/api_client.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/alert_dialog.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class ContactService {
  final DatabaseHelper dbHelper;
  final ApiClient apiClient;
  ContactService({required this.dbHelper, required this.apiClient});

  Future<void> fetchAndStoreLocalContacts() async {
    if (!await Utils.hasContactsPermission()) {
      await CustomAlertDialog(
        context: navigatorKey.currentContext!,
        icon: SvgImage(
          source: SvgAssets.icSettings,
          color: AppColors.white,
          height: 28.w,
          width: 28.w,
        ),
        title: S.current.permissionRequired,
        description: S.current.askContactPermission,
        buttonText: S.current.openSetting,
        onPressed: () => openAppSettings(),
      );
      await AppPreference.setBoolean(LocalDbConstants.contactPermission,
          value: false);
      return;
    }
    if (!(await Utils.askContactPermission())) {
      showMessage("fetchAndStoreLocalContacts");
      return;
    }

    // Fetch local contacts from device
    List<Contact> localContacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone});

    // showMessage("D localContacts $localContacts");

    // Convert to a map of phone numbers for quick lookup
    Map<String, String> localContactsMap = {
      for (var contact in localContacts)
        Utils.removeSpaceAndSpecialCharectorsFromString(
                contact.phones.isNotEmpty ? contact.phones.first.number : ""):
            (contact.displayName ?? "").isEmpty
                ? (contact.displayName ?? "")
                : "${contact.name?.first ?? ''} ${contact.name?.last ?? ''}"
    };

    // showMessage("D localContactsMap $localContactsMap");

    // log("Local Contacts: ${localContactsMap}");

    // Fetch all stored contacts from the database
    List<ContactUser> storedContacts = await dbHelper.getAllContacts();

    // showMessage("D storedContacts ${storedContacts.length}");

    // Convert stored contacts to a set of phone numbers for comparison
    // Set<String> storedPhoneNumbers =
    //     storedContacts.map((contact) => contact.phone ?? "").toSet();

    // **Step 1: Add or Update Contacts**
    for (var entry in localContactsMap.entries) {
      String phoneNumber = entry.key;
      String displayName = entry.value;

      ContactUser? existingContact =
          await dbHelper.getContactByPhone(phoneNumber, "");

      // log("contact ===> $displayName  $phoneNumber  ${existingContact?.name}");
      if (existingContact != null) {
        // Update only if the name has changed
        // if (displayName.isNotEmpty && existingContact.name != displayName) {
        //   await dbHelper.updateLocalContact(phoneNumber, displayName);
        // }
      } else {
        // Insert new contact
        await dbHelper.insertContact(ContactUser(
          phone: phoneNumber,
          name: displayName,
          isRegistered: false, // Initially assume not registered
        ));
      }
    }

    // **Step 2: Remove Deleted Contacts**
    for (var storedContact in storedContacts) {
      if (!localContactsMap.containsKey(storedContact.phone)) {
        await dbHelper.deleteContactByPhone(storedContact.phone ?? "");
        showMessage("Deleted contact: ${storedContact.phone}");
      }
    }
  }

  /// Get all contacts from the database
  Future<List<ContactUser>> getAllLocalContacts() async {
    return await dbHelper.getAllContacts();
  }

  Future<List<ContactUser>> syncApiUsersWithContacts({
    required BuildContext context,
    required String searchQuery,
    required List<String> contactNumbers,
    required int page,
    required int limit,
    required List<Participant> removedUsers,
  }) async {
    try {
      AllUserResponse response = await apiClient.getAllUser(
          searchQuery, page, limit, context, contactNumbers);
      List<ContactUser> otherUser = [];
      if (response.status == Utils.APISUCCESS) {
        List<UserData> apiUsers = response.data?.users ?? [];

        // UserData? bockUserData = apiUsers.firstWhere(
        //     (element) => element.chatId == "6890589a7afcdd6bc152c7a6");

        Set<String> removedUserIds = removedUsers.map((p) => p.id!).toSet();
        // showMessage("getAllUser ${bockUserData.toJson()}");
        List<ContactUser> updatedContacts = [];

        for (var apiUser in apiUsers) {
          if (removedUserIds.contains(apiUser.sId)) continue;
          if (apiUser.phone == null) {
            ContactUser otherContact = ContactUser.fromJson(apiUser.toJson());
            otherUser.add(otherContact.copyWith(isRegistered: true));
            continue;
          }
          ContactUser? existingContact = await dbHelper.getContactByPhone(
              apiUser.phone ?? "", apiUser.email ?? "");

          if (existingContact != null) {
            // Update existing contact with API data
            // log("existingContact in ${existingContact.name}  ${existingContact.toJson()}");

            showMessage("Datas existingContact ${existingContact.toJson()}");

            ContactUser updatedContact = existingContact.copyWith(
              isRegistered: true,
              profilePicture: apiUser.profilePicture,
              bio: apiUser.bio,
              countryCode: apiUser.countryCode,
              // phone: apiUser.phone,
              countryISOCode: apiUser.countryISOCode,
              createdAt: apiUser.createdAt,
              email: apiUser.email,
              iV: apiUser.iV,
              isOnline: apiUser.isOnline,
              lastSeen: apiUser.lastSeen,
              sId: apiUser.sId,
              updatedAt: apiUser.updatedAt,
              userName: apiUser.userName,
              name: (apiUser.name != null && apiUser.name!.isNotEmpty)
                  ? apiUser.name
                  : (existingContact.name ?? ""),
              chatId: apiUser.chatId,
              isBlocked: apiUser.isBlocked,
              youBlocked: apiUser.youBlocked,
              messageAutoDeleteTime: apiUser.messageAutoDeleteTime,
              nickName: apiUser.nickName,
              isActiveNickname: apiUser.isActiveNickname,
            );

            // showMessage("Datas updateContact ${updatedContact.toJson()}");

            await dbHelper.updateContact(updatedContact);
            updatedContacts.add(updatedContact);

            // showMessage("DTA MNMN ${updatedContacts.where(
            //       (element) => element.sId == "6889bb3b3b3a715e65331b1b",
            //     ).firstOrNull?.toJson()}");
          } else {
            // Insert new API user as a contact
            ContactUser otherContact = ContactUser.fromJson(apiUser.toJson());
            otherUser.add(otherContact.copyWith(isRegistered: true));
            // ContactUser newContact = ContactUser(
            //   phone: apiUser.phone,
            //   name: apiUser.name,
            //   isRegistered: true,
            //   profilePicture: apiUser.profilePicture,
            // );
            // await dbHelper.insertContact(newContact);
            // updatedContacts.add(newContact);
          }
        }
      }
      return otherUser;
    } catch (e) {
      showMessage("Error syncing API users: $e");
      return [];
    }
  }

  /// Search local contacts first, then fetch API users if necessary
  Future<List<ContactUser>> searchContacts(
      BuildContext context, String searchQuery, int page, int limit) async {
    // 1️⃣ Get contacts from local DB
    List<ContactUser> localResults =
        await dbHelper.searchContacts(searchQuery, limit, limit * page);

    // 2️⃣ If we have enough local results, return them
    if (localResults.length >= limit) {
      return localResults;
    }

    // // 3️⃣ If not enough results, fetch from API
    // await syncApiUsersWithContacts(
    //   context: context,
    //   searchQuery: searchQuery,
    //   page: page,
    //   limit: limit,
    //   removedUsers: [],
    // );

    // 4️⃣ Fetch updated local contacts again
    return await dbHelper.searchContacts(searchQuery, limit, page * limit);
  }
}
