import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/student_provider.dart';
import '../models/course.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  final List<String> _days = const [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final courses = provider.courses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      body: courses.isEmpty
          ? const Center(
              child: Text(
                'No courses added yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayOfWeek = index + 1;
                final dayCourses = courses.where((c) => c.dayOfWeek == dayOfWeek).toList()
                  ..sort((a, b) => a.time.hour.compareTo(b.time.hour) != 0
                      ? a.time.hour.compareTo(b.time.hour)
                      : a.time.minute.compareTo(b.time.minute));

                if (dayCourses.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        _days[index],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    ...dayCourses.map((c) => ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.class_)),
                          title: Text(c.name),
                          subtitle: Text(DateFormat.jm().format(c.time)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              provider.deleteCourse(c.id);
                            },
                          ),
                        )),
                    const Divider(),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedDay = 1;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Course'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Course Name'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedDay,
                    decoration: const InputDecoration(labelText: 'Day of Week'),
                    items: List.generate(7, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_days[index]),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedDay = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Time'),
                    trailing: Text(selectedTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    
                    final now = DateTime.now();
                    final time = DateTime(
                      now.year, now.month, now.day,
                      selectedTime.hour, selectedTime.minute,
                    );
                    
                    final course = Course(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      dayOfWeek: selectedDay,
                      time: time,
                    );
                    
                    context.read<StudentProvider>().addCourse(course);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
