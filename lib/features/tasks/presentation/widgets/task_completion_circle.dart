import 'package:flutter/material.dart';

class TaskCompletionCircle extends StatelessWidget {
  const TaskCompletionCircle({
    super.key,
    required this.completed,
    required this.onTap,
    this.categoryEmoji,
  });

  final bool completed;
  final VoidCallback onTap;
  final String? categoryEmoji;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 26,
        height: 30,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.6),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: completed
                  ? const Icon(
                      Icons.check,
                      key: ValueKey('checked'),
                      size: 14,
                      color: Colors.white,
                    )
                  : categoryEmoji != null && categoryEmoji!.isNotEmpty
                  ? Text(
                      categoryEmoji!,
                      key: const ValueKey('emoji'),
                      style: const TextStyle(fontSize: 15, height: 1),
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox(key: ValueKey('unchecked')),
            ),
          ),
        ),
      ),
    );
  }
}
