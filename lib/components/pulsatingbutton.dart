//import 'dart:developer' as developer;
import 'package:flutter/material.dart';

class PulsatingButton extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  PulsatingButton({
    Key? key,
    required this.onTap,
    required this.radius,
    this.text = "",
    this.pulsating = false,
  }) : super(key: key);

  final String text;
  final Function onTap;
  final bool pulsating;
  final double radius;

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
    children.add(_buildButton(context, widget.radius, widget.text));

    return Stack(alignment: Alignment.center, children: children);
  }

  Widget _buildRipples() {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildCircle(widget.radius*1.1*_controller.value, opacity: 1-_controller.value),
            _buildCircle(widget.radius*1.3*_controller.value, opacity: 1-_controller.value),
            _buildCircle(widget.radius*1.5*_controller.value, opacity: 1-_controller.value),
            _buildCircle(widget.radius*1.7*_controller.value, opacity: 1-_controller.value),
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
          _buildCircle(radius),
          Text(text, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
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
        color: Theme.of(context).colorScheme.secondary.withOpacity(opacity),
      ),
    );
  }
}