import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  Widget build(BuildContext context) {
    final today = MaterialLocalizations.of(context)
      .formatFullDate(DateTime.now())
      .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                today,
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: AppColors.subtext,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'What\'s Brewing?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia', 
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Here are your tasks for today',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subtext,
                ),
              ),
              const SizedBox(height: 20),
              // Search bar and filters go here next
            ],
          ),
        ),
      ),
    );
  }
}