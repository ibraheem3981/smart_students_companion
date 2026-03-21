import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/assignment.dart';

class StorageService {
  static const String _coursesKey = 'courses_v1';
  static const String _assignmentsKey = 'assignments_v1';
  static const String _studyTimeKey = 'study_time_seconds';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveCourses(List<Course> courses) async {
    final List<String> jsonList = courses.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_coursesKey, jsonList);
  }

  List<Course> getCourses() {
    final List<String>? jsonList = _prefs.getStringList(_coursesKey);
    if (jsonList == null) return [];
    
    return jsonList.map((str) => Course.fromJson(jsonDecode(str))).toList();
  }

  Future<void> saveAssignments(List<Assignment> assignments) async {
    final List<String> jsonList = assignments.map((a) => jsonEncode(a.toJson())).toList();
    await _prefs.setStringList(_assignmentsKey, jsonList);
  }

  List<Assignment> getAssignments() {
    final List<String>? jsonList = _prefs.getStringList(_assignmentsKey);
    if (jsonList == null) return [];
    
    return jsonList.map((str) => Assignment.fromJson(jsonDecode(str))).toList();
  }

  Future<void> saveStudyTime(int seconds) async {
    await _prefs.setInt(_studyTimeKey, seconds);
  }

  int getStudyTime() {
    return _prefs.getInt(_studyTimeKey) ?? 0;
  }
}
