// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(userName) =>
      "${userName} kann dich nicht mehr anrufen oder Nachrichten senden.";

  static String m1(userName) => "Du hast ${userName} erfolgreich blockiert";

  static String m2(userName) =>
      "Du kannst ${userName} keine Nachrichten senden, weil du sie blockiert hast.";

  static String m3(value) => "${value} ausgewählt";

  static String m4(userName, days) =>
      "${userName} verwendet den Standard-Timer für verschwindende Nachrichten in neuen Chats. Neue Nachrichten verschwinden in diesem Chat nach ${days} Tagen, außer wenn sie behalten werden.\nTippe, um deinen eigenen Standard-Timer festzulegen.";

  static String m5(value) => "${value} bearbeiten";

  static String m6(groupOrChannel) =>
      "${groupOrChannel} wurde erfolgreich aktualisiert!";

  static String m7(value) => "Ist \'${value}\' noch deine E-Mail-Adresse?";

  static String m8(value) => "Ist \'${value}\' noch deine Nummer?";

  static String m9(value) =>
      "Bitte geben Sie das OTP ein, das an ${value} gesendet wurde";

  static String m10(MemberName, group) =>
      "${MemberName} wurde aus der ${group} entfernt.";

  static String m11(value) => "${value} Mitglieder";

  static String m12(value) => "${value} Abonnent";

  static String m13(number) => "${number} archivierte Chats verfügbar";

  static String m14(name) =>
      "Du kannst keine Nachrichten senden, da du kein Mitglied von ${name} mehr bist.";

  static String m15(userName) =>
      "Du kannst wieder Nachrichten und Anrufe von ${userName} empfangen.";

  static String m16(userName) => "Du hast ${userName} erfolgreich entsperrt";

  static String m17(userName) =>
      "${userName} hat dich blockiert, daher kannst du keine Nachrichten senden.";

  static String m18(name) =>
      "Du hast den Benutzer ${name} erfolgreich gemeldet.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutYouError": MessageLookupByLibrary.simpleMessage(
      "\'Über dich\' darf nicht leer sein",
    ),
    "aboutYouPlaceholder": MessageLookupByLibrary.simpleMessage("Über dich"),
    "accept": MessageLookupByLibrary.simpleMessage("Akzeptieren"),
    "accessThisCharFromAnyDevice": MessageLookupByLibrary.simpleMessage(
      "Greife von jedem Gerät auf diesen Chat zu",
    ),
    "accessThisChatFromAnyDevice": MessageLookupByLibrary.simpleMessage(
      "Greife von jedem Gerät auf diesen Chat zu",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Konto"),
    "adFreeUserMessage": MessageLookupByLibrary.simpleMessage(
      "Du bist ein werbefreier Nutzer! Genieße unsere App ohne Werbung. Upgrade auf Premium für noch mehr exklusive Funktionen.",
    ),
    "addFewWordsAboutYourself": MessageLookupByLibrary.simpleMessage(
      "Füge ein paar Worte über dich in den Profileinstellungen hinzu.",
    ),
    "addMembers": MessageLookupByLibrary.simpleMessage("Mitglieder hinzufügen"),
    "addMessage": MessageLookupByLibrary.simpleMessage(
      "Nachricht hinzufügen...",
    ),
    "addSubscribers": MessageLookupByLibrary.simpleMessage(
      "Abonnenten hinzufügen",
    ),
    "admin": MessageLookupByLibrary.simpleMessage("Administrator"),
    "allowMembersToSendMessage": MessageLookupByLibrary.simpleMessage(
      "Mitgliedern erlauben, Nachrichten zu senden",
    ),
    "archive": MessageLookupByLibrary.simpleMessage("Archivieren"),
    "archiveChats": MessageLookupByLibrary.simpleMessage("Chats archivieren"),
    "areYouSureToWantToArchiveThisChat": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diesen Chat archivieren möchtest?",
    ),
    "areYouSureToWantToUnArchiveThisChat": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diesen Chat aus dem Archiv entfernen möchtest?",
    ),
    "askContactPermission": MessageLookupByLibrary.simpleMessage(
      "Wir verwenden deine Kontakte, um dir zu helfen, Freunde in der App zu finden. Bitte aktiviere den Kontaktzugriff in den Einstellungen.",
    ),
    "bio": MessageLookupByLibrary.simpleMessage("Biografie"),
    "block": MessageLookupByLibrary.simpleMessage("Blockieren"),
    "blockUser": MessageLookupByLibrary.simpleMessage("Benutzer blockieren"),
    "blockUserSubtitle": m0,
    "blockUserSuccessfully": m1,
    "blockUserTitle": MessageLookupByLibrary.simpleMessage(
      "Benutzer blockieren?",
    ),
    "blockedContacts": MessageLookupByLibrary.simpleMessage(
      "Blockierte Kontakte",
    ),
    "blockedUserCannotSendMessage": m2,
    "btnVerifyTxt": MessageLookupByLibrary.simpleMessage("Verifizieren"),
    "buyAdFree": MessageLookupByLibrary.simpleMessage("Werbefrei kaufen"),
    "buyPremium": MessageLookupByLibrary.simpleMessage("Premium kaufen"),
    "callHistory": MessageLookupByLibrary.simpleMessage("Anrufverlauf"),
    "calls": MessageLookupByLibrary.simpleMessage("Anruf"),
    "camera": MessageLookupByLibrary.simpleMessage("Kamera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "cannotSendMessageToDeletedUser": MessageLookupByLibrary.simpleMessage(
      "Du kannst diesem Benutzer keine Nachrichten senden, da sein Konto gelöscht wurde.",
    ),
    "channel": MessageLookupByLibrary.simpleMessage("Kanal"),
    "channelCreatedEmptyChatMsg": MessageLookupByLibrary.simpleMessage(
      "hat einen neuen Kanal erstellt",
    ),
    "channelNameError": MessageLookupByLibrary.simpleMessage(
      "Kanalname darf nicht leer sein",
    ),
    "channelNamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Kanalname eingeben",
    ),
    "channelPermission": MessageLookupByLibrary.simpleMessage(
      "Kanalberechtigung",
    ),
    "clear": MessageLookupByLibrary.simpleMessage("Löschen"),
    "clearCallLog": MessageLookupByLibrary.simpleMessage(
      "Anrufprotokolle löschen",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Chat löschen"),
    "clearNotification": MessageLookupByLibrary.simpleMessage(
      "Alle Benachrichtigungen löschen",
    ),
    "clearNotificationSubTitle": MessageLookupByLibrary.simpleMessage(
      "Möchtest du wirklich alle Benachrichtigungen löschen?",
    ),
    "clear_all_calls_subtitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du den gesamten Anrufverlauf löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.",
    ),
    "clear_all_calls_title": MessageLookupByLibrary.simpleMessage(
      "Anrufverlauf löschen",
    ),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Demnächst verfügbar"),
    "connecting": MessageLookupByLibrary.simpleMessage(
      "Verbindung wird hergestellt...",
    ),
    "contactUseDescription": MessageLookupByLibrary.simpleMessage(
      "Um dir zu helfen, Freunde zu finden, die die App bereits nutzen, können wir mit deiner Zustimmung deine Kontaktliste auf unseren Server hochladen. Diese wird nur verwendet, um Kontakte abzugleichen – deine Daten werden niemals weitergegeben.",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "In die Zwischenablage kopiert!",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Kopieren"),
    "countSelected": m3,
    "createChannelBtn": MessageLookupByLibrary.simpleMessage("Kanal erstellen"),
    "createGroupBtn": MessageLookupByLibrary.simpleMessage("Gruppe erstellen"),
    "customContactUploadConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Kontakte hochladen?",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Konto löschen"),
    "deleteAccountSlogen": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du dein Konto löschen möchtest? Diese Aktion ist unwiderruflich, und alle deine Nachrichten, Kontakte und Daten gehen dauerhaft verloren.",
    ),
    "deleteChannel": MessageLookupByLibrary.simpleMessage("Kanal löschen"),
    "deleteChatSubtitle": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie diesen Chat löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden und alle Nachrichten werden dauerhaft von Ihrem Gerät entfernt.",
    ),
    "deleteForMe": MessageLookupByLibrary.simpleMessage("Für mich löschen"),
    "deleteGroup": MessageLookupByLibrary.simpleMessage("Gruppe löschen"),
    "deleteGroupAuthority": MessageLookupByLibrary.simpleMessage(
      "Nur der Gruppenersteller kann die Gruppe löschen.",
    ),
    "deleteMessageForEveryone": MessageLookupByLibrary.simpleMessage(
      "Für alle löschen",
    ),
    "deleteSelected": MessageLookupByLibrary.simpleMessage(
      "Ausgewählte löschen",
    ),
    "deleteThisChat": MessageLookupByLibrary.simpleMessage(
      "Diesen Chat löschen?",
    ),
    "delete_selected_calls_subtitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du die ausgewählten Anrufe löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.",
    ),
    "delete_selected_calls_title": MessageLookupByLibrary.simpleMessage(
      "Ausgewählte Anrufe löschen",
    ),
    "disableVideo": MessageLookupByLibrary.simpleMessage("Video deaktivieren"),
    "disappearingMessage": MessageLookupByLibrary.simpleMessage(
      "Verschwindende Nachrichten",
    ),
    "disappearingMessageDescription": MessageLookupByLibrary.simpleMessage(
      "Wenn aktiviert, beginnen alle neuen Einzelchats mit verschwindenden Nachrichten, die für die von dir gewählte Dauer festgelegt sind. Diese Einstellung wirkt sich nicht auf deine bestehenden Chats aus.",
    ),
    "disappearingMessageInfo": m4,
    "disappearingMessageTitle": MessageLookupByLibrary.simpleMessage(
      "Neuen Chat mit aktivierter Selbstzerstörung für Nachrichten starten",
    ),
    "document": MessageLookupByLibrary.simpleMessage("Dokument"),
    "edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
    "editImage": MessageLookupByLibrary.simpleMessage("Bild bearbeiten"),
    "editMessage": MessageLookupByLibrary.simpleMessage("Nachricht bearbeiten"),
    "editPhoneOrEmail": m5,
    "edited": MessageLookupByLibrary.simpleMessage("Bearbeitet"),
    "email": MessageLookupByLibrary.simpleMessage("E-Mail"),
    "emailAddressIsAlreadyUpdated": MessageLookupByLibrary.simpleMessage(
      "Bitte ändere die E-Mail-Adresse vor dem Update.",
    ),
    "emailAddressIsInvalid": MessageLookupByLibrary.simpleMessage(
      "Die E-Mail-Adresse ist ungültig",
    ),
    "emailAdress": MessageLookupByLibrary.simpleMessage("E-Mail-Adresse"),
    "emailChangeSuccessfully": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Adresse erfolgreich geändert",
    ),
    "emailError": MessageLookupByLibrary.simpleMessage(
      "E-Mail darf nicht leer sein",
    ),
    "emailPlaceHolder": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Adresse eingeben",
    ),
    "emailVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Adresse erfolgreich verifiziert",
    ),
    "enableVideo": MessageLookupByLibrary.simpleMessage("Video aktivieren"),
    "endCall": MessageLookupByLibrary.simpleMessage("Anruf beenden"),
    "enterValidUsername": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie einen gültigen Benutzernamen ein.",
    ),
    "errorCannotRemoveEmail": MessageLookupByLibrary.simpleMessage(
      "Du kannst die E-Mail nicht entfernen, da deine Telefonnummer nicht in deinem Konto registriert oder verifiziert ist.",
    ),
    "errorCannotRemovePhone": MessageLookupByLibrary.simpleMessage(
      "Du kannst die Telefonnummer nicht entfernen, da deine E-Mail nicht in deinem Konto registriert oder verifiziert ist.",
    ),
    "facebookText": MessageLookupByLibrary.simpleMessage("Facebook"),
    "forward": MessageLookupByLibrary.simpleMessage("Weiterleiten"),
    "forwardMessageHereToSaveThem": MessageLookupByLibrary.simpleMessage(
      "Leite Nachrichten hier weiter, um sie zu speichern",
    ),
    "forwardMessageLimitText": MessageLookupByLibrary.simpleMessage(
      "Du kannst Nachrichten an bis zu 5 Mitglieder oder Gruppen weiterleiten.",
    ),
    "forwardTo": MessageLookupByLibrary.simpleMessage("Weiterleiten an"),
    "gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "giftsCommingSoon": MessageLookupByLibrary.simpleMessage(
      "Geschenke kommen bald!",
    ),
    "giftsCommingSoonMessage": MessageLookupByLibrary.simpleMessage(
      "Wir arbeiten hart daran, dir eine neue unterhaltsame Möglichkeit zum Versenden von Geschenken zu bieten. Bleib dran und halte Ausschau nach dieser Funktion im nächsten Update!",
    ),
    "googleText": MessageLookupByLibrary.simpleMessage("Google"),
    "group": MessageLookupByLibrary.simpleMessage("Gruppe"),
    "groupCreatedEmptyChatMsg": MessageLookupByLibrary.simpleMessage(
      "hat eine neue Gruppe erstellt, also kannst du mit dem Gespräch beginnen!",
    ),
    "groupMembers": MessageLookupByLibrary.simpleMessage("Gruppenmitglieder"),
    "groupMembersLimitrichMessage": MessageLookupByLibrary.simpleMessage(
      "Du kannst nicht mehr als 200.000 Mitglieder hinzufügen",
    ),
    "groupNameError": MessageLookupByLibrary.simpleMessage(
      "Gruppenname darf nicht leer sein",
    ),
    "groupNamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Gruppenname eingeben",
    ),
    "groupOrChannelUpdateSuccessfully": m6,
    "groupPermission": MessageLookupByLibrary.simpleMessage(
      "Gruppenberechtigung",
    ),
    "image": MessageLookupByLibrary.simpleMessage("Bild"),
    "info": MessageLookupByLibrary.simpleMessage("Info"),
    "invalid_phone_number": MessageLookupByLibrary.simpleMessage(
      "Die Telefonnummer ist ungültig. Bitte überprüfen Sie sie und versuchen Sie es erneut.",
    ),
    "inviteFriend": MessageLookupByLibrary.simpleMessage("Freund einladen"),
    "inviteToChannel": MessageLookupByLibrary.simpleMessage(
      "In den Kanal einladen",
    ),
    "inviteToGroup": MessageLookupByLibrary.simpleMessage(
      "In die Gruppe einladen",
    ),
    "isStillYourEmailAddress": m7,
    "isStillYourNumber": m8,
    "language": MessageLookupByLibrary.simpleMessage("Sprache"),
    "languages": MessageLookupByLibrary.simpleMessage("Sprachen"),
    "lblAlert": MessageLookupByLibrary.simpleMessage("Warnung"),
    "lblAlertSubtitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du die Anwendung verlassen möchtest?",
    ),
    "lblChannelInfo": MessageLookupByLibrary.simpleMessage("Kanalinfo"),
    "lblClearChatSubTitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du den Chat löschen möchtest?",
    ),
    "lblContinue": MessageLookupByLibrary.simpleMessage("Weiter"),
    "lblCreateProfile": MessageLookupByLibrary.simpleMessage(
      "Profil erstellen",
    ),
    "lblDeleteChannelSubTitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diesen Kanal löschen möchtest?",
    ),
    "lblDeleteGroupSubTitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diese Gruppe löschen möchtest?",
    ),
    "lblDeleteMessage": MessageLookupByLibrary.simpleMessage(
      "Nachricht löschen",
    ),
    "lblDeleteMessageSubTitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diese Nachricht löschen möchtest?",
    ),
    "lblDeleteStories": MessageLookupByLibrary.simpleMessage("Story löschen"),
    "lblDeleteStoriesSubTitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du die Story entfernen möchtest?",
    ),
    "lblEditProfile": MessageLookupByLibrary.simpleMessage("Profil bearbeiten"),
    "lblEmailChangeTxt": MessageLookupByLibrary.simpleMessage(
      "Tippe, um die E-Mail-Adresse zu ändern",
    ),
    "lblExit": MessageLookupByLibrary.simpleMessage("Beenden"),
    "lblGroupInfo": MessageLookupByLibrary.simpleMessage("Gruppeninfo"),
    "lblKeepYourEmailAddressUptoDate": MessageLookupByLibrary.simpleMessage(
      "Halte deine E-Mail-Adresse aktuell, um sicherzustellen, dass du dich immer bei 212 Private Messenger anmelden kannst.",
    ),
    "lblKeepYourNumberUptoDate": MessageLookupByLibrary.simpleMessage(
      "Halte deine Nummer aktuell, um sicherzustellen, dass du dich immer bei 212 Private Messenger anmelden kannst.",
    ),
    "lblLeaveChannelSubTitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diesen Kanal verlassen möchtest?",
    ),
    "lblLeaveGroupSubTitle": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diese Gruppe verlassen möchtest?",
    ),
    "lblLoginSubtitleText": MessageLookupByLibrary.simpleMessage(
      "Bitte fülle die Details aus, um dich anzumelden",
    ),
    "lblLoginText": MessageLookupByLibrary.simpleMessage(
      "212 Private Messenger\nWillkommen!",
    ),
    "lblNewGroup": MessageLookupByLibrary.simpleMessage("Neue Gruppe"),
    "lblNo": MessageLookupByLibrary.simpleMessage("Nein"),
    "lblNoDataFound": MessageLookupByLibrary.simpleMessage(
      "Keine Daten gefunden",
    ),
    "lblOtpSubtitleText": m9,
    "lblOtpText": MessageLookupByLibrary.simpleMessage(
      "Geben Sie\nVerifizierungscode ein",
    ),
    "lblPhoneChangeTxt": MessageLookupByLibrary.simpleMessage(
      "Tippe, um die Telefonnummer zu ändern",
    ),
    "lblSearchChat": MessageLookupByLibrary.simpleMessage("Chat suchen"),
    "lblSearchUser": MessageLookupByLibrary.simpleMessage("Benutzer suchen"),
    "lblShowProfilePhoto": MessageLookupByLibrary.simpleMessage(
      "Profilfoto anzeigen",
    ),
    "lblUpdateProfile": MessageLookupByLibrary.simpleMessage(
      "Profil erfolgreich aktualisiert",
    ),
    "lblUploadMedias": MessageLookupByLibrary.simpleMessage(
      "Medien hochladen von",
    ),
    "lblUploadPhotos": MessageLookupByLibrary.simpleMessage(
      "Fotos hochladen von",
    ),
    "leaveChannel": MessageLookupByLibrary.simpleMessage("Kanal verlassen"),
    "leaveGroup": MessageLookupByLibrary.simpleMessage("Gruppe verlassen"),
    "logIn": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "loginButtonTextRe": MessageLookupByLibrary.simpleMessage(
      "Erneut versuchen",
    ),
    "loginButtonTextSubTitle": MessageLookupByLibrary.simpleMessage(
      "Melde dich bei deinem registrierten Konto an",
    ),
    "makeProfilePrivate": MessageLookupByLibrary.simpleMessage(
      "Profil privat machen",
    ),
    "memberRemovedFromTheGroupOrChannel": m10,
    "menu": MessageLookupByLibrary.simpleMessage("Menü"),
    "message": MessageLookupByLibrary.simpleMessage("Nachricht"),
    "messageEncryptionInfo": MessageLookupByLibrary.simpleMessage(
      "Nachrichten sind Ende-zu-Ende-verschlüsselt. Niemand außerhalb dieses Chats, nicht einmal 212 Messenger, kann sie lesen oder anhören.",
    ),
    "more": MessageLookupByLibrary.simpleMessage("Mehr"),
    "muteNotification": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen stummschalten",
    ),
    "nameError": MessageLookupByLibrary.simpleMessage(
      "Anzeigename darf nicht leer sein",
    ),
    "namePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Anzeigenamen eingeben",
    ),
    "network_request_failed": MessageLookupByLibrary.simpleMessage(
      "Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung.",
    ),
    "newChannel": MessageLookupByLibrary.simpleMessage("Neuer Kanal"),
    "newContacts": MessageLookupByLibrary.simpleMessage("Neue Kontakte"),
    "newGroup": MessageLookupByLibrary.simpleMessage("Neue Gruppe"),
    "next": MessageLookupByLibrary.simpleMessage("Weiter"),
    "no": MessageLookupByLibrary.simpleMessage("Nein"),
    "noArchiveChatsFound": MessageLookupByLibrary.simpleMessage(
      "Keine archivierten Chats gefunden",
    ),
    "noCallHistoryFound": MessageLookupByLibrary.simpleMessage(
      "Kein Anrufverlauf gefunden",
    ),
    "noContactsFound": MessageLookupByLibrary.simpleMessage(
      "Keine registrierten Kontakte verfügbar. Bitte lade ein Mitglied ein.",
    ),
    "noConversationsFound": MessageLookupByLibrary.simpleMessage(
      "Keine Gespräche gefunden",
    ),
    "noEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Keine E-Mail-Adresse",
    ),
    "noMessage": MessageLookupByLibrary.simpleMessage("Keine Nachricht"),
    "noNotificationsFound": MessageLookupByLibrary.simpleMessage(
      "Keine Benachrichtigungen gefunden",
    ),
    "noOfMember": m11,
    "noOfSubscriber": m12,
    "noPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Keine Telefonnummer",
    ),
    "noStories": MessageLookupByLibrary.simpleMessage("Keine Geschichten"),
    "noStoriesUploadedDescription": MessageLookupByLibrary.simpleMessage(
      "Sie haben noch nichts zu Ihrer Geschichte hochgeladen. Bitte fügen Sie Geschichten hinzu, indem Sie unten auf die Plus-Schaltfläche klicken.",
    ),
    "noSubscriptionMessage": MessageLookupByLibrary.simpleMessage(
      "Verbessere dein Erlebnis! Wähle Werbefrei, um Werbung zu entfernen, oder entscheide dich für Premium, um alle exklusiven Funktionen freizuschalten.",
    ),
    "noViewsYetForStories": MessageLookupByLibrary.simpleMessage(
      "Noch keine Aufrufe. Deine Story wurde noch nicht angesehen.",
    ),
    "notNow": MessageLookupByLibrary.simpleMessage("Nicht jetzt"),
    "notifications": MessageLookupByLibrary.simpleMessage("Benachrichtigungen"),
    "notificationsSettings": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungseinstellungen",
    ),
    "numberOfArchiveChats": m13,
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "online": MessageLookupByLibrary.simpleMessage("Online"),
    "onlyAdminsCanSendMessages": MessageLookupByLibrary.simpleMessage(
      "Nur Administratoren können Nachrichten senden",
    ),
    "openSetting": MessageLookupByLibrary.simpleMessage("Einstellungen öffnen"),
    "or": MessageLookupByLibrary.simpleMessage("ODER"),
    "other": MessageLookupByLibrary.simpleMessage("Andere"),
    "otherUsers": MessageLookupByLibrary.simpleMessage("Andere Benutzer"),
    "otpError": MessageLookupByLibrary.simpleMessage(
      "Gib ein gültiges OTP ein",
    ),
    "otpIsInvalid": MessageLookupByLibrary.simpleMessage(
      "Das OTP ist ungültig",
    ),
    "otpNotReceivedText": MessageLookupByLibrary.simpleMessage(
      "OTP nicht erhalten?",
    ),
    "otpVerifySuccess": MessageLookupByLibrary.simpleMessage(
      "OTP erfolgreich verifiziert",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "Berechtigung erforderlich",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Telefon"),
    "phoneError": MessageLookupByLibrary.simpleMessage(
      "Telefonnummer darf nicht leer sein",
    ),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Telefonnummer"),
    "phonePlaceholder": MessageLookupByLibrary.simpleMessage("000 000 0000"),
    "phoneVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Telefonnummer erfolgreich verifiziert",
    ),
    "pin": MessageLookupByLibrary.simpleMessage("Anheften"),
    "pleaseChangePhoneNumberBeforeUpdate": MessageLookupByLibrary.simpleMessage(
      "Bitte ändere die Telefonnummer vor dem Update",
    ),
    "pleaseEnterEmailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie eine E-Mail-Adresse ODER Telefonnummer an",
    ),
    "pleaseEnterYourEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie Ihre E-Mail-Adresse ein",
    ),
    "pleaseEnterYourOTP": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie Ihr OTP ein",
    ),
    "pleaseFillOnlyOneFieldEmailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Bitte füllen Sie nur ein Feld aus: E-Mail oder Telefon.",
    ),
    "pleaseSelectChannelImage": MessageLookupByLibrary.simpleMessage(
      "Bitte wähle ein Kanalbild aus",
    ),
    "pleaseSelectGroupImage": MessageLookupByLibrary.simpleMessage(
      "Bitte wähle ein Gruppenbild aus",
    ),
    "pleaseSelectProfileImage": MessageLookupByLibrary.simpleMessage(
      "Bitte wähle ein Profilbild aus",
    ),
    "pleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Etwas ist schief gelaufen!, bitte versuchen Sie es erneut",
    ),
    "pleaseTryAgainTxt": MessageLookupByLibrary.simpleMessage(
      "Bitte versuche es erneut!",
    ),
    "pleaseVerifyEmail": MessageLookupByLibrary.simpleMessage(
      "bitte verifizieren Sie Ihre E-Mail",
    ),
    "premiumComingSoon": MessageLookupByLibrary.simpleMessage(
      "Premium kommt bald! Bleib dran für exklusive Funktionen.",
    ),
    "premiumScreenTitle": MessageLookupByLibrary.simpleMessage(
      "212 Messenger Premium",
    ),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage(
      "Datenschutz und Sicherheit",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzrichtlinie",
    ),
    "privateProfileText": MessageLookupByLibrary.simpleMessage(
      "Ihr Profil ist privat. Nur bekannte Kontakte können Sie finden.",
    ),
    "publicProfileText": MessageLookupByLibrary.simpleMessage(
      "Ihr Profil ist für alle sichtbar.",
    ),
    "publicUsers": MessageLookupByLibrary.simpleMessage("Öffentliche Benutzer"),
    "quota_exceeded": MessageLookupByLibrary.simpleMessage(
      "OTP-Anforderungslimit überschritten. Bitte versuchen Sie es später erneut.",
    ),
    "react": MessageLookupByLibrary.simpleMessage("Reagieren"),
    "recentMessage": MessageLookupByLibrary.simpleMessage("Letzte Nachrichten"),
    "recording": MessageLookupByLibrary.simpleMessage("Aufnahme"),
    "recording2": MessageLookupByLibrary.simpleMessage("Aufnahme läuft..."),
    "refresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "reject": MessageLookupByLibrary.simpleMessage("Ablehnen"),
    "removeEmailSuccess": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Adresse erfolgreich entfernt",
    ),
    "removePhoneSuccess": MessageLookupByLibrary.simpleMessage(
      "Telefonnummer erfolgreich entfernt",
    ),
    "removedUserCannotSendMessage": m14,
    "reply": MessageLookupByLibrary.simpleMessage("Antworten"),
    "replyingTo": MessageLookupByLibrary.simpleMessage("Antwort auf: "),
    "reportReasonFakeProfile": MessageLookupByLibrary.simpleMessage(
      "Falsches Profil",
    ),
    "reportReasonHarassment": MessageLookupByLibrary.simpleMessage(
      "Belästigung",
    ),
    "reportReasonHateSpeech": MessageLookupByLibrary.simpleMessage("Hassrede"),
    "reportReasonInappropriateContent": MessageLookupByLibrary.simpleMessage(
      "Unangemessener Inhalt",
    ),
    "reportReasonScamOrFraud": MessageLookupByLibrary.simpleMessage(
      "Betrug oder Täuschung",
    ),
    "reportReasonSpam": MessageLookupByLibrary.simpleMessage("Spam"),
    "reportReasonViolenceOrThreats": MessageLookupByLibrary.simpleMessage(
      "Gewalt oder Drohungen",
    ),
    "reportUser": MessageLookupByLibrary.simpleMessage("Benutzer melden"),
    "reportUserButton": MessageLookupByLibrary.simpleMessage("Benutzer melden"),
    "reportUserDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Beschreibe das Problem (bis zu 300 Zeichen)...",
    ),
    "reportUserDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Zusätzliche Details (Optional)",
    ),
    "reportUserReasonLabel": MessageLookupByLibrary.simpleMessage(
      "Bitte wähle einen Grund für die Meldung",
    ),
    "reportUserTitle": MessageLookupByLibrary.simpleMessage("Benutzer melden"),
    "resendOtpText": MessageLookupByLibrary.simpleMessage("OTP erneut senden"),
    "restart": MessageLookupByLibrary.simpleMessage("Neustart"),
    "restartRecording": MessageLookupByLibrary.simpleMessage(
      "Aufnahme neu starten...",
    ),
    "restorePurchase": MessageLookupByLibrary.simpleMessage(
      "Käufe wiederherstellen",
    ),
    "sCalls": MessageLookupByLibrary.simpleMessage("Anrufe"),
    "sContacts": MessageLookupByLibrary.simpleMessage("Kontakte"),
    "sDcr": MessageLookupByLibrary.simpleMessage("DCR"),
    "sHr": MessageLookupByLibrary.simpleMessage("Personalwesen"),
    "sInviteFriends": MessageLookupByLibrary.simpleMessage("Freunde einladen"),
    "sLastSeen": MessageLookupByLibrary.simpleMessage("Zuletzt gesehen "),
    "sLogout": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "sLogoutMessage": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie sich von der Anwendung abmelden möchten?",
    ),
    "sManager": MessageLookupByLibrary.simpleMessage("Manager"),
    "sProfile": MessageLookupByLibrary.simpleMessage("Mein Profil"),
    "sSavedMessages": MessageLookupByLibrary.simpleMessage(
      "Gespeicherte Nachrichten",
    ),
    "sSearchContacts": MessageLookupByLibrary.simpleMessage(
      "Kontakte suchen...",
    ),
    "sSearchNotifications": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen suchen...",
    ),
    "sSettings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "saveMessage": MessageLookupByLibrary.simpleMessage("Nachricht speichern"),
    "searchConversations": MessageLookupByLibrary.simpleMessage(
      "Gespräche suchen...",
    ),
    "searchCountry": MessageLookupByLibrary.simpleMessage("Land suchen"),
    "searchUsers": MessageLookupByLibrary.simpleMessage("Benutzer suchen"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Alle auswählen"),
    "selectContactToInviteThem": MessageLookupByLibrary.simpleMessage(
      "Wähle Kontakte aus, um sie zu 212 Private Messenger einzuladen",
    ),
    "selectMedia": MessageLookupByLibrary.simpleMessage("Medien auswählen"),
    "send": MessageLookupByLibrary.simpleMessage("Senden"),
    "sendMediaAndFilesToStoreThem": MessageLookupByLibrary.simpleMessage(
      "Sende Medien und Dateien, um sie zu speichern",
    ),
    "shareYourContacts": MessageLookupByLibrary.simpleMessage(
      "Möchtest du deine Kontakte teilen?",
    ),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "Etwas ist schiefgelaufen!",
    ),
    "somethingWentWrongPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.",
    ),
    "sortedByLastSeenTime": MessageLookupByLibrary.simpleMessage(
      "Nach zuletzt gesehen sortiert",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "stop": MessageLookupByLibrary.simpleMessage("Stopp"),
    "stopNotifications": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen stoppen",
    ),
    "submitButtonText": MessageLookupByLibrary.simpleMessage("Absenden"),
    "subscribers": MessageLookupByLibrary.simpleMessage("Abonnenten"),
    "tapToStartRecord": MessageLookupByLibrary.simpleMessage(
      "Tippe auf Start, um aufzunehmen",
    ),
    "timer24Hours": MessageLookupByLibrary.simpleMessage("24 Stunden"),
    "timer7Days": MessageLookupByLibrary.simpleMessage("7 Tage"),
    "timer90Days": MessageLookupByLibrary.simpleMessage("90 Tage"),
    "timerOff": MessageLookupByLibrary.simpleMessage("Aus"),
    "todayStories": MessageLookupByLibrary.simpleMessage("Heutige Storys"),
    "too_many_requests": MessageLookupByLibrary.simpleMessage(
      "Zu viele Versuche. Bitte versuchen Sie es später erneut.",
    ),
    "typeMessage": MessageLookupByLibrary.simpleMessage("Nachricht eingeben"),
    "unArchive": MessageLookupByLibrary.simpleMessage("De-Archivieren"),
    "unBlockUser": MessageLookupByLibrary.simpleMessage("Benutzer entsperren"),
    "unPin": MessageLookupByLibrary.simpleMessage("Lösen"),
    "unblockUserSubtitle": m15,
    "unblockUserSuccessfully": m16,
    "unblockUserTitle": MessageLookupByLibrary.simpleMessage(
      "Benutzer entsperren?",
    ),
    "upTo200000Members": MessageLookupByLibrary.simpleMessage(
      "Bis zu 200000 Mitglieder",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "updateBtnTxt": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "upgradeToPremium": MessageLookupByLibrary.simpleMessage(
      "Auf Premium upgraden",
    ),
    "uploadStory": MessageLookupByLibrary.simpleMessage("Story hochladen"),
    "useSearchToQuicklyFindThings": MessageLookupByLibrary.simpleMessage(
      "Verwende die Suche, um Dinge schnell zu finden",
    ),
    "userBlockedYouSoCannotSendMessage": m17,
    "userIDError": MessageLookupByLibrary.simpleMessage(
      "Der Benutzername darf nicht leer sein.",
    ),
    "userNameError": MessageLookupByLibrary.simpleMessage(
      "Der Benutzername darf nicht leer sein",
    ),
    "userNameIsAlreadyInUse": MessageLookupByLibrary.simpleMessage(
      "Dieser Benutzername ist bereits vergeben. Bitte wähle einen anderen.",
    ),
    "userNotFound": MessageLookupByLibrary.simpleMessage(
      "Benutzer nicht gefunden",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Benutzername"),
    "usernameInvalidCharacters": MessageLookupByLibrary.simpleMessage(
      "Der Benutzername enthält ungültige Zeichen. Erlaubt sind nur Buchstaben, Zahlen, Unterstriche (_) und Bindestriche (-).",
    ),
    "usernamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Benutzernamen eingeben",
    ),
    "usernameValidationError": MessageLookupByLibrary.simpleMessage(
      "Der Benutzername darf keine Leerzeichen enthalten. Er kann jedoch Unterstriche (_), Buchstaben, Zahlen und Bindestriche (-) enthalten.",
    ),
    "verificationOtp": MessageLookupByLibrary.simpleMessage(
      "Verifizierungs-Otp",
    ),
    "verifyPhoneNumberError": MessageLookupByLibrary.simpleMessage(
      "Bitte bestätige die Telefonnummer",
    ),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoDurationIsMorethen30Sec": MessageLookupByLibrary.simpleMessage(
      "Die Videodauer überschreitet 30 Sekunden. Bitte wähle ein kürzeres Video aus.",
    ),
    "viewContact": MessageLookupByLibrary.simpleMessage("Kontakt anzeigen"),
    "whoWouldYouLikeToAdd": MessageLookupByLibrary.simpleMessage(
      "Wen möchtest du hinzufügen?",
    ),
    "writeCaptionHere": MessageLookupByLibrary.simpleMessage(
      "Schreibe hier eine Bildunterschrift",
    ),
    "wrongOtp": MessageLookupByLibrary.simpleMessage(
      "Das eingegebene OTP ist falsch. Bitte versuchen Sie es erneut.",
    ),
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
    "you": MessageLookupByLibrary.simpleMessage("Du"),
    "youCanAddAnEmailAddressInProfileSettings":
        MessageLookupByLibrary.simpleMessage(
          "Du kannst eine E-Mail-Adresse in den Profileinstellungen hinzufügen.",
        ),
    "youCanAddPhoneNumberInProfileSettings":
        MessageLookupByLibrary.simpleMessage(
          "Du kannst eine Telefonnummer in den Profileinstellungen hinzufügen.",
        ),
    "youHaveSuccesfullyRepoartuser": m18,
    "yourCloudStorage": MessageLookupByLibrary.simpleMessage(
      "Dein Cloud-Speicher",
    ),
    "yourStories": MessageLookupByLibrary.simpleMessage("Deine Geschichten"),
  };
}
