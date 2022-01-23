import 'package:flutter/material.dart';
import 'container_with_ticks.dart';

class TemperatureControl extends StatefulWidget {
  const TemperatureControl({
    Key? key,
    required this.onChange,
    this.min = -10,
    this.max = 35,
  }) : super(key: key);

  final Function(double) onChange;
  final int min;
  final int max;

  @override
  State<TemperatureControl> createState() => TemperatureControlState();
}

class TemperatureControlState extends State<TemperatureControl> {
  final ScrollController _sc = ScrollController();
  int itemCount = 0;
  double itemHeight = 100.0;

  double _currentVal = 0;

  bool _isAnimating = false;

  @override
  void initState() {
    itemCount = (widget.max + 1) - widget.min;
    _currentVal = widget.min.toDouble();

    _sc.addListener(() {
      double _v = _sc.offset / itemHeight;
      _v += widget.min;
      if (!_isAnimating) widget.onChange(_v);
      setState(() {
        _currentVal = _v;
      });
    });

    Future.delayed(Duration.zero).then((value) => widget.onChange(widget.min.toDouble()));
    super.initState();
  }

  updateVal(double val) {
    _isAnimating = true;
    double newVal = (val - widget.min.abs()) * itemHeight;
    _sc.animateTo(newVal, duration: const Duration(milliseconds: 300), curve: Curves.easeInOutQuad).then(
          (value) => _isAnimating = false,
        );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var h = constraints.maxHeight;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              width: 120,
              child: ShaderMask(
                shaderCallback: (Rect rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
                    stops: [0.0, 0.2, 0.8, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstOut,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: ListView.builder(
                    controller: _sc,
                    padding: EdgeInsets.symmetric(vertical: (h / 2) - (itemHeight / 2)),
                    itemCount: itemCount,
                    reverse: true,
                    itemBuilder: (context, index) {
                      int _val = (index + widget.min);
                      double _d = (_currentVal - _val).abs();
                      if (_d > 1) _d = 1;
                      _d = 1 - _d;

                      var _c = Color.fromRGBO((_d * 255).toInt(), 0, 0, 1);

                      return ContainerWithTicks(
                        tickColor: Colors.grey[700]!,
                        height: itemHeight,
                        child: Center(
                          child: Text(
                            "$_val",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _c, fontSize: 14 + (25 * _d)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
