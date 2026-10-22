import 'package:flutter/material.dart';

import '../models/task_list.dart';
import '../utils/constants.dart';

// Compact row: a dropdown pill showing the current list (tap to switch)
// and a dashed "+ New list" pill.
class ListSwitcher extends StatefulWidget {
  final List<TaskList> lists;
  final String selectedListId;
  final Map<String, int> taskCounts; // list id -> task count
  final ValueChanged<String> onSelected;
  final VoidCallback onNewList;

  // null = hide the button (not the owner / Personal)
  final VoidCallback? onAddMember; 

  const ListSwitcher({
    super.key,
    required this.lists,
    required this.selectedListId,
    required this.taskCounts,
    required this.onSelected,
    required this.onNewList,
    this.onAddMember,
  });

  @override
  State<ListSwitcher> createState() => _ListSwitcherState();
}

class _ListSwitcherState extends State<ListSwitcher> {
  // True while the dropdown menu is showing, so the arrow can point up.
  bool _menuOpen = false;

  String get _currentLabel {
    if (widget.selectedListId == kPersonalListId) return 'Personal';
    for (final list in widget.lists) {
      if (list.id == widget.selectedListId) return list.name;
    }
    return 'Personal';
  }

  String _countLabel(int count) => count == 1 ? '1 task' : '$count tasks';

    PopupMenuItem<String> _menuItem(String id, String label) {
    final selected = id == widget.selectedListId;
    final count = widget.taskCounts[id] ?? 0;
    return PopupMenuItem<String>(
      value: id,
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.heading,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _countLabel(count),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.tagBadgeText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // --- Dropdown pill ---
        Flexible(
          child: PopupMenuButton<String>(
            onOpened: () => setState(() => _menuOpen = true),
            onCanceled: () => setState(() => _menuOpen = false),
            onSelected: (id) {
              setState(() => _menuOpen = false);
              widget.onSelected(id);
            },
            position: PopupMenuPosition.under,
            offset: const Offset(0, 6),
            constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
            color: AppColors.cardBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (_) => [
              _menuItem(kPersonalListId, 'Personal'),
              ...widget.lists.map((list) => _menuItem(list.id, list.name)),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.heading,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _currentLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _menuOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // --- Dashed "+ New list" pill ---
        GestureDetector(
          onTap: widget.onNewList,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: AppColors.subtext,
              radius: 20,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14, color: AppColors.heading),
                  SizedBox(width: 4),
                  Text(
                    'New list',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.onAddMember != null) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'Add member',
            child: GestureDetector(
              onTap: widget.onAddMember,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.tagBadgeBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.tagBadgeText),
                ),
                child: const Icon(
                  Icons.person_add_alt_1,
                  size: 16,
                  color: AppColors.heading,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Draws a rounded dashed outline around its child.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    const dashLength = 5.0;
    const gapLength = 3.5;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}