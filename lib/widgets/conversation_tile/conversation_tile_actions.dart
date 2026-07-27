import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/widgets/alert_dialog.dart';

SlidableAction buildDeleteChatAction(
  BuildContext context, {
  required String chatId,
}) {
  return SlidableAction(
    padding: EdgeInsets.zero,
    onPressed: (context) {
      showCommonDeleteDialog(
        context: context,
        subTitle: S.of(context).deleteChatSubtitle,
        title: S.of(context).deleteThisChat,
        onSubmit: () {
          homeCubit.deleteChat(context, chatId);
        },
      );
    },
    backgroundColor: AppColors.redColor,
    foregroundColor: Colors.white,
    icon: Icons.delete,
    label: S.of(context).delete,
  );
}

SlidableAction buildArchiveChatAction(
  BuildContext context, {
  required bool isArchive,
  required String userId,
  required String chatId,
}) {
  return SlidableAction(
    onPressed: (context) {
      log("ConversationTile==> $isArchive");
      CustomAlertDialog(
        context: context,
        icon: Icon(
          Icons.archive,
          color: AppColors.white,
        ),
        title: isArchive
            ? S.of(context).areYouSureToWantToUnArchiveThisChat
            : S.of(context).areYouSureToWantToArchiveThisChat,
        buttonText: S.current.yes,
        onPressed: () {
          if (isArchive) {
            homeCubit.unArchiveChat(userId, chatId);
          } else {
            homeCubit.archiveChat(userId, chatId);
          }
        },
      );
    },
    backgroundColor: AppColors.dialogBg,
    foregroundColor: AppColors.white,
    icon: Icons.archive,
    label: isArchive ? S.of(context).unArchive : S.of(context).archive,
  );
}
