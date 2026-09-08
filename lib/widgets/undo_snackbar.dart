import 'dart:async';
import 'package:flutter/material.dart';

// A custom "toast" for "task deleted, tap Undo" 
class UndoSnackbarContent extends StatelessWidget {
  final String message;
  final VoidCallback onUndo;
  final VoidCallback onDelete;
  final Duration duration;

  const UndoSnackbarContent({
    super.key,
    required this.message,
    required this.onUndo,
    required this.onDelete,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF463A35),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red.withValues(alpha: 0.18),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onUndo,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF5C4B43),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Undo', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 0.0),
              duration: duration,
              curve: Curves.linear,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE0A64B)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UndoSnackbar {
  // Tracks the currently visible overlay, if any, so a second delete
  // can remove the first one instead of stacking on top of it.
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    required VoidCallback onDelete,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Remove any existing toast + cancel its pending auto-dismiss
    // before showing a new one (handles rapid consecutive deletes).
    _removeCurrent();

    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 20,
        right: 20,
        // Same 16px bottom inset Scaffold gives the FAB by default —
        // this is what makes it visually sit at the FAB's level,
        // directly over it, instead of being pushed above it.
        bottom: 16,
        child: Material(
          // Material with transparent color is needed here because
          // Overlay widgets sit outside the normal widget tree's
          // Material ancestor — without this, things like the
          // TextButton's ink ripple wouldn't render correctly.
          color: Colors.transparent,
          child: UndoSnackbarContent(
            message: message,
            duration: duration,
            onUndo: () {
              onUndo();
              _removeCurrent();
            },
            onDelete: () {
              onDelete();
              _removeCurrent();
            },
          ),
        ),
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    // Auto-remove after `duration`, matching the countdown bar
    // animation's own length so they finish at the same moment.
    _dismissTimer = Timer(duration, _removeCurrent);
  }

  static void _removeCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}