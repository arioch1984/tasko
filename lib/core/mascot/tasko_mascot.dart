import 'package:flutter/material.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';

/// Reusable Tasko the badger mascot with optional message.
class TaskoMascot extends StatelessWidget {
  const TaskoMascot({
    super.key,
    this.pose = TaskoPose.idle,
    this.size = 160,
    this.message,
  });

  final TaskoPose pose;
  final double size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: Image.asset(
            pose.assetPath,
            key: ValueKey(pose),
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
