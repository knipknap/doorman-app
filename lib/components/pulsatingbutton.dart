//import 'dart:developer' as developer;
import 'package:flutter/material.dart';

class PulsatingButton extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  PulsatingButton({
    Key? key,
    required this.onTap,
    this.text = "",
    this.pulsating = false,
  }) : super(key: key);

  final String text;
  final Function onTap;
  final bool pulsating;

  @override
  State<PulsatingButton> createState() => _PulsatingButtonState();
}

class _PulsatingButtonState extends State<PulsatingButton> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      lowerBound: .3,
      //upperBound: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //developer.log("BUILD", name: pulsating ? "yes" : "no");

    List<Widget> children = [];
    if (widget.pulsating) {
      children.add(_buildRipples());
      _controller.repeat();
    }
    else {
      _controller.reset();
    }
    children.add(_buildButton(context, 200, widget.text));

    return Stack(alignment: Alignment.center, children: children);
  }

  Widget _buildRipples() {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildCircle(325 * _controller.value, opacity: 1 - _controller.value),
            _buildCircle(350 * _controller.value, opacity: 1 - _controller.value),
            _buildCircle(375 * _controller.value, opacity: 1 - _controller.value),
            _buildCircle(400 * _controller.value, opacity: 1 - _controller.value),
          ],
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, double radius, String text) {
    return GestureDetector(
      onTap: () { widget.onTap(context); },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCircle(200),
          Text(text, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
          //const Align(child: Icon(Icons.phone_android, size: 44,)),
        ],
      ),
    );
  }

  Widget _buildCircle(double radius, {double opacity = 1}) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.indigo.withOpacity(opacity),
      ),
    );
  }
}