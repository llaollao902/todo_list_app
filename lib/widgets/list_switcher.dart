import 'package:flutter/material.dart';

import '../models/task_list.dart';
import '../utils/constants.dart';

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
          _Pill(
            label: 'Personal',
            icon: Icons.person_outline,
            selected: selectedListId == kPersonalListId,
            onTap: () => onSelected(kPersonalListId),
          ),
          ...lists.map(
            (list) => _Pill(
              label: list.name,
              icon: Icons.group_outlined,
              selected: selectedListId == list.id,
              onTap: () => onSelected(list.id),
            ),
          ),
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

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool highlighted; // the "New list" pill uses a softer fill
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