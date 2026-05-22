import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/appbar.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/conversation_tile.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

class ArchiveChats extends StatefulWidget {
  const ArchiveChats({super.key, required this.user});
  final UserData user;
  @override
  State<ArchiveChats> createState() => _ArchiveChatsState();
}

class _ArchiveChatsState extends State<ArchiveChats> {
  int currentPage = 1;

  @override
  void initState() {

    super.initState();
    onInit();
  }

  Future<void> onInit() async {
    fetchData();
  }

  Future<void> fetchConversationData() async {
    await context.read<HomeCubit>().getConversation(context: context);
    showMessage("state ==> ${context.read<HomeCubit>().state}");
  }

  Future<void> fetchData() async {
    currentPage = 1;

    await fetchConversationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        isActionsShow: false,
        title: S.of(context).archiveChats,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.homeLoadingState == LoadingState.loading) {
            return Center(child: CustomLoadingWidget());
          } else if (state.homeLoadingState == LoadingState.success) {
            if ((state.conversationModel?.archiveChats ?? []).isEmpty) {
              return Center(child: Text(S.of(context).noArchiveChatsFound));
            }

            return SlidableAutoCloseBehavior(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: AppColors.dividerColor,
                  height: 1.h,
                ),
                itemCount: state.conversationModel!.archiveChats!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  ParticipantDetail? participant;
                  bool isGroup =
                      state.conversationModel!.archiveChats![index].type !=
                          ChatType.one_to_one;
                  if (!isGroup) {
                    try {
                      participant = state.conversationModel
                          ?.archiveChats?[index].participantDetails
                          ?.firstWhere(
                              (element) => element.id != widget.user.sId);
                    } catch (e) {
                      participant = null;
                    }
                  }
                  if (widget.user == null) return SizedBox();

                  return ConversationTile(
                      user: widget.user,
                      isGroup: isGroup,
                      isArchive: true,
                      conversationData:
                          state.conversationModel!.archiveChats![index],
                      participantDetails: participant);
                },
              ),
            );
          } else if (state.homeLoadingState == LoadingState.error) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text(S.of(context).pleaseTryAgain)),
                20.s,
                CustomButton(
                    onPressed: () {
                      fetchConversationData();
                    },
                    child: Text(
                      S.of(context).refresh,
                      style: AppTextStyles.baseStyle(),
                    ))
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
