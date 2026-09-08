import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/filter_sort_bar.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  TaskTag? _selectedTagFilter;
  Priority? _selectedPriorityFilter;
  String _selectedSortOption = 'Date added';

  void _onTagChanged(TaskTag? tag) {
    setState(() => _selectedTagFilter = tag);
  }

  void _onPriorityChanged(Priority? priority) {
    setState(() => _selectedPriorityFilter = priority);
  }

  void _onSortChanged(String? sortOption) {
    setState(() => _selectedSortOption = sortOption ?? 'Date added');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Pinned sticky header section for better scrolling ergonomics
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
            
                  const SizedBox(height: 15),
                  FilterSortBar(
                    selectedTag: _selectedTagFilter,
                    selectedPriority: _selectedPriorityFilter,
                    selectedSort: _selectedSortOption,
                    onTagChanged: _onTagChanged,
                    onPriorityChanged: _onPriorityChanged,
                    onSortChanged: _onSortChanged,
                  ),
                ],
              ),
            ),
            
            // Scrollable task area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: const [
                  // Task items will render here seamlessly without scrolling the whole header away
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final today = MaterialLocalizations.of(context)
        .formatFullDate(DateTime.now())
        .toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          today,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                color: AppColors.subtext,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "What's Brewing?",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
                color: AppColors.heading,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          'Here are your tasks for today',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.subtext,
              ),
        ),
      ],
    );
  }
}