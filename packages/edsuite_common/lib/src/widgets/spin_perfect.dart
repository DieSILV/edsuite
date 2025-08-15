import 'package:flutter/material.dart';

class SpinPerfect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool infinite;
  const SpinPerfect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.infinite = false,
  });

  @override
  State<SpinPerfect> createState() => _SpinPerfectState();
}

class _SpinPerfectState extends State<SpinPerfect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spin;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _spin = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.infinite) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _spin.value * 3.1415926535897932,
          child: widget.child,
        );
      },
    );
  }
}
