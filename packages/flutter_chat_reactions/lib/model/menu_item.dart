import 'package:flutter/widgets.dart';

class MenuItem {
  final String label;
  final String value;
  final Widget icon;
  final bool isDestuctive;

  // contsructor
  const MenuItem({
    required this.label,
    required this.icon,
    required this.value,
    this.isDestuctive = false,
  });
}
