import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../../extension/sizebox.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/text_style.dart';
import '../../utils/utils.dart';
import 'search_widgets.dart';

class ContactsBody extends StatelessWidget {
  const ContactsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      if (state.contactsLoadingState == LoadingState.loading) {
        return const Center(child: CustomLoadingWidget());
      }
      return GroupedListWithRail<ContactUser>(
        items: state.displayedContacts,
        nameOf: (u) => u.name ?? '',
        tileBuilder: (user) => _ContactTile(user: user),
        emptyState: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(S.of(context).noContactsFound),
          ),
        ),
      );
    });
  }
}

class _ContactTile extends StatelessWidget {
  final ContactUser user;

  const _ContactTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final isRegistered = user.isRegistered ?? false;
    final phone = (user.phone ?? "").isEmpty
        ? ""
        : "${user.countryCode ?? ""}${user.phone ?? ""}";

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isRegistered
          ? () async {
              ParticipantDetail sender =
                  ParticipantDetail.fromJson(user.toJson());
              await chatCubit.resetChatScreenState();
              NavigationService().replaceWith(ChatScreen(
                chatType: ChatType.one_to_one,
                sender: sender,
                unreadMessageCount: 0,
                userName: user.name ?? "",
                userId: user.sId ?? "",
                userPic: user.profilePicture ?? "",
                chatId: '',
                aesKey: '',
                isSendMessage: true,
                isShowProfileImage: true,
              ));
            }
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Row(
          children: [
            AvatarWidgets(
                userPic: user.profilePicture ?? "", height: 42, width: 42),
            12.s,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name ?? "Unknown",
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(fontSize: 15.sp)),
                  4.s,
                  Text(
                    (user.isOnline ?? false)
                        ? S.of(context).online
                        : (user.lastSeen != null)
                            ? "${S.of(context).sLastSeen}${DateTime.parse(user.lastSeen!).toLocal().formattedDateWithDayMonthAtTime}"
                            : (isRegistered ? "" : phone),
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular(
                        fontSize: 12.sp,
                        color: AppColors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            if (!isRegistered)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (phone.isNotEmpty) {
                    Utils.sendSMS(
                        phone,
                        Platform.isIOS
                            ? AppConstants.inviteLinkForIos
                            : AppConstants.inviteLinkForAndroid);
                  }
                },
                child: Text(
                  S.of(context).inviteFriend,
                  style: AppTextStyles.regular(
                      fontSize: 12.sp, color: AppColors.purpleText),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
