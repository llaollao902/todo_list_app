import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'dropdown.dart';

// Groups the three filter/sort dropdowns into a single row widget.
class FilterSortBar extends StatelessWidget {
  final TaskTag? selectedTag;
  final Priority? selectedPriority;
  final String selectedSort;
  final ValueChanged<TaskTag?> onTagChanged;
  final ValueChanged<Priority?> onPriorityChanged;
  final ValueChanged<String?> onSortChanged;

  const FilterSortBar({
    super.key,
    required this.selectedTag,
    required this.selectedPriority,
    required this.selectedSort,
    required this.onTagChanged,
    required this.onPriorityChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TAG filter
        Expanded(
          child: PillDropdown<TaskTag?>(
            hint: 'All tags',
            value: selectedTag,
            items: [
              const DropdownMenuItem(value: null, child: Text('All tags')),
              ...TaskTag.values.map(
                (tag) => DropdownMenuItem(value: tag, child: Text(tag.label)),
              ),
            ],
            onChanged: onTagChanged,
          ),
        ),
        const SizedBox(width: 8),

        // PRIORITY filter
        Expanded(
          child: PillDropdown<Priority?>(
            hint: 'All priorities',
            value: selectedPriority,
            items: [
              const DropdownMenuItem(value: null, child: Text('All priorities')),
              ...Priority.values.map(
                (p) => DropdownMenuItem(value: p, child: Text(p.label)),
              ),
            ],
            onChanged: onPriorityChanged,
          ),
        ),
        const SizedBox(width: 8),

        // SORT dropdown
        Expanded(
          child: PillDropdown<String>(
            hint: 'Date added',
            value: selectedSort,
            items: const [
              DropdownMenuItem(value: 'Date added', child: Text('Date added')),
              DropdownMenuItem(value: 'Due date', child: Text('Due date')),
              DropdownMenuItem(value: 'Priority', child: Text('Priority')),
              DropdownMenuItem(value: 'Tag', child: Text('Tag')),
            ],
            onChanged: onSortChanged,
          ),
        ),
      ],
    );
  }
}