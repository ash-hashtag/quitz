import 'package:flutter/material.dart';

class System {
  static showSnackBar(final String text, BuildContext context,
      {void Function()? onTap}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
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

  static final ErrorWidget = Scaffold(
    backgroundColor: Colors.purple,
    body: Center(
        child: RichText(
            text: const TextSpan(children: [
      TextSpan(
        text: 'ERROR',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]))),
  );
}
