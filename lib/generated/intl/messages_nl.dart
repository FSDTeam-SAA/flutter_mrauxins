// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a nl locale. All the
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
  String get localeName => 'nl';

  static String m0(userName) =>
      "${userName} kan je niet meer bellen of berichten sturen.";

  static String m1(userName) => "Je hebt ${userName} succesvol geblokkeerd";

  static String m2(userName) =>
      "Je kunt geen berichten sturen naar ${userName} omdat je hen hebt geblokkeerd.";

  static String m3(value) => "${value} geselecteerd";

  static String m4(userName, days) =>
      "${userName} gebruikt de standaardtimer voor verdwijnende berichten in nieuwe chats. Nieuwe berichten verdwijnen uit deze chat na ${days} dagen, behalve wanneer ze worden bewaard.\nTik om je eigen standaardtimer in te stellen.";

  static String m5(value) => "${value} bewerken";

  static String m6(groupOrChannel) =>
      "${groupOrChannel} is succesvol bijgewerkt!";

  static String m7(value) => "Is \'${value}\' nog steeds jouw e-mailadres?";

  static String m8(value) => "Is \'${value}\' nog steeds jouw nummer?";

  static String m9(value) =>
      "Voer alstublieft de OTP in die is ontvangen op ${value}";

  static String m10(MemberName, group) =>
      "${MemberName} is verwijderd uit de ${group}.";

  static String m11(value) => "${value} Leden";

  static String m12(value) => "${value} Abonnee";

  static String m13(number) => "${number} gearchiveerde chats beschikbaar";

  static String m14(name) =>
      "Je kunt geen berichten sturen omdat je geen lid meer bent van ${name}.";

  static String m15(userName) =>
      "Je kunt weer berichten en oproepen van ${userName} ontvangen.";

  static String m16(userName) => "Je hebt ${userName} succesvol gedeblokkeerd";

  static String m17(userName) =>
      "${userName} heeft je geblokkeerd, dus je kunt geen berichten sturen.";

  static String m18(name) =>
      "Je hebt gebruiker ${name} succesvol gerapporteerd.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutYouError": MessageLookupByLibrary.simpleMessage(
      "\'Over jou\' mag niet leeg zijn",
    ),
    "aboutYouPlaceholder": MessageLookupByLibrary.simpleMessage("Over jou"),
    "accept": MessageLookupByLibrary.simpleMessage("Accepteren"),
    "accessThisCharFromAnyDevice": MessageLookupByLibrary.simpleMessage(
      "Toegang tot deze chat vanaf elk apparaat",
    ),
    "accessThisChatFromAnyDevice": MessageLookupByLibrary.simpleMessage(
      "Toegang tot deze chat vanaf elk apparaat",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "adFreeUserMessage": MessageLookupByLibrary.simpleMessage(
      "Je bent een advertentievrije gebruiker! Geniet van onze app zonder advertenties. Upgrade naar Premium voor nog meer exclusieve functies.",
    ),
    "addFewWordsAboutYourself": MessageLookupByLibrary.simpleMessage(
      "Voeg een paar woorden over jezelf toe in de profielinstellingen.",
    ),
    "addMembers": MessageLookupByLibrary.simpleMessage("Leden toevoegen"),
    "addMessage": MessageLookupByLibrary.simpleMessage(
      "Voeg een bericht toe...",
    ),
    "addSubscribers": MessageLookupByLibrary.simpleMessage(
      "Abonnees toevoegen",
    ),
    "admin": MessageLookupByLibrary.simpleMessage("Beheerder"),
    "allowMembersToSendMessage": MessageLookupByLibrary.simpleMessage(
      "Sta leden toe berichten te verzenden",
    ),
    "archive": MessageLookupByLibrary.simpleMessage("Archiveren"),
    "archiveChats": MessageLookupByLibrary.simpleMessage("Chats archiveren"),
    "areYouSureToWantToArchiveThisChat": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je deze chat wilt archiveren?",
    ),
    "areYouSureToWantToUnArchiveThisChat": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je deze chat wilt de-archiveren?",
    ),
    "askContactPermission": MessageLookupByLibrary.simpleMessage(
      "We gebruiken je contacten om je te helpen vrienden op de app te vinden. Schakel toegang tot contacten in via de instellingen.",
    ),
    "bio": MessageLookupByLibrary.simpleMessage("Biografie"),
    "block": MessageLookupByLibrary.simpleMessage("Blokkeren"),
    "blockUser": MessageLookupByLibrary.simpleMessage("Gebruiker blokkeren"),
    "blockUserSubtitle": m0,
    "blockUserSuccessfully": m1,
    "blockUserTitle": MessageLookupByLibrary.simpleMessage(
      "Gebruiker blokkeren?",
    ),
    "blockedContacts": MessageLookupByLibrary.simpleMessage(
      "Geblokkeerde contacten",
    ),
    "blockedUserCannotSendMessage": m2,
    "btnVerifyTxt": MessageLookupByLibrary.simpleMessage("Verifiëren"),
    "buyAdFree": MessageLookupByLibrary.simpleMessage("Koop Advertentievrij"),
    "buyPremium": MessageLookupByLibrary.simpleMessage("Koop Premium"),
    "callHistory": MessageLookupByLibrary.simpleMessage("Oproepgeschiedenis"),
    "calls": MessageLookupByLibrary.simpleMessage("Oproep"),
    "camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
    "cannotSendMessageToDeletedUser": MessageLookupByLibrary.simpleMessage(
      "Je kunt geen berichten naar deze gebruiker sturen omdat hun account is verwijderd.",
    ),
    "channel": MessageLookupByLibrary.simpleMessage("Kanaal"),
    "channelCreatedEmptyChatMsg": MessageLookupByLibrary.simpleMessage(
      "heeft een nieuw kanaal aangemaakt",
    ),
    "channelNameError": MessageLookupByLibrary.simpleMessage(
      "Kanaalnaam mag niet leeg zijn",
    ),
    "channelNamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Voer kanaalnaam in",
    ),
    "channelPermission": MessageLookupByLibrary.simpleMessage("Kanaalrechten"),
    "clear": MessageLookupByLibrary.simpleMessage("Wissen"),
    "clearCallLog": MessageLookupByLibrary.simpleMessage("Oproeplogs wissen"),
    "clearChat": MessageLookupByLibrary.simpleMessage("Chat wissen"),
    "clearNotification": MessageLookupByLibrary.simpleMessage(
      "Alle meldingen wissen",
    ),
    "clearNotificationSubTitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je alle meldingen wilt wissen?",
    ),
    "clear_all_calls_subtitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je de hele oproepgeschiedenis wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.",
    ),
    "clear_all_calls_title": MessageLookupByLibrary.simpleMessage(
      "Oproepgeschiedenis wissen",
    ),
    "comingSoon": MessageLookupByLibrary.simpleMessage(
      "Binnenkort beschikbaar",
    ),
    "connecting": MessageLookupByLibrary.simpleMessage("Verbinden..."),
    "contactUseDescription": MessageLookupByLibrary.simpleMessage(
      "Om je te helpen vrienden te vinden die de app al gebruiken, kunnen we met jouw toestemming je contactenlijst naar onze server uploaden. Dit wordt alleen gebruikt om contacten te matchen – je gegevens worden nooit gedeeld.",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Gekopieerd naar klembord!",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Kopiëren"),
    "countSelected": m3,
    "createChannelBtn": MessageLookupByLibrary.simpleMessage("Kanaal aanmaken"),
    "createGroupBtn": MessageLookupByLibrary.simpleMessage("Groep aanmaken"),
    "customContactUploadConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Contacten uploaden?",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage(
      "Account verwijderen",
    ),
    "deleteAccountSlogen": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je je account wilt verwijderen? Deze actie is onomkeerbaar en al je berichten, contacten en gegevens gaan permanent verloren.",
    ),
    "deleteChannel": MessageLookupByLibrary.simpleMessage("Kanaal verwijderen"),
    "deleteChatSubtitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je dit gesprek wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt en alle berichten worden permanent van je apparaat verwijderd.",
    ),
    "deleteForMe": MessageLookupByLibrary.simpleMessage("Verwijder voor mij"),
    "deleteGroup": MessageLookupByLibrary.simpleMessage("Groep verwijderen"),
    "deleteGroupAuthority": MessageLookupByLibrary.simpleMessage(
      "Alleen de groepsbeheerder kan de groep verwijderen.",
    ),
    "deleteMessageForEveryone": MessageLookupByLibrary.simpleMessage(
      "Voor iedereen verwijderen",
    ),
    "deleteSelected": MessageLookupByLibrary.simpleMessage(
      "Geselecteerde verwijderen",
    ),
    "deleteThisChat": MessageLookupByLibrary.simpleMessage(
      "Dit gesprek verwijderen?",
    ),
    "delete_selected_calls_subtitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je de geselecteerde oproepen wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.",
    ),
    "delete_selected_calls_title": MessageLookupByLibrary.simpleMessage(
      "Geselecteerde oproepen verwijderen",
    ),
    "disableVideo": MessageLookupByLibrary.simpleMessage("Video uitschakelen"),
    "disappearingMessage": MessageLookupByLibrary.simpleMessage(
      "Verdwijnende berichten",
    ),
    "disappearingMessageDescription": MessageLookupByLibrary.simpleMessage(
      "Wanneer ingeschakeld, beginnen alle nieuwe individuele chats met verdwijnende berichten die zijn ingesteld op de door jou geselecteerde duur. Deze instelling heeft geen invloed op je bestaande chats.",
    ),
    "disappearingMessageInfo": m4,
    "disappearingMessageTitle": MessageLookupByLibrary.simpleMessage(
      "Nieuwe chat starten met verdwijnende berichten ingesteld op",
    ),
    "document": MessageLookupByLibrary.simpleMessage("Document"),
    "edit": MessageLookupByLibrary.simpleMessage("Bewerken"),
    "editImage": MessageLookupByLibrary.simpleMessage("Afbeelding bewerken"),
    "editMessage": MessageLookupByLibrary.simpleMessage("Bericht bewerken"),
    "editPhoneOrEmail": m5,
    "edited": MessageLookupByLibrary.simpleMessage("Bewerkt"),
    "email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "emailAddressIsAlreadyUpdated": MessageLookupByLibrary.simpleMessage(
      "Wijzig het e-mailadres voordat je het bijwerkt.",
    ),
    "emailAddressIsInvalid": MessageLookupByLibrary.simpleMessage(
      "Het e-mailadres is ongeldig",
    ),
    "emailAdress": MessageLookupByLibrary.simpleMessage("E-mailadres"),
    "emailChangeSuccessfully": MessageLookupByLibrary.simpleMessage(
      "E-mailadres succesvol gewijzigd",
    ),
    "emailError": MessageLookupByLibrary.simpleMessage(
      "E-mailadres mag niet leeg zijn",
    ),
    "emailPlaceHolder": MessageLookupByLibrary.simpleMessage(
      "Voer e-mailadres in",
    ),
    "emailVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "E-mailadres succesvol geverifieerd",
    ),
    "enableVideo": MessageLookupByLibrary.simpleMessage("Video inschakelen"),
    "endCall": MessageLookupByLibrary.simpleMessage("Einde gesprek"),
    "enterValidUsername": MessageLookupByLibrary.simpleMessage(
      "Voer alstublieft een geldige gebruikersnaam in.",
    ),
    "errorCannotRemoveEmail": MessageLookupByLibrary.simpleMessage(
      "Je kunt het e-mailadres niet verwijderen omdat je telefoonnummer niet is geregistreerd of geverifieerd in je account.",
    ),
    "errorCannotRemovePhone": MessageLookupByLibrary.simpleMessage(
      "Je kunt het telefoonnummer niet verwijderen omdat je e-mailadres niet is geregistreerd of geverifieerd in je account.",
    ),
    "facebookText": MessageLookupByLibrary.simpleMessage("Facebook"),
    "forward": MessageLookupByLibrary.simpleMessage("Doorsturen"),
    "forwardMessageHereToSaveThem": MessageLookupByLibrary.simpleMessage(
      "Stuur berichten hierheen om ze op te slaan",
    ),
    "forwardMessageLimitText": MessageLookupByLibrary.simpleMessage(
      "Je kunt berichten doorsturen naar maximaal 5 leden of groepen.",
    ),
    "forwardTo": MessageLookupByLibrary.simpleMessage("Doorsturen naar"),
    "gallery": MessageLookupByLibrary.simpleMessage("Galerij"),
    "giftsCommingSoon": MessageLookupByLibrary.simpleMessage(
      "Cadeaus komen binnenkort!",
    ),
    "giftsCommingSoonMessage": MessageLookupByLibrary.simpleMessage(
      "We werken hard aan een leuke nieuwe manier om cadeaus te sturen. Blijf op de hoogte en let op deze functie in de volgende update!",
    ),
    "googleText": MessageLookupByLibrary.simpleMessage("Google"),
    "group": MessageLookupByLibrary.simpleMessage("Groep"),
    "groupCreatedEmptyChatMsg": MessageLookupByLibrary.simpleMessage(
      "heeft een nieuwe groep aangemaakt, dus je kunt het gesprek starten!",
    ),
    "groupMembers": MessageLookupByLibrary.simpleMessage("Groepsleden"),
    "groupMembersLimitrichMessage": MessageLookupByLibrary.simpleMessage(
      "Je kunt niet meer dan 200.000 leden toevoegen",
    ),
    "groupNameError": MessageLookupByLibrary.simpleMessage(
      "Groepsnaam mag niet leeg zijn",
    ),
    "groupNamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Voer groepsnaam in",
    ),
    "groupOrChannelUpdateSuccessfully": m6,
    "groupPermission": MessageLookupByLibrary.simpleMessage("Groepsrechten"),
    "image": MessageLookupByLibrary.simpleMessage("Afbeelding"),
    "info": MessageLookupByLibrary.simpleMessage("Informatie"),
    "invalid_phone_number": MessageLookupByLibrary.simpleMessage(
      "Het telefoonnummer is ongeldig. Controleer het en probeer het opnieuw.",
    ),
    "inviteFriend": MessageLookupByLibrary.simpleMessage("Vriend uitnodigen"),
    "inviteToChannel": MessageLookupByLibrary.simpleMessage(
      "Uitnodigen voor kanaal",
    ),
    "inviteToGroup": MessageLookupByLibrary.simpleMessage(
      "Uitnodigen voor groep",
    ),
    "isStillYourEmailAddress": m7,
    "isStillYourNumber": m8,
    "language": MessageLookupByLibrary.simpleMessage("Taal"),
    "languages": MessageLookupByLibrary.simpleMessage("Talen"),
    "lblAlert": MessageLookupByLibrary.simpleMessage("Waarschuwing"),
    "lblAlertSubtitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je de applicatie wilt verlaten?",
    ),
    "lblChannelInfo": MessageLookupByLibrary.simpleMessage("Kanaalinfo"),
    "lblClearChatSubTitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je de chat wilt wissen?",
    ),
    "lblContinue": MessageLookupByLibrary.simpleMessage("Doorgaan"),
    "lblCreateProfile": MessageLookupByLibrary.simpleMessage(
      "Profiel aanmaken",
    ),
    "lblDeleteChannelSubTitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je dit kanaal wilt verwijderen?",
    ),
    "lblDeleteGroupSubTitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je deze groep wilt verwijderen?",
    ),
    "lblDeleteMessage": MessageLookupByLibrary.simpleMessage(
      "Bericht verwijderen",
    ),
    "lblDeleteMessageSubTitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je dit bericht wilt verwijderen?",
    ),
    "lblDeleteStories": MessageLookupByLibrary.simpleMessage(
      "Verhaal verwijderen",
    ),
    "lblDeleteStoriesSubTitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je het verhaal wilt verwijderen?",
    ),
    "lblEditProfile": MessageLookupByLibrary.simpleMessage("Bewerk profiel"),
    "lblEmailChangeTxt": MessageLookupByLibrary.simpleMessage(
      "Tik om het e-mailadres te wijzigen",
    ),
    "lblExit": MessageLookupByLibrary.simpleMessage("Afsluiten"),
    "lblGroupInfo": MessageLookupByLibrary.simpleMessage("Groepsinformatie"),
    "lblKeepYourEmailAddressUptoDate": MessageLookupByLibrary.simpleMessage(
      "Houd je e-mailadres up-to-date om ervoor te zorgen dat je altijd kunt inloggen op 212 Private Messenger.",
    ),
    "lblKeepYourNumberUptoDate": MessageLookupByLibrary.simpleMessage(
      "Houd je nummer up-to-date om ervoor te zorgen dat je altijd kunt inloggen op 212 Private Messenger.",
    ),
    "lblLeaveChannelSubTitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je dit kanaal wilt verlaten?",
    ),
    "lblLeaveGroupSubTitle": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je deze groep wilt verlaten?",
    ),
    "lblLoginSubtitleText": MessageLookupByLibrary.simpleMessage(
      "Vul de gegevens in om in te loggen",
    ),
    "lblLoginText": MessageLookupByLibrary.simpleMessage(
      "212 Private Messenger\nVerwelkomt je!",
    ),
    "lblNewGroup": MessageLookupByLibrary.simpleMessage("Nieuwe groep"),
    "lblNo": MessageLookupByLibrary.simpleMessage("Nee"),
    "lblNoDataFound": MessageLookupByLibrary.simpleMessage(
      "Geen gegevens gevonden",
    ),
    "lblOtpSubtitleText": m9,
    "lblOtpText": MessageLookupByLibrary.simpleMessage(
      "Voer\nVerificatiecode in",
    ),
    "lblPhoneChangeTxt": MessageLookupByLibrary.simpleMessage(
      "Tik om het telefoonnummer te wijzigen",
    ),
    "lblSearchChat": MessageLookupByLibrary.simpleMessage("Chat zoeken"),
    "lblSearchUser": MessageLookupByLibrary.simpleMessage("Gebruiker zoeken"),
    "lblShowProfilePhoto": MessageLookupByLibrary.simpleMessage(
      "Profielfoto weergeven",
    ),
    "lblUpdateProfile": MessageLookupByLibrary.simpleMessage(
      "Profiel succesvol bijgewerkt",
    ),
    "lblUploadMedias": MessageLookupByLibrary.simpleMessage(
      "Media uploaden van",
    ),
    "lblUploadPhotos": MessageLookupByLibrary.simpleMessage(
      "Foto\'s uploaden van",
    ),
    "leaveChannel": MessageLookupByLibrary.simpleMessage("Kanaal verlaten"),
    "leaveGroup": MessageLookupByLibrary.simpleMessage("Groep verlaten"),
    "logIn": MessageLookupByLibrary.simpleMessage("Inloggen"),
    "loginButtonTextRe": MessageLookupByLibrary.simpleMessage(
      "Opnieuw proberen",
    ),
    "loginButtonTextSubTitle": MessageLookupByLibrary.simpleMessage(
      "Log in op je geregistreerde account",
    ),
    "makeProfilePrivate": MessageLookupByLibrary.simpleMessage(
      "Profiel privé maken",
    ),
    "memberRemovedFromTheGroupOrChannel": m10,
    "menu": MessageLookupByLibrary.simpleMessage("Menu"),
    "message": MessageLookupByLibrary.simpleMessage("Bericht"),
    "messageEncryptionInfo": MessageLookupByLibrary.simpleMessage(
      "Berichten zijn end-to-end versleuteld. Niemand buiten deze chat, zelfs 212 Messenger niet, kan ze lezen of beluisteren.",
    ),
    "more": MessageLookupByLibrary.simpleMessage("Meer"),
    "muteNotification": MessageLookupByLibrary.simpleMessage(
      "Meldingen dempen",
    ),
    "nameError": MessageLookupByLibrary.simpleMessage(
      "Weergavenaam mag niet leeg zijn",
    ),
    "namePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Voer weergavenaam in",
    ),
    "network_request_failed": MessageLookupByLibrary.simpleMessage(
      "Netwerkfout. Controleer uw internetverbinding.",
    ),
    "newChannel": MessageLookupByLibrary.simpleMessage("Nieuw kanaal"),
    "newContacts": MessageLookupByLibrary.simpleMessage("Nieuwe contacten"),
    "newGroup": MessageLookupByLibrary.simpleMessage("Nieuwe groep"),
    "next": MessageLookupByLibrary.simpleMessage("Volgende"),
    "no": MessageLookupByLibrary.simpleMessage("Nee"),
    "noArchiveChatsFound": MessageLookupByLibrary.simpleMessage(
      "Geen gearchiveerde chats gevonden",
    ),
    "noCallHistoryFound": MessageLookupByLibrary.simpleMessage(
      "Geen oproepgeschiedenis gevonden",
    ),
    "noContactsFound": MessageLookupByLibrary.simpleMessage(
      "Geen geregistreerde contacten beschikbaar. Nodig een lid uit.",
    ),
    "noConversationsFound": MessageLookupByLibrary.simpleMessage(
      "Geen gesprekken gevonden",
    ),
    "noEmailAddress": MessageLookupByLibrary.simpleMessage("Geen e-mailadres"),
    "noMessage": MessageLookupByLibrary.simpleMessage("Geen berichten"),
    "noNotificationsFound": MessageLookupByLibrary.simpleMessage(
      "Geen meldingen gevonden",
    ),
    "noOfMember": m11,
    "noOfSubscriber": m12,
    "noPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Geen telefoonnummer",
    ),
    "noStories": MessageLookupByLibrary.simpleMessage("Geen verhalen"),
    "noStoriesUploadedDescription": MessageLookupByLibrary.simpleMessage(
      "Je hebt nog niets aan je verhaal toegevoegd. Voeg verhalen toe door op de plusknop hieronder te klikken.",
    ),
    "noSubscriptionMessage": MessageLookupByLibrary.simpleMessage(
      "Upgrade om je ervaring te verbeteren! Kies Advertentievrij om advertenties te verwijderen of ga voor Premium voor het volledige pakket met exclusieve functies.",
    ),
    "noViewsYetForStories": MessageLookupByLibrary.simpleMessage(
      "Nog geen weergaven. Niemand heeft je verhaal bekeken.",
    ),
    "notNow": MessageLookupByLibrary.simpleMessage("Niet nu"),
    "notifications": MessageLookupByLibrary.simpleMessage("Meldingen"),
    "notificationsSettings": MessageLookupByLibrary.simpleMessage(
      "Meldingsinstellingen",
    ),
    "numberOfArchiveChats": m13,
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "online": MessageLookupByLibrary.simpleMessage("Online"),
    "onlyAdminsCanSendMessages": MessageLookupByLibrary.simpleMessage(
      "Alleen beheerders kunnen berichten verzenden",
    ),
    "openSetting": MessageLookupByLibrary.simpleMessage("Instellingen openen"),
    "or": MessageLookupByLibrary.simpleMessage("OF"),
    "other": MessageLookupByLibrary.simpleMessage("Anders"),
    "otherUsers": MessageLookupByLibrary.simpleMessage("Andere gebruikers"),
    "otpError": MessageLookupByLibrary.simpleMessage("Voer een geldige OTP in"),
    "otpIsInvalid": MessageLookupByLibrary.simpleMessage("De OTP is ongeldig"),
    "otpNotReceivedText": MessageLookupByLibrary.simpleMessage(
      "OTP niet ontvangen?",
    ),
    "otpVerifySuccess": MessageLookupByLibrary.simpleMessage(
      "OTP succesvol geverifieerd",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Wachtwoord"),
    "pause": MessageLookupByLibrary.simpleMessage("Pauze"),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "Toestemming vereist",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Telefoon"),
    "phoneError": MessageLookupByLibrary.simpleMessage(
      "Telefoonnummer mag niet leeg zijn",
    ),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Telefoonnummer"),
    "phonePlaceholder": MessageLookupByLibrary.simpleMessage("000 000 0000"),
    "phoneVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Telefoonnummer succesvol geverifieerd",
    ),
    "pin": MessageLookupByLibrary.simpleMessage("Vastzetten"),
    "pleaseChangePhoneNumberBeforeUpdate": MessageLookupByLibrary.simpleMessage(
      "Wijzig het telefoonnummer voordat je bijwerkt",
    ),
    "pleaseEnterEmailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Geef alstublieft een e-mailadres OF telefoonnummer op",
    ),
    "pleaseEnterYourEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Voer alstublieft uw e-mailadres in",
    ),
    "pleaseEnterYourOTP": MessageLookupByLibrary.simpleMessage(
      "Voer alstublieft uw OTP in",
    ),
    "pleaseFillOnlyOneFieldEmailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Vul alstublieft slechts één veld in: e-mail of telefoon.",
    ),
    "pleaseSelectChannelImage": MessageLookupByLibrary.simpleMessage(
      "Selecteer een kanaalafbeelding",
    ),
    "pleaseSelectGroupImage": MessageLookupByLibrary.simpleMessage(
      "Selecteer een groepsafbeelding",
    ),
    "pleaseSelectProfileImage": MessageLookupByLibrary.simpleMessage(
      "Selecteer een profielfoto",
    ),
    "pleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Er is iets misgegaan!, probeer het alstublieft opnieuw",
    ),
    "pleaseTryAgainTxt": MessageLookupByLibrary.simpleMessage(
      "Probeer het alstublieft opnieuw!",
    ),
    "pleaseVerifyEmail": MessageLookupByLibrary.simpleMessage(
      "verifieer alstublieft uw e-mail",
    ),
    "premiumComingSoon": MessageLookupByLibrary.simpleMessage(
      "Premium komt binnenkort! Blijf op de hoogte voor exclusieve functies.",
    ),
    "premiumScreenTitle": MessageLookupByLibrary.simpleMessage(
      "212 Messenger Premium",
    ),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage(
      "Privacy en beveiliging",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacybeleid"),
    "privateProfileText": MessageLookupByLibrary.simpleMessage(
      "Je profiel is privé. Alleen bekende contacten kunnen je vinden.",
    ),
    "publicProfileText": MessageLookupByLibrary.simpleMessage(
      "Je profiel is zichtbaar voor iedereen.",
    ),
    "publicUsers": MessageLookupByLibrary.simpleMessage("Openbare gebruikers"),
    "quota_exceeded": MessageLookupByLibrary.simpleMessage(
      "OTP-aanvraaglimiet overschreden. Probeer het later opnieuw.",
    ),
    "react": MessageLookupByLibrary.simpleMessage("Reageren"),
    "recentMessage": MessageLookupByLibrary.simpleMessage("Recente berichten"),
    "recording": MessageLookupByLibrary.simpleMessage("Opname"),
    "recording2": MessageLookupByLibrary.simpleMessage("Opname bezig..."),
    "refresh": MessageLookupByLibrary.simpleMessage("Vernieuwen"),
    "reject": MessageLookupByLibrary.simpleMessage("Weigeren"),
    "removeEmailSuccess": MessageLookupByLibrary.simpleMessage(
      "E-mailadres succesvol verwijderd",
    ),
    "removePhoneSuccess": MessageLookupByLibrary.simpleMessage(
      "Telefoonnummer succesvol verwijderd",
    ),
    "removedUserCannotSendMessage": m14,
    "reply": MessageLookupByLibrary.simpleMessage("Antwoorden"),
    "replyingTo": MessageLookupByLibrary.simpleMessage("Beantwoorden aan: "),
    "reportReasonFakeProfile": MessageLookupByLibrary.simpleMessage(
      "Nepprofiel",
    ),
    "reportReasonHarassment": MessageLookupByLibrary.simpleMessage(
      "Intimidatie",
    ),
    "reportReasonHateSpeech": MessageLookupByLibrary.simpleMessage(
      "Haatspraak",
    ),
    "reportReasonInappropriateContent": MessageLookupByLibrary.simpleMessage(
      "Ongepaste inhoud",
    ),
    "reportReasonScamOrFraud": MessageLookupByLibrary.simpleMessage(
      "Oplichting of fraude",
    ),
    "reportReasonSpam": MessageLookupByLibrary.simpleMessage("Spam"),
    "reportReasonViolenceOrThreats": MessageLookupByLibrary.simpleMessage(
      "Geweld of bedreigingen",
    ),
    "reportUser": MessageLookupByLibrary.simpleMessage("Gebruiker rapporteren"),
    "reportUserButton": MessageLookupByLibrary.simpleMessage(
      "Gebruiker rapporteren",
    ),
    "reportUserDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Beschrijf het probleem (maximaal 300 tekens)...",
    ),
    "reportUserDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Aanvullende details (optioneel)",
    ),
    "reportUserReasonLabel": MessageLookupByLibrary.simpleMessage(
      "Selecteer de reden voor de melding",
    ),
    "reportUserTitle": MessageLookupByLibrary.simpleMessage(
      "Gebruiker rapporteren",
    ),
    "resendOtpText": MessageLookupByLibrary.simpleMessage(
      "OTP opnieuw verzenden",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Opnieuw starten"),
    "restartRecording": MessageLookupByLibrary.simpleMessage(
      "Opname opnieuw starten...",
    ),
    "restorePurchase": MessageLookupByLibrary.simpleMessage(
      "Aankopen herstellen",
    ),
    "sCalls": MessageLookupByLibrary.simpleMessage("Oproepen"),
    "sContacts": MessageLookupByLibrary.simpleMessage("Contacten"),
    "sDcr": MessageLookupByLibrary.simpleMessage("DCR"),
    "sHr": MessageLookupByLibrary.simpleMessage("HR"),
    "sInviteFriends": MessageLookupByLibrary.simpleMessage(
      "Vrienden uitnodigen",
    ),
    "sLastSeen": MessageLookupByLibrary.simpleMessage("Laatst gezien "),
    "sLogout": MessageLookupByLibrary.simpleMessage("Uitloggen"),
    "sLogoutMessage": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je wilt uitloggen uit de applicatie?",
    ),
    "sManager": MessageLookupByLibrary.simpleMessage("Manager"),
    "sProfile": MessageLookupByLibrary.simpleMessage("Mijn profiel"),
    "sSavedMessages": MessageLookupByLibrary.simpleMessage(
      "Opgeslagen berichten",
    ),
    "sSearchContacts": MessageLookupByLibrary.simpleMessage(
      "Zoek contacten...",
    ),
    "sSearchNotifications": MessageLookupByLibrary.simpleMessage(
      "Meldingen zoeken...",
    ),
    "sSettings": MessageLookupByLibrary.simpleMessage("Instellingen"),
    "save": MessageLookupByLibrary.simpleMessage("Opslaan"),
    "saveMessage": MessageLookupByLibrary.simpleMessage("Bericht opslaan"),
    "searchConversations": MessageLookupByLibrary.simpleMessage(
      "Zoek gesprekken...",
    ),
    "searchCountry": MessageLookupByLibrary.simpleMessage("Zoek land"),
    "searchUsers": MessageLookupByLibrary.simpleMessage("Gebruikers zoeken"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Alles selecteren"),
    "selectContactToInviteThem": MessageLookupByLibrary.simpleMessage(
      "Selecteer contacten om ze uit te nodigen voor 212 Private Messenger",
    ),
    "selectMedia": MessageLookupByLibrary.simpleMessage("Media selecteren"),
    "send": MessageLookupByLibrary.simpleMessage("Versturen"),
    "sendMediaAndFilesToStoreThem": MessageLookupByLibrary.simpleMessage(
      "Stuur media en bestanden om ze op te slaan",
    ),
    "shareYourContacts": MessageLookupByLibrary.simpleMessage(
      "Je contacten delen?",
    ),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "Er is iets misgegaan!",
    ),
    "somethingWentWrongPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Er is iets misgegaan. Probeer het opnieuw.",
    ),
    "sortedByLastSeenTime": MessageLookupByLibrary.simpleMessage(
      "Gesorteerd op laatst gezien",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "stop": MessageLookupByLibrary.simpleMessage("Stoppen"),
    "stopNotifications": MessageLookupByLibrary.simpleMessage("Stop meldingen"),
    "submitButtonText": MessageLookupByLibrary.simpleMessage("Verzenden"),
    "subscribers": MessageLookupByLibrary.simpleMessage("Abonnees"),
    "tapToStartRecord": MessageLookupByLibrary.simpleMessage(
      "Tik op Start om op te nemen",
    ),
    "timer24Hours": MessageLookupByLibrary.simpleMessage("24 Uur"),
    "timer7Days": MessageLookupByLibrary.simpleMessage("7 Dagen"),
    "timer90Days": MessageLookupByLibrary.simpleMessage("90 Dagen"),
    "timerOff": MessageLookupByLibrary.simpleMessage("Uit"),
    "todayStories": MessageLookupByLibrary.simpleMessage(
      "Verhalen van vandaag",
    ),
    "too_many_requests": MessageLookupByLibrary.simpleMessage(
      "Te veel pogingen. Probeer het later opnieuw.",
    ),
    "typeMessage": MessageLookupByLibrary.simpleMessage("Typ een bericht"),
    "unArchive": MessageLookupByLibrary.simpleMessage("Dearchiveren"),
    "unBlockUser": MessageLookupByLibrary.simpleMessage(
      "Gebruiker deblokkeren",
    ),
    "unPin": MessageLookupByLibrary.simpleMessage("Losmaken"),
    "unblockUserSubtitle": m15,
    "unblockUserSuccessfully": m16,
    "unblockUserTitle": MessageLookupByLibrary.simpleMessage(
      "Gebruiker deblokkeren?",
    ),
    "upTo200000Members": MessageLookupByLibrary.simpleMessage(
      "Tot 200000 leden",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Bijwerken"),
    "updateBtnTxt": MessageLookupByLibrary.simpleMessage("Bijwerken"),
    "upgradeToPremium": MessageLookupByLibrary.simpleMessage(
      "Upgrade naar Premium",
    ),
    "uploadStory": MessageLookupByLibrary.simpleMessage("Verhaal uploaden"),
    "useSearchToQuicklyFindThings": MessageLookupByLibrary.simpleMessage(
      "Gebruik zoeken om snel dingen te vinden",
    ),
    "userBlockedYouSoCannotSendMessage": m17,
    "userIDError": MessageLookupByLibrary.simpleMessage(
      "De gebruikersnaam mag niet leeg zijn.",
    ),
    "userNameError": MessageLookupByLibrary.simpleMessage(
      "Gebruikersnaam mag niet leeg zijn",
    ),
    "userNameIsAlreadyInUse": MessageLookupByLibrary.simpleMessage(
      "Deze gebruikersnaam is al in gebruik. Kies een andere.",
    ),
    "userNotFound": MessageLookupByLibrary.simpleMessage(
      "Gebruiker niet gevonden",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Gebruikersnaam"),
    "usernameInvalidCharacters": MessageLookupByLibrary.simpleMessage(
      "De gebruikersnaam bevat ongeldige tekens. Alleen letters, cijfers, onderstrepingstekens (_) en streepjes (-) zijn toegestaan.",
    ),
    "usernamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Voer gebruikersnaam in",
    ),
    "usernameValidationError": MessageLookupByLibrary.simpleMessage(
      "De gebruikersnaam mag geen spaties bevatten. Het mag echter onderstrepingstekens (_), letters, cijfers en streepjes (-) bevatten.",
    ),
    "verificationOtp": MessageLookupByLibrary.simpleMessage("Verificatie Otp"),
    "verifyPhoneNumberError": MessageLookupByLibrary.simpleMessage(
      "Verifieer alstublieft het telefoonnummer",
    ),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoDurationIsMorethen30Sec": MessageLookupByLibrary.simpleMessage(
      "De videoduur overschrijdt 30 seconden. Selecteer een kortere video.",
    ),
    "viewContact": MessageLookupByLibrary.simpleMessage("Bekijk contact"),
    "whoWouldYouLikeToAdd": MessageLookupByLibrary.simpleMessage(
      "Wie wil je toevoegen?",
    ),
    "writeCaptionHere": MessageLookupByLibrary.simpleMessage(
      "Schrijf hier een onderschrift",
    ),
    "wrongOtp": MessageLookupByLibrary.simpleMessage(
      "De ingevoerde OTP is onjuist. Probeer het opnieuw.",
    ),
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
    "you": MessageLookupByLibrary.simpleMessage("Jij"),
    "youCanAddAnEmailAddressInProfileSettings":
        MessageLookupByLibrary.simpleMessage(
          "Je kunt een e-mailadres toevoegen in de profielinstellingen.",
        ),
    "youCanAddPhoneNumberInProfileSettings":
        MessageLookupByLibrary.simpleMessage(
          "Je kunt een telefoonnummer toevoegen in de profielinstellingen.",
        ),
    "youHaveSuccesfullyRepoartuser": m18,
    "yourCloudStorage": MessageLookupByLibrary.simpleMessage(
      "Jouw cloudopslag",
    ),
    "yourStories": MessageLookupByLibrary.simpleMessage("Jouw verhalen"),
  };
}
