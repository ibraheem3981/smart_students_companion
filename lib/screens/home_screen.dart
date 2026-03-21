import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/student_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final today = DateTime.now();

    final todaysClasses = provider.courses.where((c) => c.dayOfWeek == today.weekday).toList()
      ..sort((a, b) => a.time.hour.compareTo(b.time.hour) != 0
          ? a.time.hour.compareTo(b.time.hour)
          : a.time.minute.compareTo(b.time.minute));

    final upcomingAssignments = provider.assignments
        .where((a) => !a.isCompleted && a.dueDate.isAfter(today.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Summary
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Classes Today',
                    count: todaysClasses.length.toString(),
                    icon: Icons.class_,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: 'Pending Tasks',
                    count: upcomingAssignments.length.toString(),
                    icon: Icons.assignment_late,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Today's Classes
            Text('Today\'s Classes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (todaysClasses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No classes today!', style: TextStyle(color: Colors.grey)),
              )
            else
              ...todaysClasses.map((c) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.school),
                      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(DateFormat.jm().format(c.time)),
                    ),
                  )),

            const SizedBox(height: 24),

            // Upcoming Assignments
            Text('Upcoming Assignments', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (upcomingAssignments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No upcoming assignments!', style: TextStyle(color: Colors.grey)),
              )
            else
              ...upcomingAssignments.take(3).map((a) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.assignment),
                      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Due: ${DateFormat.yMMMd().format(a.dueDate)}'),
                      trailing: a.dueDate.isBefore(today)
                          ? const Text('Overdue!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                          : null,
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(count, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
