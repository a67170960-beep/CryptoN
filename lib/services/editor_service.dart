import 'package:flutter/foundation.dart';

enum ToolTab {
  media,
  audio,
  text,
  stickers,
  effects,
  filters,
  transition,
  adjust,
  speed,
  animation,
  canvas,
  export,
}

class TimelineClip {
  final String id;
  String name;
  double start; // seconds on timeline
  double duration;
  String type; // video / audio / text / sticker / effect
  String? path;
  double volume;
  double speed;
  bool muted;
  Map<String, dynamic> properties;

  TimelineClip({
    required this.id,
    required this.name,
    required this.start,
    required this.duration,
    required this.type,
    this.path,
    this.volume = 1.0,
    this.speed = 1.0,
    this.muted = false,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};
}

class EditorService extends ChangeNotifier {
  ToolTab _currentTab = ToolTab.media;
  double _playhead = 0.0;
  double _timelineScale = 1.0;
  bool _isPlaying = false;
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _projectName = 'Untitled';
  final List<TimelineClip> _clips = [];
  String? _selectedClipId;

  // Getters
  ToolTab get currentTab => _currentTab;
  double get playhead => _playhead;
  double get timelineScale => _timelineScale;
  bool get isPlaying => _isPlaying;
  bool get isExporting => _isExporting;
  double get exportProgress => _exportProgress;
  String get projectName => _projectName;
  List<TimelineClip> get clips => List.unmodifiable(_clips);
  String? get selectedClipId => _selectedClipId;

  TimelineClip? get selectedClip {
    if (_selectedClipId == null) return null;
    try {
      return _clips.firstWhere((c) => c.id == _selectedClipId);
    } catch (_) {
      return null;
    }
  }

  double get totalDuration {
    if (_clips.isEmpty) return 30.0;
    return _clips.map((c) => c.start + c.duration).reduce((a, b) => a > b ? a : b);
  }

  void setTab(ToolTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void setPlayhead(double value) {
    _playhead = value.clamp(0.0, totalDuration);
    notifyListeners();
  }

  void setTimelineScale(double value) {
    _timelineScale = value.clamp(0.3, 4.0);
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _playhead = 0;
    notifyListeners();
  }

  void selectClip(String? id) {
    _selectedClipId = id;
    notifyListeners();
  }

  void addClip(TimelineClip clip) {
    _clips.add(clip);
    _selectedClipId = clip.id;
    notifyListeners();
  }

  void removeClip(String id) {
    _clips.removeWhere((c) => c.id == id);
    if (_selectedClipId == id) _selectedClipId = null;
    notifyListeners();
  }

  void updateClip(String id, {double? start, double? duration, double? volume, double? speed}) {
    final clip = _clips.firstWhere((c) => c.id == id);
    if (start != null) clip.start = start;
    if (duration != null) clip.duration = duration;
    if (volume != null) clip.volume = volume;
    if (speed != null) clip.speed = speed;
    notifyListeners();
  }

  void setProjectName(String name) {
    _projectName = name;
    notifyListeners();
  }

  Future<void> exportProject() async {
    _isExporting = true;
    _exportProgress = 0;
    notifyListeners();

    // Simulate export progress
    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      _exportProgress = i / 20;
      notifyListeners();
    }

    _isExporting = false;
    _exportProgress = 0;
    notifyListeners();
  }

  // Demo clips for first open
  void loadDemoTimeline() {
    if (_clips.isNotEmpty) return;
    _clips.addAll([
      TimelineClip(
        id: 'c1',
        name: 'Clip 1',
        start: 0,
        duration: 5.2,
        type: 'video',
      ),
      TimelineClip(
        id: 'c2',
        name: 'Clip 2',
        start: 5.2,
        duration: 4.8,
        type: 'video',
      ),
      TimelineClip(
        id: 'a1',
        name: 'Music',
        start: 0,
        duration: 15,
        type: 'audio',
        volume: 0.7,
      ),
      TimelineClip(
        id: 't1',
        name: 'Title',
        start: 1.0,
        duration: 3.0,
        type: 'text',
      ),
    ]);
    notifyListeners();
  }
}
