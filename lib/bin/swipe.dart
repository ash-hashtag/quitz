import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwipeProvider extends ChangeNotifier {
  Offset _position = Offset.zero;
  bool isDragging = false;

  Offset get position => _position;

  void startPosition(DragStartDetails details) {
    isDragging = true;
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    notifyListeners();
  }

  void endPosition() {
    resetPosition();
  }

  void resetPosition() {
    isDragging = false;
    _position = Offset.zero;

    notifyListeners();
  }
}

class SwipeableWidget extends StatelessWidget {
  final Widget child;
  const SwipeableWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart:
          Provider.of<SwipeProvider>(context, listen: false).startPosition,
      onPanUpdate:
          Provider.of<SwipeProvider>(context, listen: false).updatePosition,
      onPanEnd: (_) =>
          Provider.of<SwipeProvider>(context, listen: false).endPosition(),
      child: Builder(
        builder: (context) {
          final provider = Provider.of<SwipeProvider>(
            context,
          );
          final position = provider.position;
          final milliseconds = provider.isDragging ? 0 : 400;
          return AnimatedContainer(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: milliseconds),
            transform: Matrix4.identity()..translate(position.dx, position.dy),
            child: child,
          );
        },
      ),
    );
  }
}
