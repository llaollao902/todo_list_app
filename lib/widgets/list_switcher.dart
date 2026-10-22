import 'package:flutter/material.dart';

import '../models/task_list.dart';
import '../utils/constants.dart';

// Displays available task lists and allows the user to switch between them.
class ListSwitcher extends StatelessWidget {
  final List<TaskList> lists;
  final String selectedListId;
  final ValueChanged<String> onSelected;
  final VoidCallback onNewList;

  const ListSwitcher({
    super.key,
    required this.lists,
    required this.selectedListId,
    required this.onSelected,
    required this.onNewList,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Personal is a built-in list, separate from user-created lists.
          _Pill(
            label: 'Personal',
            icon: Icons.person_outline,
            selected: selectedListId == kPersonalListId,
            onTap: () => onSelected(kPersonalListId),
          ),

          // Display each custom list and highlight the currently selected one.
          ...lists.map(
            (list) => _Pill(
              label: list.name,
              icon: Icons.group_outlined,
              selected: selectedListId == list.id,
              onTap: () => onSelected(list.id),
            ),
          ),

          // Opens the flow for creating a new list.
          _Pill(
            label: 'New list',
            icon: Icons.add,
            selected: false,
            highlighted: true,
            onTap: onNewList,
          ),
        ],
      ),
    );
  }
}

// Reusable pill-shaped button for selecting a list or creating a new one.
class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Selected pills use the heading color; the new-list pill has a softer fill.
    final background = selected
        ? AppColors.heading
        : highlighted
            ? AppColors.tagBadgeBg
            : AppColors.cardBackground;

    final foreground = selected
        ? Colors.white
        : highlighted
            ? AppColors.tagBadgeText
            : AppColors.heading;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 6),
              // Prevents long list names from overflowing the pill.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}