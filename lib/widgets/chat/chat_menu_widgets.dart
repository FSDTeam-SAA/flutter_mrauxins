import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';

Widget buildChatEmojiPicker(
    BuildContext context, void Function(String) onEmojiSelected) {
  return SizedBox(
    height: 310,
    child: Theme(
      data: ThemeData.dark(),
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) => onEmojiSelected(emoji.emoji),
      ),
    ),
  );
}

Widget buildChatMenuItemRow(MenuItem item, Widget icon, VoidCallback onTap) {
  final color = item.isDestructive ? AppColors.redColor : AppColors.dark;
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          IconTheme(data: IconThemeData(color: color), child: icon),
          8.s,
          Text(item.label, style: AppTextStyles.regular(color: color)),
        ],
      ),
    ),
  );
}
