import 'package:flutter/widgets.dart';

class DpiAdjuster extends StatelessWidget {
  const DpiAdjuster({
    Key? key,
    required this.child,
    required this.newDevicePixelRatio,
  }) : super(key: key);

  final Widget child;
  final double newDevicePixelRatio;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    var ratio = newDevicePixelRatio / mq.devicePixelRatio;

    return FractionallySizedBox(
      widthFactor: 1 / ratio,
      heightFactor: 1 / ratio,
      child: Transform.scale(
          scale: ratio,
          child: MediaQuery(
              data: mq.copyWith(
                  size: mq.size / ratio,
                  devicePixelRatio: ratio,
                  viewInsets: mq.viewInsets.copyWith(
                    bottom: mq.viewInsets.bottom / ratio,
                  )),
              child: child)),
    );
  }
}
