import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class PinnedMessagesWidget extends StatefulWidget {
  final List<MessageModel> pinnedMessages; // List of pinned messages
  final Function(MessageModel message) onViewMessage;
  final Function(String messageId) onUnpin;
  final String currentUserId;
  const PinnedMessagesWidget({
    required this.pinnedMessages,
    required this.onViewMessage,
    required this.onUnpin,
    required this.currentUserId,
    super.key,
  });

  @override
  State<PinnedMessagesWidget> createState() => _PinnedMessagesWidgetState();
}

class _PinnedMessagesWidgetState extends State<PinnedMessagesWidget> {
  int _currentIndex = 0;

  MessageModel currentMessage = MessageModel();

  @override
  void initState() {
    if (widget.pinnedMessages.isNotEmpty) {
      currentMessage = widget.pinnedMessages[_currentIndex];
    }
    if (mounted) {
      setState(() {});
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PinnedMessagesWidget oldWidget) {
    _currentIndex = 0;
    if (widget.pinnedMessages.isNotEmpty) {
      currentMessage = widget.pinnedMessages[_currentIndex];
    }
    if (mounted) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  void _nextMessage() {
    if (_currentIndex < widget.pinnedMessages.length - 1) {
      setState(() {
        _currentIndex++;
        currentMessage = widget.pinnedMessages[_currentIndex];
      });
    }
  }

  void _previousMessage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        currentMessage = widget.pinnedMessages[_currentIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pinnedMessages.isEmpty) {
      return const SizedBox(); // Hide if no pinned messages
    }

    final chatCubit = context.read<ChatCubit>();

    return BlocBuilder<ChatCubit, ChatState>(builder: (contextChat, state) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.darkInputFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.push_pin, color: AppColors.white),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => widget.onViewMessage(currentMessage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentUserId == currentMessage.sender?.id
                          ? S.of(context).you
                          : AppMethods.getNickName(currentMessage.sender),
                      style: AppTextStyles.medium(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentMessage.content ?? S.of(context).noMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular(),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                TextButton(
                  onPressed: () => chatCubit.unPinMessage(
                    chatId: currentMessage.chatId ?? "",
                    messageId: currentMessage.messageId ?? "",
                  ),
                  child: Text(
                    S.of(context).unPin,
                    style: AppTextStyles.regular(color: AppColors.purpleText),
                  ),
                ),
                if (widget.pinnedMessages.length > 1)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _previousMessage,
                        behavior: HitTestBehavior.translucent,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.arrow_back,
                            color: _currentIndex > 0
                                ? AppColors.primaryColor
                                : AppColors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _nextMessage,
                        behavior: HitTestBehavior.translucent,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.arrow_forward,
                            color: _currentIndex < widget.pinnedMessages.length - 1
                                ? AppColors.primaryColor
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
