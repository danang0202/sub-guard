import 'package:flutter/material.dart';
import 'dart:async';

class DynamicIslandToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const DynamicIslandToast({
    super.key,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.duration,
    required this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_rounded,
    Color iconColor = const Color(0xFF2ECC71),
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => DynamicIslandToast(
        message: message,
        icon: icon,
        iconColor: iconColor,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  State<DynamicIslandToast> createState() => _DynamicIslandToastState();
}

class _DynamicIslandToastState extends State<DynamicIslandToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _contentOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
    );

    // Initial bounce/expand animation
    _widthAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 40,
          end: 120,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 120,
          end: 340,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _heightAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 10,
          end: 35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 35,
          end: 60,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    _contentOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: _widthAnimation.value,
                height: _heightAnimation.value,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Opacity(
                  opacity: _contentOpacityAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: widget.iconColor, size: 24),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            fontFamily: 'Roboto', // Ensure font consistency
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
