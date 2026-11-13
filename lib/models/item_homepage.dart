import 'package:flutter/material.dart';

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  /// Extra action to run after the card shows its SnackBar, such as opening
  /// another page. Cards without an action only show the SnackBar.
  final void Function(BuildContext context)? onTap;

  const ItemHomepage(this.name, this.icon, this.color, {this.onTap});
}
