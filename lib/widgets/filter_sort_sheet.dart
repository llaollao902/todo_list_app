import 'package:flutter/material.dart';

import '../utils/constants.dart';

// What the sheet returns when the user taps Apply.
class FilterSortResult {
  final TaskTag? tag;
  final Priority? priority;
  final String sort;

  const FilterSortResult({
    required this.tag,
    required this.priority,
    required this.sort,
  });
}

class FilterSortSheet extends StatefulWidget {
  final TaskTag? tag;
  final Priority? priority;
  final String sort;

  const FilterSortSheet({
    super.key,
    required this.tag,
    required this.priority,
    required this.sort,
  });

  // Returns null if the sheet is dismissed without tapping Apply.
  static Future<FilterSortResult?> show(
    BuildContext context, {
    required TaskTag? tag,
    required Priority? priority,
    required String sort,
  }) {
    return showModalBottomSheet<FilterSortResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterSortSheet(tag: tag, priority: priority, sort: sort),
    );
  }

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late TaskTag? _tag = widget.tag;
  late Priority? _priority = widget.priority;
  late String _sort = widget.sort;

  // Label shown on the chip -> value stored in TaskProvider.selectedSort.
  static const _sortOptions = {
    'Due date': 'Due date',
    'Priority': 'Priority',
    'Newest': 'Date added',
    'Tag': 'Tag',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter and sort',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 20),

            // --- Tag ---
            const _SectionLabel('Tag'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OptionChip(
                  label: 'All',
                  selected: _tag == null,
                  onTap: () => setState(() => _tag = null),
                ),
                ...TaskTag.values.map(
                  (tag) => _OptionChip(
                    label: tag.label,
                    selected: _tag == tag,
                    onTap: () => setState(() => _tag = tag),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // --- Priority ---
            const _SectionLabel('Priority'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OptionChip(
                  label: 'All',
                  selected: _priority == null,
                  onTap: () => setState(() => _priority = null),
                ),
                // High first
                ...Priority.values.reversed.map(
                  (p) => _OptionChip(
                    label: p.label,
                    selected: _priority == p,
                    labelColor: p.color,
                    onTap: () => setState(() => _priority = p),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // --- Sort by ---
            const _SectionLabel('Sort by'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sortOptions.entries
                  .map(
                    (entry) => _OptionChip(
                      label: entry.key,
                      selected: _sort == entry.value,
                      onTap: () => setState(() => _sort = entry.value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            // --- Apply ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  FilterSortResult(
                    tag: _tag,
                    priority: _priority,
                    sort: _sort,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.heading,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.subtext,
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? labelColor; // used by the priority chips

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.heading : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.heading
                : AppColors.subtext.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : (labelColor ?? AppColors.heading),
          ),
        ),
      ),
    );
  }
}