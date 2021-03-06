import 'package:flutter/material.dart';
import 'package:doorman/components/bezier_container.dart';

class LoadScreen extends StatefulWidget {
  const LoadScreen({
    Key? key,
    this.title,
    this.status,
  }) : super(key: key);

  final String? title;
  final String? status;

  @override
  _LoadScreenState createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      lowerBound: 0,
      upperBound: 10,
      vsync: this,
    );

    _controller.addStatusListener((status) {
      setState(() {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: widget.title ?? "Loading...",
        style: TextStyle(
          shadows: <Shadow>[
            Shadow(
              offset: Offset(0.0, 0.0),
              blurRadius: 1.0+10*_controller.value,
              color: Colors.indigo, //Color.fromARGB(255, 0, 0, 0),
            ),
          ],
          fontSize: 30+.2*_controller.value,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return _buildTitle();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()
            ),
            Center(
              child: _buildAnimatedTitle(),
            ),
            Column(
              children: [
                Expanded(child: Container(), flex: 50),
                Expanded(
                  child: Text(
                    widget.status ?? "",
                    style: TextStyle(fontSize: 12),
                  ),
                  flex: 1),
              ],
            )
          ],
        ),
      )
    );
  }
}