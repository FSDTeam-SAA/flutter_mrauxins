import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/model/menu_item.dart';

class DefaultData {
// default list of five reactions to be displayed from emojis and a plus icon at the end
// the plus icon will be used to add more reactions
  static const List<String> reactions = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '😠',
    '➕',
  ];
  // The default list of menuItems
  static const List<MenuItem> menuItems = [
    reply,
    copy,
    delete,
  ];

  // defaul reply menu item
  static const MenuItem reply = MenuItem(
    label: 'Reply',
    value: 'Reply',
    icon: Icon(Icons.reply),
  );

  // default copy menu item
  static const MenuItem copy = MenuItem(
    label: 'Copy',
    value: 'Copy',
    icon: Icon(Icons.copy),
  );

  // default edit menu item
  static const MenuItem delete = MenuItem(
    label: 'Delete',
    value: 'Delete',
    icon: Icon(Icons.delete_forever),
    isDestuctive: true,
  );
}
