import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class StudentProvider with ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;

  List<Course> _courses = [];
  List<Assignment> _assignments = [];
  int _studyTimeSeconds = 0;

  StudentProvider(this._storageService, this._notificationService);

  List<Course> get courses => _courses;
  List<Assignment> get assignments => _assignments;
  int get studyTimeSeconds => _studyTimeSeconds;

  Future<void> loadData() async {
    _courses = _storageService.getCourses();
    _assignments = _storageService.getAssignments();
    _studyTimeSeconds = _storageService.getStudyTime();
    notifyListeners();
  }

  // ==== Courses ====
  Future<void> addCourse(Course course) async {
    _courses.add(course);
    await _storageService.saveCourses(_courses);
    await _notificationService.scheduleClassReminder(course);
    notifyListeners();
  }

  Future<void> updateCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      await _storageService.saveCourses(_courses);
      await _notificationService.cancelReminder(course.id.hashCode);
      await _notificationService.scheduleClassReminder(course);
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String id) async {
    _courses.removeWhere((c) => c.id == id);
    await _storageService.saveCourses(_courses);
    await _notificationService.cancelReminder(id.hashCode);
    notifyListeners();
  }

  // ==== Assignments ====
  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    await _storageService.saveAssignments(_assignments);
    await _notificationService.scheduleAssignmentReminder(assignment);
    notifyListeners();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = assignment;
      await _storageService.saveAssignments(_assignments);
      await _notificationService.cancelReminder(assignment.id.hashCode);
      // Only schedule if not completed
      if (!assignment.isCompleted) {
        await _notificationService.scheduleAssignmentReminder(assignment);
      }
      notifyListeners();
    }
  }

  Future<void> deleteAssignment(String id) async {
    _assignments.removeWhere((a) => a.id == id);
    await _storageService.saveAssignments(_assignments);
    await _notificationService.cancelReminder(id.hashCode);
    notifyListeners();
  }

  Future<void> toggleAssignmentComplete(String id) async {
    final assignment = _assignments.firstWhere((a) => a.id == id);
    await updateAssignment(assignment.copyWith(isCompleted: !assignment.isCompleted));
  }

  Future<void> addStudyTime(int seconds) async {
    _studyTimeSeconds += seconds;
    await _storageService.saveStudyTime(_studyTimeSeconds);
    notifyListeners();
  }
}
