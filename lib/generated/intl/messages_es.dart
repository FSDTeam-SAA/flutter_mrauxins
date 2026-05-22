// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(userName) =>
      "${userName} ya no podrá llamarte ni enviarte mensajes.";

  static String m1(userName) => "Has bloqueado a ${userName} con éxito";

  static String m2(userName) =>
      "No puedes enviar mensajes a ${userName} porque los has bloqueado.";

  static String m3(value) => "${value} seleccionado";

  static String m4(userName, days) =>
      "${userName} usa el temporizador predeterminado para mensajes que desaparecen en nuevos chats. Los nuevos mensajes desaparecerán de este chat en ${days} días después de ser enviados, excepto cuando se guarden.\nToca para establecer tu propio temporizador predeterminado.";

  static String m5(value) => "Editar ${value}";

  static String m6(groupOrChannel) =>
      "¡${groupOrChannel} actualizado con éxito!";

  static String m7(value) =>
      "¿Sigue siendo \'${value}\' tu dirección de correo electrónico?";

  static String m8(value) => "¿Sigue siendo \'${value}\' tu número?";

  static String m9(value) => "Por favor, ingrese el OTP recibido en ${value}";

  static String m10(MemberName, group) =>
      "${MemberName} ha sido eliminado del ${group}.";

  static String m11(value) => "${value} Miembros";

  static String m12(value) => "${value} Suscriptor";

  static String m13(number) => "${number} chats archivados disponibles";

  static String m14(name) =>
      "No puedes enviar mensajes porque ya no eres miembro de ${name}.";

  static String m15(userName) =>
      "Podrás recibir mensajes y llamadas de ${userName} nuevamente.";

  static String m16(userName) => "Has desbloqueado a ${userName} con éxito";

  static String m17(userName) =>
      "${userName} te ha bloqueado, por lo que no puedes enviarle mensajes.";

  static String m18(name) => "Has reportado con éxito al usuario ${name}.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutYouError": MessageLookupByLibrary.simpleMessage(
      "La sección \'Acerca de ti\' no puede estar vacía",
    ),
    "aboutYouPlaceholder": MessageLookupByLibrary.simpleMessage("Sobre ti"),
    "accept": MessageLookupByLibrary.simpleMessage("Aceptar"),
    "accessThisCharFromAnyDevice": MessageLookupByLibrary.simpleMessage(
      "Accede a este chat desde cualquier dispositivo",
    ),
    "accessThisChatFromAnyDevice": MessageLookupByLibrary.simpleMessage(
      "Accede a este chat desde cualquier dispositivo",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Cuenta"),
    "adFreeUserMessage": MessageLookupByLibrary.simpleMessage(
      "¡Eres un usuario sin anuncios! Disfruta de nuestra aplicación sin publicidad. Mejora a Premium para obtener aún más funciones exclusivas.",
    ),
    "addFewWordsAboutYourself": MessageLookupByLibrary.simpleMessage(
      "Añade algunas palabras sobre ti en Configuración de Perfil.",
    ),
    "addMembers": MessageLookupByLibrary.simpleMessage("Agregar miembros"),
    "addMessage": MessageLookupByLibrary.simpleMessage("Añadir un mensaje..."),
    "addSubscribers": MessageLookupByLibrary.simpleMessage(
      "Añadir suscriptores",
    ),
    "admin": MessageLookupByLibrary.simpleMessage("Administrador"),
    "allowMembersToSendMessage": MessageLookupByLibrary.simpleMessage(
      "Permitir que los miembros envíen mensajes",
    ),
    "archive": MessageLookupByLibrary.simpleMessage("Archivar"),
    "archiveChats": MessageLookupByLibrary.simpleMessage("Archivar chats"),
    "areYouSureToWantToArchiveThisChat": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres archivar este chat?",
    ),
    "areYouSureToWantToUnArchiveThisChat": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres desarchivar este chat?",
    ),
    "askContactPermission": MessageLookupByLibrary.simpleMessage(
      "Usamos tus contactos para ayudarte a encontrar amigos en la app. Por favor, habilita el acceso a los contactos en la configuración.",
    ),
    "bio": MessageLookupByLibrary.simpleMessage("Biografía"),
    "block": MessageLookupByLibrary.simpleMessage("Bloquear"),
    "blockUser": MessageLookupByLibrary.simpleMessage("Bloquear usuario"),
    "blockUserSubtitle": m0,
    "blockUserSuccessfully": m1,
    "blockUserTitle": MessageLookupByLibrary.simpleMessage(
      "¿Bloquear usuario?",
    ),
    "blockedContacts": MessageLookupByLibrary.simpleMessage(
      "Contactos bloqueados",
    ),
    "blockedUserCannotSendMessage": m2,
    "btnVerifyTxt": MessageLookupByLibrary.simpleMessage("Verificar"),
    "buyAdFree": MessageLookupByLibrary.simpleMessage("Comprar Sin Anuncios"),
    "buyPremium": MessageLookupByLibrary.simpleMessage("Comprar Premium"),
    "callHistory": MessageLookupByLibrary.simpleMessage(
      "Historial de llamadas",
    ),
    "calls": MessageLookupByLibrary.simpleMessage("Llamada"),
    "camera": MessageLookupByLibrary.simpleMessage("Cámara"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "cannotSendMessageToDeletedUser": MessageLookupByLibrary.simpleMessage(
      "No puedes enviar mensajes a este usuario porque su cuenta ha sido eliminada.",
    ),
    "channel": MessageLookupByLibrary.simpleMessage("Canal"),
    "channelCreatedEmptyChatMsg": MessageLookupByLibrary.simpleMessage(
      "ha creado un nuevo canal",
    ),
    "channelNameError": MessageLookupByLibrary.simpleMessage(
      "El nombre del canal no puede estar vacío",
    ),
    "channelNamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Ingrese el nombre del canal",
    ),
    "channelPermission": MessageLookupByLibrary.simpleMessage(
      "Permiso del canal",
    ),
    "clear": MessageLookupByLibrary.simpleMessage("Borrar"),
    "clearCallLog": MessageLookupByLibrary.simpleMessage(
      "Borrar registros de llamadas",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Borrar chat"),
    "clearNotification": MessageLookupByLibrary.simpleMessage(
      "Borrar todas las notificaciones",
    ),
    "clearNotificationSubTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas borrar todas las notificaciones?",
    ),
    "clear_all_calls_subtitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas eliminar todo el historial de llamadas? Esta acción no se puede deshacer.",
    ),
    "clear_all_calls_title": MessageLookupByLibrary.simpleMessage(
      "Borrar historial de llamadas",
    ),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Próximamente"),
    "connecting": MessageLookupByLibrary.simpleMessage("Conectando..."),
    "contactUseDescription": MessageLookupByLibrary.simpleMessage(
      "Para ayudarte a conectar con amigos que ya usan la app, podemos subir tu lista de contactos a nuestro servidor con tu permiso. Esto solo se utiliza para encontrar coincidencias de contactos — nunca compartimos tus datos.",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "¡Copiado al portapapeles!",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copiar"),
    "countSelected": m3,
    "createChannelBtn": MessageLookupByLibrary.simpleMessage("Crear canal"),
    "createGroupBtn": MessageLookupByLibrary.simpleMessage("Crear grupo"),
    "customContactUploadConsentTitle": MessageLookupByLibrary.simpleMessage(
      "¿Subir contactos?",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Eliminar cuenta"),
    "deleteAccountSlogen": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres eliminar tu cuenta? Esta acción es irreversible y todos tus mensajes, contactos y datos se perderán permanentemente.",
    ),
    "deleteChannel": MessageLookupByLibrary.simpleMessage("Eliminar canal"),
    "deleteChatSubtitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas eliminar este chat? Esta acción no se puede deshacer y todos los mensajes se eliminarán permanentemente de tu dispositivo.",
    ),
    "deleteForMe": MessageLookupByLibrary.simpleMessage("Eliminar para mí"),
    "deleteGroup": MessageLookupByLibrary.simpleMessage("Eliminar grupo"),
    "deleteGroupAuthority": MessageLookupByLibrary.simpleMessage(
      "Solo el creador del grupo puede eliminar el grupo.",
    ),
    "deleteMessageForEveryone": MessageLookupByLibrary.simpleMessage(
      "Eliminar para todos",
    ),
    "deleteSelected": MessageLookupByLibrary.simpleMessage(
      "Eliminar seleccionado",
    ),
    "deleteThisChat": MessageLookupByLibrary.simpleMessage(
      "¿Eliminar este chat?",
    ),
    "delete_selected_calls_subtitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas eliminar las llamadas seleccionadas? Esta acción no se puede deshacer.",
    ),
    "delete_selected_calls_title": MessageLookupByLibrary.simpleMessage(
      "Eliminar llamadas seleccionadas",
    ),
    "disableVideo": MessageLookupByLibrary.simpleMessage("Desactivar video"),
    "disappearingMessage": MessageLookupByLibrary.simpleMessage(
      "Mensajes que desaparecen",
    ),
    "disappearingMessageDescription": MessageLookupByLibrary.simpleMessage(
      "Cuando se activa, todos los nuevos chats individuales comenzarán con mensajes temporales configurados con la duración que selecciones. Esta configuración no afectará tus chats existentes.",
    ),
    "disappearingMessageInfo": m4,
    "disappearingMessageTitle": MessageLookupByLibrary.simpleMessage(
      "Iniciar un nuevo chat con el temporizador de mensajes que desaparecen configurado en",
    ),
    "document": MessageLookupByLibrary.simpleMessage("Documento"),
    "edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "editImage": MessageLookupByLibrary.simpleMessage("Editar imagen"),
    "editMessage": MessageLookupByLibrary.simpleMessage("Editar mensaje"),
    "editPhoneOrEmail": m5,
    "edited": MessageLookupByLibrary.simpleMessage("Editado"),
    "email": MessageLookupByLibrary.simpleMessage("Correo electrónico"),
    "emailAddressIsAlreadyUpdated": MessageLookupByLibrary.simpleMessage(
      "Por favor, cambia la dirección de correo electrónico antes de actualizar.",
    ),
    "emailAddressIsInvalid": MessageLookupByLibrary.simpleMessage(
      "La dirección de correo electrónico no es válida",
    ),
    "emailAdress": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico",
    ),
    "emailChangeSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico cambiada con éxito",
    ),
    "emailError": MessageLookupByLibrary.simpleMessage(
      "El correo electrónico no puede estar vacío",
    ),
    "emailPlaceHolder": MessageLookupByLibrary.simpleMessage(
      "Ingresa la dirección de correo electrónico",
    ),
    "emailVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico verificada con éxito",
    ),
    "enableVideo": MessageLookupByLibrary.simpleMessage("Activar video"),
    "endCall": MessageLookupByLibrary.simpleMessage("Finalizar llamada"),
    "enterValidUsername": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduce un nombre de usuario válido.",
    ),
    "errorCannotRemoveEmail": MessageLookupByLibrary.simpleMessage(
      "No puedes eliminar el correo electrónico porque tu número de teléfono no está registrado o verificado en tu cuenta.",
    ),
    "errorCannotRemovePhone": MessageLookupByLibrary.simpleMessage(
      "No puedes eliminar el número de teléfono porque tu correo electrónico no está registrado o verificado en tu cuenta.",
    ),
    "facebookText": MessageLookupByLibrary.simpleMessage("Facebook"),
    "forward": MessageLookupByLibrary.simpleMessage("Reenviar"),
    "forwardMessageHereToSaveThem": MessageLookupByLibrary.simpleMessage(
      "Reenvía mensajes aquí para guardarlos",
    ),
    "forwardMessageLimitText": MessageLookupByLibrary.simpleMessage(
      "Puedes reenviar mensajes a hasta 5 miembros o grupos.",
    ),
    "forwardTo": MessageLookupByLibrary.simpleMessage("Reenviar a"),
    "gallery": MessageLookupByLibrary.simpleMessage("Galería"),
    "giftsCommingSoon": MessageLookupByLibrary.simpleMessage(
      "¡Regalos próximamente!",
    ),
    "giftsCommingSoonMessage": MessageLookupByLibrary.simpleMessage(
      "Estamos trabajando duro para traerte una nueva forma divertida de enviar regalos. ¡Mantente atento y estate pendiente de esta función en la próxima actualización!",
    ),
    "googleText": MessageLookupByLibrary.simpleMessage("Google"),
    "group": MessageLookupByLibrary.simpleMessage("Grupo"),
    "groupCreatedEmptyChatMsg": MessageLookupByLibrary.simpleMessage(
      "ha creado un nuevo grupo, ¡así que puedes empezar la conversación!",
    ),
    "groupMembers": MessageLookupByLibrary.simpleMessage("Miembros del grupo"),
    "groupMembersLimitrichMessage": MessageLookupByLibrary.simpleMessage(
      "No puedes agregar más de 200,000 miembros",
    ),
    "groupNameError": MessageLookupByLibrary.simpleMessage(
      "El nombre del grupo no puede estar vacío",
    ),
    "groupNamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Ingrese el nombre del grupo",
    ),
    "groupOrChannelUpdateSuccessfully": m6,
    "groupPermission": MessageLookupByLibrary.simpleMessage("Permiso de grupo"),
    "image": MessageLookupByLibrary.simpleMessage("Imagen"),
    "info": MessageLookupByLibrary.simpleMessage("Información"),
    "invalid_phone_number": MessageLookupByLibrary.simpleMessage(
      "El número de teléfono no es válido. Por favor, verifíquelo e inténtelo de nuevo.",
    ),
    "inviteFriend": MessageLookupByLibrary.simpleMessage("Invitar amigo"),
    "inviteToChannel": MessageLookupByLibrary.simpleMessage("Invitar al canal"),
    "inviteToGroup": MessageLookupByLibrary.simpleMessage("Invitar al grupo"),
    "isStillYourEmailAddress": m7,
    "isStillYourNumber": m8,
    "language": MessageLookupByLibrary.simpleMessage("Idioma"),
    "languages": MessageLookupByLibrary.simpleMessage("Idiomas"),
    "lblAlert": MessageLookupByLibrary.simpleMessage("Alerta"),
    "lblAlertSubtitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres salir de la aplicación?",
    ),
    "lblChannelInfo": MessageLookupByLibrary.simpleMessage(
      "Información del canal",
    ),
    "lblClearChatSubTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres borrar el chat?",
    ),
    "lblContinue": MessageLookupByLibrary.simpleMessage("Continuar"),
    "lblCreateProfile": MessageLookupByLibrary.simpleMessage("Crear perfil"),
    "lblDeleteChannelSubTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres eliminar este canal?",
    ),
    "lblDeleteGroupSubTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres eliminar este grupo?",
    ),
    "lblDeleteMessage": MessageLookupByLibrary.simpleMessage(
      "Eliminar mensaje",
    ),
    "lblDeleteMessageSubTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres eliminar este mensaje?",
    ),
    "lblDeleteStories": MessageLookupByLibrary.simpleMessage(
      "Eliminar historia",
    ),
    "lblDeleteStoriesSubTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres eliminar la historia?",
    ),
    "lblEditProfile": MessageLookupByLibrary.simpleMessage("Editar perfil"),
    "lblEmailChangeTxt": MessageLookupByLibrary.simpleMessage(
      "Toca para cambiar la dirección de correo electrónico",
    ),
    "lblExit": MessageLookupByLibrary.simpleMessage("Salir"),
    "lblGroupInfo": MessageLookupByLibrary.simpleMessage(
      "Información del grupo",
    ),
    "lblKeepYourEmailAddressUptoDate": MessageLookupByLibrary.simpleMessage(
      "Mantén tu dirección de correo electrónico actualizada para asegurarte de que siempre puedas iniciar sesión en 212 Private Messenger.",
    ),
    "lblKeepYourNumberUptoDate": MessageLookupByLibrary.simpleMessage(
      "Mantén tu número actualizado para asegurarte de que siempre puedas iniciar sesión en 212 Private Messenger.",
    ),
    "lblLeaveChannelSubTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres salir de este canal?",
    ),
    "lblLeaveGroupSubTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres salir de este grupo?",
    ),
    "lblLoginSubtitleText": MessageLookupByLibrary.simpleMessage(
      "Por favor, completa los detalles para iniciar sesión",
    ),
    "lblLoginText": MessageLookupByLibrary.simpleMessage(
      "212 Private Messenger\n¡Te da la bienvenida!",
    ),
    "lblNewGroup": MessageLookupByLibrary.simpleMessage("Nuevo grupo"),
    "lblNo": MessageLookupByLibrary.simpleMessage("No"),
    "lblNoDataFound": MessageLookupByLibrary.simpleMessage(
      "No se encontraron datos",
    ),
    "lblOtpSubtitleText": m9,
    "lblOtpText": MessageLookupByLibrary.simpleMessage(
      "Ingrese\nCódigo de verificación",
    ),
    "lblPhoneChangeTxt": MessageLookupByLibrary.simpleMessage(
      "Toca para cambiar el número de teléfono",
    ),
    "lblSearchChat": MessageLookupByLibrary.simpleMessage("Buscar chat"),
    "lblSearchUser": MessageLookupByLibrary.simpleMessage("Buscar usuario"),
    "lblShowProfilePhoto": MessageLookupByLibrary.simpleMessage(
      "Mostrar foto de perfil",
    ),
    "lblUpdateProfile": MessageLookupByLibrary.simpleMessage(
      "Perfil actualizado con éxito",
    ),
    "lblUploadMedias": MessageLookupByLibrary.simpleMessage(
      "Subir medios desde",
    ),
    "lblUploadPhotos": MessageLookupByLibrary.simpleMessage(
      "Subir fotos desde",
    ),
    "leaveChannel": MessageLookupByLibrary.simpleMessage("Salir del canal"),
    "leaveGroup": MessageLookupByLibrary.simpleMessage("Salir del grupo"),
    "logIn": MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
    "loginButtonTextRe": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "loginButtonTextSubTitle": MessageLookupByLibrary.simpleMessage(
      "Inicia sesión en tu cuenta registrada",
    ),
    "makeProfilePrivate": MessageLookupByLibrary.simpleMessage(
      "Hacer perfil privado",
    ),
    "memberRemovedFromTheGroupOrChannel": m10,
    "menu": MessageLookupByLibrary.simpleMessage("Menú"),
    "message": MessageLookupByLibrary.simpleMessage("Mensaje"),
    "messageEncryptionInfo": MessageLookupByLibrary.simpleMessage(
      "Los mensajes están cifrados de extremo a extremo. Nadie fuera de este chat, ni siquiera 212 Messenger, puede leerlos o escucharlos.",
    ),
    "more": MessageLookupByLibrary.simpleMessage("Más"),
    "muteNotification": MessageLookupByLibrary.simpleMessage(
      "Silenciar notificaciones",
    ),
    "nameError": MessageLookupByLibrary.simpleMessage(
      "El nombre para mostrar no puede estar vacío",
    ),
    "namePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Ingrese el nombre para mostrar",
    ),
    "network_request_failed": MessageLookupByLibrary.simpleMessage(
      "Error de red. Por favor, verifique su conexión a internet.",
    ),
    "newChannel": MessageLookupByLibrary.simpleMessage("Nuevo canal"),
    "newContacts": MessageLookupByLibrary.simpleMessage("Nuevos contactos"),
    "newGroup": MessageLookupByLibrary.simpleMessage("Nuevo grupo"),
    "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noArchiveChatsFound": MessageLookupByLibrary.simpleMessage(
      "No se encontraron chats archivados",
    ),
    "noCallHistoryFound": MessageLookupByLibrary.simpleMessage(
      "No se encontró historial de llamadas",
    ),
    "noContactsFound": MessageLookupByLibrary.simpleMessage(
      "No hay contactos registrados disponibles. Por favor, invita a un miembro.",
    ),
    "noConversationsFound": MessageLookupByLibrary.simpleMessage(
      "No se encontraron conversaciones",
    ),
    "noEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Sin dirección de correo electrónico",
    ),
    "noMessage": MessageLookupByLibrary.simpleMessage("Sin mensajes"),
    "noNotificationsFound": MessageLookupByLibrary.simpleMessage(
      "No se encontraron notificaciones",
    ),
    "noOfMember": m11,
    "noOfSubscriber": m12,
    "noPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Sin número de teléfono",
    ),
    "noStories": MessageLookupByLibrary.simpleMessage("No hay historias"),
    "noStoriesUploadedDescription": MessageLookupByLibrary.simpleMessage(
      "Aún no has subido nada a tu historia. Por favor, añade historias haciendo clic en el botón más abajo.",
    ),
    "noSubscriptionMessage": MessageLookupByLibrary.simpleMessage(
      "¡Mejora tu experiencia! Elige Sin Anuncios para eliminar la publicidad o adquiere Premium para acceder a todas las funciones exclusivas.",
    ),
    "noViewsYetForStories": MessageLookupByLibrary.simpleMessage(
      "Aún no hay vistas. Nadie ha visto tu historia.",
    ),
    "notNow": MessageLookupByLibrary.simpleMessage("Ahora no"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notificaciones"),
    "notificationsSettings": MessageLookupByLibrary.simpleMessage(
      "Configuración de notificaciones",
    ),
    "numberOfArchiveChats": m13,
    "offline": MessageLookupByLibrary.simpleMessage("Desconectado"),
    "online": MessageLookupByLibrary.simpleMessage("En línea"),
    "onlyAdminsCanSendMessages": MessageLookupByLibrary.simpleMessage(
      "Solo los administradores pueden enviar mensajes",
    ),
    "openSetting": MessageLookupByLibrary.simpleMessage("Abrir configuración"),
    "or": MessageLookupByLibrary.simpleMessage("O"),
    "other": MessageLookupByLibrary.simpleMessage("Otro"),
    "otherUsers": MessageLookupByLibrary.simpleMessage("Otros usuarios"),
    "otpError": MessageLookupByLibrary.simpleMessage("Ingresa un OTP válido"),
    "otpIsInvalid": MessageLookupByLibrary.simpleMessage("El OTP no es válido"),
    "otpNotReceivedText": MessageLookupByLibrary.simpleMessage(
      "¿No recibiste el OTP?",
    ),
    "otpVerifySuccess": MessageLookupByLibrary.simpleMessage(
      "OTP verificado con éxito",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "pause": MessageLookupByLibrary.simpleMessage("Pausa"),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "Permiso requerido",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Teléfono"),
    "phoneError": MessageLookupByLibrary.simpleMessage(
      "El número de teléfono no puede estar vacío",
    ),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Número de teléfono"),
    "phonePlaceholder": MessageLookupByLibrary.simpleMessage("000 000 0000"),
    "phoneVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Número de teléfono verificado con éxito",
    ),
    "pin": MessageLookupByLibrary.simpleMessage("Fijar"),
    "pleaseChangePhoneNumberBeforeUpdate": MessageLookupByLibrary.simpleMessage(
      "Por favor, cambia el número de teléfono antes de actualizar",
    ),
    "pleaseEnterEmailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Por favor, proporcione una dirección de correo electrónico O número de teléfono",
    ),
    "pleaseEnterYourEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingrese su dirección de correo electrónico",
    ),
    "pleaseEnterYourOTP": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingrese su OTP",
    ),
    "pleaseFillOnlyOneFieldEmailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Por favor, complete solo un campo: correo electrónico o teléfono.",
    ),
    "pleaseSelectChannelImage": MessageLookupByLibrary.simpleMessage(
      "Por favor, selecciona una imagen de canal",
    ),
    "pleaseSelectGroupImage": MessageLookupByLibrary.simpleMessage(
      "Por favor, selecciona una imagen de grupo",
    ),
    "pleaseSelectProfileImage": MessageLookupByLibrary.simpleMessage(
      "Por favor, selecciona una imagen de perfil",
    ),
    "pleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "¡Algo salió mal!, por favor inténtalo de nuevo",
    ),
    "pleaseTryAgainTxt": MessageLookupByLibrary.simpleMessage(
      "¡Por favor, inténtalo de nuevo!",
    ),
    "pleaseVerifyEmail": MessageLookupByLibrary.simpleMessage(
      "por favor, verifique su correo electrónico",
    ),
    "premiumComingSoon": MessageLookupByLibrary.simpleMessage(
      "¡Premium llegará pronto! Mantente atento a funciones exclusivas.",
    ),
    "premiumScreenTitle": MessageLookupByLibrary.simpleMessage(
      "212 Messenger Premium",
    ),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage(
      "Privacidad y seguridad",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "privateProfileText": MessageLookupByLibrary.simpleMessage(
      "Tu perfil es privado. Solo los contactos conocidos pueden encontrarte.",
    ),
    "publicProfileText": MessageLookupByLibrary.simpleMessage(
      "Tu perfil es visible para todos.",
    ),
    "publicUsers": MessageLookupByLibrary.simpleMessage("Usuarios Públicos"),
    "quota_exceeded": MessageLookupByLibrary.simpleMessage(
      "Límite de solicitudes de OTP excedido. Inténtelo de nuevo más tarde.",
    ),
    "react": MessageLookupByLibrary.simpleMessage("Reaccionar"),
    "recentMessage": MessageLookupByLibrary.simpleMessage("Mensajes recientes"),
    "recording": MessageLookupByLibrary.simpleMessage("Grabando"),
    "recording2": MessageLookupByLibrary.simpleMessage("Grabando..."),
    "refresh": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "reject": MessageLookupByLibrary.simpleMessage("Rechazar"),
    "removeEmailSuccess": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico eliminada con éxito",
    ),
    "removePhoneSuccess": MessageLookupByLibrary.simpleMessage(
      "Número de teléfono eliminado con éxito",
    ),
    "removedUserCannotSendMessage": m14,
    "reply": MessageLookupByLibrary.simpleMessage("Responder"),
    "replyingTo": MessageLookupByLibrary.simpleMessage("Respondiendo a: "),
    "reportReasonFakeProfile": MessageLookupByLibrary.simpleMessage(
      "Perfil falso",
    ),
    "reportReasonHarassment": MessageLookupByLibrary.simpleMessage("Acoso"),
    "reportReasonHateSpeech": MessageLookupByLibrary.simpleMessage(
      "Discurso de odio",
    ),
    "reportReasonInappropriateContent": MessageLookupByLibrary.simpleMessage(
      "Contenido inapropiado",
    ),
    "reportReasonScamOrFraud": MessageLookupByLibrary.simpleMessage(
      "Estafa o fraude",
    ),
    "reportReasonSpam": MessageLookupByLibrary.simpleMessage("Spam"),
    "reportReasonViolenceOrThreats": MessageLookupByLibrary.simpleMessage(
      "Violencia o amenazas",
    ),
    "reportUser": MessageLookupByLibrary.simpleMessage("Reportar usuario"),
    "reportUserButton": MessageLookupByLibrary.simpleMessage(
      "Reportar usuario",
    ),
    "reportUserDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "Describe el problema (hasta 300 caracteres)...",
    ),
    "reportUserDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Detalles adicionales (Opcional)",
    ),
    "reportUserReasonLabel": MessageLookupByLibrary.simpleMessage(
      "Por favor, selecciona un motivo para el reporte",
    ),
    "reportUserTitle": MessageLookupByLibrary.simpleMessage("Reportar usuario"),
    "resendOtpText": MessageLookupByLibrary.simpleMessage("Reenviar OTP"),
    "restart": MessageLookupByLibrary.simpleMessage("Reiniciar"),
    "restartRecording": MessageLookupByLibrary.simpleMessage(
      "Reiniciar grabación...",
    ),
    "restorePurchase": MessageLookupByLibrary.simpleMessage(
      "Restaurar compras",
    ),
    "sCalls": MessageLookupByLibrary.simpleMessage("Llamadas"),
    "sContacts": MessageLookupByLibrary.simpleMessage("Contactos"),
    "sDcr": MessageLookupByLibrary.simpleMessage("DCR"),
    "sHr": MessageLookupByLibrary.simpleMessage("Recursos Humanos"),
    "sInviteFriends": MessageLookupByLibrary.simpleMessage("Invitar amigos"),
    "sLastSeen": MessageLookupByLibrary.simpleMessage("Visto por última vez "),
    "sLogout": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
    "sLogoutMessage": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas cerrar sesión en la aplicación?",
    ),
    "sManager": MessageLookupByLibrary.simpleMessage("Gerente"),
    "sProfile": MessageLookupByLibrary.simpleMessage("Mi perfil"),
    "sSavedMessages": MessageLookupByLibrary.simpleMessage(
      "Mensajes guardados",
    ),
    "sSearchContacts": MessageLookupByLibrary.simpleMessage(
      "Buscar contactos...",
    ),
    "sSearchNotifications": MessageLookupByLibrary.simpleMessage(
      "Buscar notificaciones...",
    ),
    "sSettings": MessageLookupByLibrary.simpleMessage("Configuraciones"),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "saveMessage": MessageLookupByLibrary.simpleMessage("Guardar mensaje"),
    "searchConversations": MessageLookupByLibrary.simpleMessage(
      "Buscar conversaciones...",
    ),
    "searchCountry": MessageLookupByLibrary.simpleMessage("Buscar país"),
    "searchUsers": MessageLookupByLibrary.simpleMessage("Buscar usuarios"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Seleccionar todo"),
    "selectContactToInviteThem": MessageLookupByLibrary.simpleMessage(
      "Selecciona contactos para invitarlos a 212 Private Messenger",
    ),
    "selectMedia": MessageLookupByLibrary.simpleMessage("Seleccionar medio"),
    "send": MessageLookupByLibrary.simpleMessage("Enviar"),
    "sendMediaAndFilesToStoreThem": MessageLookupByLibrary.simpleMessage(
      "Envía medios y archivos para almacenarlos",
    ),
    "shareYourContacts": MessageLookupByLibrary.simpleMessage(
      "¿Compartir tus contactos?",
    ),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "¡Algo salió mal!",
    ),
    "somethingWentWrongPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Algo salió mal. Por favor, inténtelo de nuevo.",
    ),
    "sortedByLastSeenTime": MessageLookupByLibrary.simpleMessage(
      "Ordenado por última vez visto",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Iniciar"),
    "stop": MessageLookupByLibrary.simpleMessage("Detener"),
    "stopNotifications": MessageLookupByLibrary.simpleMessage(
      "Detener notificaciones",
    ),
    "submitButtonText": MessageLookupByLibrary.simpleMessage("Enviar"),
    "subscribers": MessageLookupByLibrary.simpleMessage("Suscriptores"),
    "tapToStartRecord": MessageLookupByLibrary.simpleMessage(
      "Toca Iniciar para grabar",
    ),
    "timer24Hours": MessageLookupByLibrary.simpleMessage("24 Horas"),
    "timer7Days": MessageLookupByLibrary.simpleMessage("7 Días"),
    "timer90Days": MessageLookupByLibrary.simpleMessage("90 Días"),
    "timerOff": MessageLookupByLibrary.simpleMessage("Desactivado"),
    "todayStories": MessageLookupByLibrary.simpleMessage("Historias de hoy"),
    "too_many_requests": MessageLookupByLibrary.simpleMessage(
      "Demasiados intentos. Por favor, inténtelo de nuevo más tarde.",
    ),
    "typeMessage": MessageLookupByLibrary.simpleMessage("Escribe un mensaje"),
    "unArchive": MessageLookupByLibrary.simpleMessage("Desarchivar"),
    "unBlockUser": MessageLookupByLibrary.simpleMessage("Desbloquear usuario"),
    "unPin": MessageLookupByLibrary.simpleMessage("Desanclar"),
    "unblockUserSubtitle": m15,
    "unblockUserSuccessfully": m16,
    "unblockUserTitle": MessageLookupByLibrary.simpleMessage(
      "¿Desbloquear usuario?",
    ),
    "upTo200000Members": MessageLookupByLibrary.simpleMessage(
      "Hasta 200000 miembros",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "updateBtnTxt": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "upgradeToPremium": MessageLookupByLibrary.simpleMessage(
      "Actualizar a Premium",
    ),
    "uploadStory": MessageLookupByLibrary.simpleMessage("Subir historia"),
    "useSearchToQuicklyFindThings": MessageLookupByLibrary.simpleMessage(
      "Usa la búsqueda para encontrar cosas rápidamente",
    ),
    "userBlockedYouSoCannotSendMessage": m17,
    "userIDError": MessageLookupByLibrary.simpleMessage(
      "El nombre de usuario no puede estar vacío.",
    ),
    "userNameError": MessageLookupByLibrary.simpleMessage(
      "El nombre de usuario no puede estar vacío",
    ),
    "userNameIsAlreadyInUse": MessageLookupByLibrary.simpleMessage(
      "Este nombre de usuario ya está en uso. Por favor, elige otro.",
    ),
    "userNotFound": MessageLookupByLibrary.simpleMessage(
      "Usuario no encontrado",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Nombre de usuario"),
    "usernameInvalidCharacters": MessageLookupByLibrary.simpleMessage(
      "El nombre de usuario contiene caracteres no válidos. Solo se permiten letras, números, guiones bajos (_) y guiones (-).",
    ),
    "usernamePlaceholder": MessageLookupByLibrary.simpleMessage(
      "Ingrese nombre de usuario",
    ),
    "usernameValidationError": MessageLookupByLibrary.simpleMessage(
      "El nombre de usuario no debe contener espacios. Sin embargo, puede incluir guiones bajos (_), letras, números y guiones (-).",
    ),
    "verificationOtp": MessageLookupByLibrary.simpleMessage("Verificación Otp"),
    "verifyPhoneNumberError": MessageLookupByLibrary.simpleMessage(
      "Por favor, verifica el número de teléfono",
    ),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoDurationIsMorethen30Sec": MessageLookupByLibrary.simpleMessage(
      "La duración del video supera los 30 segundos. Por favor, selecciona un video más corto.",
    ),
    "viewContact": MessageLookupByLibrary.simpleMessage("Ver contacto"),
    "whoWouldYouLikeToAdd": MessageLookupByLibrary.simpleMessage(
      "¿A quién te gustaría agregar?",
    ),
    "writeCaptionHere": MessageLookupByLibrary.simpleMessage(
      "Escribe un pie de foto aquí",
    ),
    "wrongOtp": MessageLookupByLibrary.simpleMessage(
      "El OTP que ingresó es incorrecto. Por favor, inténtelo de nuevo.",
    ),
    "yes": MessageLookupByLibrary.simpleMessage("Sí"),
    "you": MessageLookupByLibrary.simpleMessage("Tú"),
    "youCanAddAnEmailAddressInProfileSettings":
        MessageLookupByLibrary.simpleMessage(
          "Puedes añadir una dirección de correo electrónico en Configuración de Perfil.",
        ),
    "youCanAddPhoneNumberInProfileSettings":
        MessageLookupByLibrary.simpleMessage(
          "Puedes añadir un número de teléfono en Configuración de Perfil.",
        ),
    "youHaveSuccesfullyRepoartuser": m18,
    "yourCloudStorage": MessageLookupByLibrary.simpleMessage(
      "Tu almacenamiento en la nube",
    ),
    "yourStories": MessageLookupByLibrary.simpleMessage("Tus historias"),
  };
}
