import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

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
  double start;
  double duration;
  String type;
  String? path;
  double volume;
  double speed;
  bool muted;
  VideoPlayerController? controller;

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
    this.controller,
  });
}

class EditorService extends ChangeNotifier {
  final _uuid = const Uuid();

  ToolTab _currentTab = ToolTab.media;
  double _playhead = 0.0;
  double _timelineScale = 1.0;
  bool _isPlaying = false;
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _projectName = 'Untitled';
  final List<TimelineClip> _clips = [];
  String? _selectedClipId;
  VideoPlayerController? _previewController;
  bool _isLoadingMedia = false;
  String? _errorMessage;

  ToolTab get currentTab => _currentTab;
  double get playhead => _playhead;
  double get timelineScale => _timelineScale;
  bool get isPlaying => _isPlaying;
  bool get isExporting => _isExporting;
  double get exportProgress => _exportProgress;
  String get projectName => _projectName;
  List<TimelineClip> get clips => List.unmodifiable(_clips);
  String? get selectedClipId => _selectedClipId;
  VideoPlayerController? get previewController => _previewController;
  bool get isLoadingMedia => _isLoadingMedia;
  String? get errorMessage => _errorMessage;
  bool get hasVideo => _previewController != null && _previewController!.value.isInitialized;

  TimelineClip? get selectedClip {
    if (_selectedClipId == null) return null;
    try {
      return _clips.firstWhere((c) => c.id == _selectedClipId);
    } catch (_) {
      return null;
    }
  }

  double get totalDuration {
    if (_clips.isEmpty) return 10.0;
    return _clips.map((c) => c.start + c.duration).reduce((a, b) => a > b ? a : b).clamp(1.0, 9999.0);
  }

  List<TimelineClip> get videoClips => _clips.where((c) => c.type == 'video').toList();
  List<TimelineClip> get audioClips => _clips.where((c) => c.type == 'audio').toList();
  List<TimelineClip> get textClips => _clips.where((c) => c.type == 'text').toList();

  void setTab(ToolTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void setPlayhead(double value) {
    _playhead = value.clamp(0.0, totalDuration);
    if (_previewController != null && _previewController!.value.isInitialized) {
      _previewController!.seekTo(Duration(milliseconds: (_playhead * 1000).round()));
    }
    notifyListeners();
  }

  void setTimelineScale(double value) {
    _timelineScale = value.clamp(0.3, 4.0);
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (_previewController == null || !_previewController!.value.isInitialized) {
      _isPlaying = false;
      notifyListeners();
      return;
    }
    if (_isPlaying) {
      await _previewController!.pause();
      _isPlaying = false;
    } else {
      await _previewController!.play();
      _isPlaying = true;
      _listenPosition();
    }
    notifyListeners();
  }

  void _listenPosition() {
    _previewController?.addListener(() {
      if (_previewController == null) return;
      if (_previewController!.value.isPlaying) {
        _playhead = _previewController!.value.position.inMilliseconds / 1000.0;
        notifyListeners();
      }
      if (_previewController!.value.position >= _previewController!.value.duration) {
        _isPlaying = false;
        notifyListeners();
      }
    });
  }

  void stop() {
    _isPlaying = false;
    _playhead = 0;
    _previewController?.pause();
    _previewController?.seekTo(Duration.zero);
    notifyListeners();
  }

  void selectClip(String? id) {
    _selectedClipId = id;
    notifyListeners();
  }

  Future<void> importVideo(String filePath, String fileName) async {
    _isLoadingMedia = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _previewController?.dispose();
      _previewController = null;

      final controller = VideoPlayerController.file(File(filePath));
      await controller.initialize();

      final durationSec = controller.value.duration.inMilliseconds / 1000.0;

      double startAt = 0;
      if (videoClips.isNotEmpty) {
        startAt = videoClips.map((c) => c.start + c.duration).reduce((a, b) => a > b ? a : b);
      }

      final clip = TimelineClip(
        id: _uuid.v4(),
        name: fileName.length > 20 ? '${fileName.substring(0, 18)}…' : fileName,
        start: startAt,
        duration: durationSec,
        type: 'video',
        path: filePath,
        controller: controller,
      );

      _clips.add(clip);
      _selectedClipId = clip.id;
      _previewController = controller;
      _playhead = startAt;
      await controller.seekTo(Duration.zero);

      _isLoadingMedia = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMedia = false;
      _errorMessage = 'Не удалось загрузить видео';
      notifyListeners();
    }
  }

  void addTextClip(String text) {
    final clip = TimelineClip(
      id: _uuid.v4(),
      name: text.isEmpty ? 'Text' : (text.length > 12 ? '${text.substring(0, 10)}…' : text),
      start: _playhead,
      duration: 3.0,
      type: 'text',
    );
    _clips.add(clip);
    _selectedClipId = clip.id;
    notifyListeners();
  }

  void removeSelectedClip() {
    if (_selectedClipId == null) return;
    final id = _selectedClipId!;
    TimelineClip? clip;
    for (final c in _clips) {
      if (c.id == id) {
        clip = c;
        break;
      }
    }
    if (clip == null) return;
    clip.controller?.dispose();
    _clips.removeWhere((c) => c.id == id);
    if (_previewController == clip.controller) {
      _previewController = null;
      _isPlaying = false;
    }
    _selectedClipId = null;
    notifyListeners();
  }

  void splitSelectedClip() {
    final clip = selectedClip;
    if (clip == null || clip.type != 'video') return;
    if (_playhead <= clip.start || _playhead >= clip.start + clip.duration) return;

    final leftDuration = _playhead - clip.start;
    final rightDuration = clip.duration - leftDuration;
    clip.duration = leftDuration;

    final right = TimelineClip(
      id: _uuid.v4(),
      name: '${clip.name} (2)',
      start: _playhead,
      duration: rightDuration,
      type: 'video',
      path: clip.path,
    );
    _clips.add(right);
    notifyListeners();
  }

  void setProjectName(String name) {
    _projectName = name;
    notifyListeners();
  }

  Future<void> exportProject() async {
    if (_clips.isEmpty) {
      _errorMessage = 'Нет клипов для экспорта';
      notifyListeners();
      return;
    }
    _isExporting = true;
    _exportProgress = 0;
    notifyListeners();

    for (int i = 1; i <= 12; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      _exportProgress = i / 12.0;
      notifyListeners();
    }

    _isExporting = false;
    _exportProgress = 0;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void loadDemoTimeline() {}

  @override
  void dispose() {
    _previewController?.dispose();
    for (final c in _clips) {
      c.controller?.dispose();
    }
    super.dispose();
  }
}
