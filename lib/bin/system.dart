import 'package:flutter/material.dart';

class System {
  static showSnackBar(final String text, BuildContext _,
      {void Function()? onTap}) {
    ScaffoldMessenger.of(_).showSnackBar(
      SnackBar(
        content: Text(text),
        action: onTap != null
            ? SnackBarAction(
                label: 'onTap',
                onPressed: onTap,
              )
            : null,
      ),
    );
  }
}
