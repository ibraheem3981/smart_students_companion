import 'package:flutter/material.dart';

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _CourseGrade {
  String name = '';
  int credits = 1;
  String grade = 'A';
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final List<_CourseGrade> _courses = [_CourseGrade()]; // Start with 1 row

  final Map<String, double> _gradePoints = {
    'A': 5.0,
    'B': 4.0,
    'C': 3.0,
    'D': 2.0,
    'E': 1.0,
    'F': 0.0,
  };

  void _calculateGpa() {
    double totalPoints = 0;
    int totalCredits = 0;

    for (var c in _courses) {
      final points = _gradePoints[c.grade] ?? 0.0;
      totalPoints += points * c.credits;
      totalCredits += c.credits;
    }

    final gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Your GPA', textAlign: TextAlign.center),
          content: Text(
            gpa.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator (5.0)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () {
              setState(() {
                _courses.clear();
                _courses.add(_CourseGrade());
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 16),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return Card(
            key: ObjectKey(course),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Course Name
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Course ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) => course.name = val,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Credits
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      value: course.credits,
                      items: [1, 2, 3, 4, 5, 6].map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit.toString()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => course.credits = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Grade
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        border: OutlineInputBorder(),
                      ),
                      value: course.grade,
                      items: _gradePoints.keys.map((grade) {
                        return DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => course.grade = val);
                        }
                      },
                    ),
                  ),
                  
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      if (_courses.length > 1) {
                        setState(() {
                          _courses.removeAt(index);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_course',
            icon: const Icon(Icons.add),
            label: const Text('Add Row'),
            onPressed: () {
              setState(() {
                _courses.add(_CourseGrade());
              });
            },
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'calc_gpa',
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: _calculateGpa,
          ),
        ],
      ),
    );
  }
}
