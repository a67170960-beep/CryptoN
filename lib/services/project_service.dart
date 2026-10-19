import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class VideoProject {
  final String id;
  String name;
  final DateTime createdAt;
  DateTime updatedAt;
  String? coverPath;
  double duration; // seconds
  int clipCount;
  String resolution; // e.g. 1080p
  bool isDraft;

  VideoProject({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.coverPath,
    this.duration = 0,
    this.clipCount = 0,
    this.resolution = '1080p',
    this.isDraft = true,
  });
}

class ProjectService extends ChangeNotifier {
  final List<VideoProject> _projects = [];
  final _uuid = const Uuid();

  List<VideoProject> get projects => List.unmodifiable(_projects);
  List<VideoProject> get recent => _projects.take(6).toList();

  ProjectService() {
    _loadDemo();
  }

  void _loadDemo() {
    final now = DateTime.now();
    _projects.addAll([
      VideoProject(
        id: _uuid.v4(),
        name: 'Travel Edit 01',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        duration: 48.5,
        clipCount: 12,
        resolution: '1080p',
      ),
      VideoProject(
        id: _uuid.v4(),
        name: 'Cinematic Night',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        duration: 92.0,
        clipCount: 24,
        resolution: '4K',
      ),
      VideoProject(
        id: _uuid.v4(),
        name: 'Product Showcase',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 3)),
        duration: 31.2,
        clipCount: 8,
        resolution: '1080p',
      ),
    ]);
  }

  VideoProject createProject(String name) {
    final now = DateTime.now();
    final project = VideoProject(
      id: _uuid.v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    _projects.insert(0, project);
    notifyListeners();
    return project;
  }

  void renameProject(String id, String newName) {
    final p = _projects.firstWhere((e) => e.id == id);
    p.name = newName;
    p.updatedAt = DateTime.now();
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void touch(String id) {
    final p = _projects.firstWhere((e) => e.id == id);
    p.updatedAt = DateTime.now();
    // move to top
    _projects.remove(p);
    _projects.insert(0, p);
    notifyListeners();
  }
}
