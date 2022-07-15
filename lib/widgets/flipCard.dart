import 'dart:math';

import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  const FlipCard(
      {Key? key,
      required this.front,
      required this.back,
      this.duration = const Duration(milliseconds: 500)})
      : super(key: key);

  @override
  State<FlipCard> createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard> {
  double angle = 0;
  bool flipped = true;
  void flip() => setState(() => angle = (angle + pi) % (2 * pi));

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: angle),
      duration: widget.duration,
      builder: (_, double val, __) {
        flipped = (val < pi / 2);
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(val),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: flipped
                ? Card(child: widget.front)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: Card(child: widget.back),
                  ),
          ),
        );
      },
    );
  }
}
