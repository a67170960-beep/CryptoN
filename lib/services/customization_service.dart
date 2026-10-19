import 'package:flutter/material.dart';

class CustomizationService extends ChangeNotifier {
  Color _accentColor = const Color(0xFF7EB8D4);
  double _glassOpacity = 0.11;
  double _glassBlur = 16.0;
  double _borderRadius = 18.0;
  bool _enableAnimations = true;
  bool _enableBlur = true;
  bool _compactTimeline = false;
  bool _showWaveform = true;
  bool _snapToGrid = true;
  double _timelineHeight = 1.0;
  int _previewQuality = 1; // 0 low, 1 med, 2 high
  bool _hapticFeedback = true;
  bool _autoSave = true;
  int _autoSaveInterval = 30; // seconds

  Color get accentColor => _accentColor;
  double get glassOpacity => _glassOpacity;
  double get glassBlur => _glassBlur;
  double get borderRadius => _borderRadius;
  bool get enableAnimations => _enableAnimations;
  bool get enableBlur => _enableBlur;
  bool get compactTimeline => _compactTimeline;
  bool get showWaveform => _showWaveform;
  bool get snapToGrid => _snapToGrid;
  double get timelineHeight => _timelineHeight;
  int get previewQuality => _previewQuality;
  bool get hapticFeedback => _hapticFeedback;
  bool get autoSave => _autoSave;
  int get autoSaveInterval => _autoSaveInterval;

  void setAccentColor(Color c) {
    _accentColor = c;
    notifyListeners();
  }

  void setGlassOpacity(double v) {
    _glassOpacity = v.clamp(0.05, 0.3);
    notifyListeners();
  }

  void setGlassBlur(double v) {
    _glassBlur = v.clamp(6.0, 32.0);
    notifyListeners();
  }

  void setBorderRadius(double v) {
    _borderRadius = v.clamp(8.0, 28.0);
    notifyListeners();
  }

  void setEnableAnimations(bool v) {
    _enableAnimations = v;
    notifyListeners();
  }

  void setEnableBlur(bool v) {
    _enableBlur = v;
    notifyListeners();
  }

  void setCompactTimeline(bool v) {
    _compactTimeline = v;
    notifyListeners();
  }

  void setShowWaveform(bool v) {
    _showWaveform = v;
    notifyListeners();
  }

  void setSnapToGrid(bool v) {
    _snapToGrid = v;
    notifyListeners();
  }

  void setTimelineHeight(double v) {
    _timelineHeight = v.clamp(0.7, 1.5);
    notifyListeners();
  }

  void setPreviewQuality(int v) {
    _previewQuality = v.clamp(0, 2);
    notifyListeners();
  }

  void setHapticFeedback(bool v) {
    _hapticFeedback = v;
    notifyListeners();
  }

  void setAutoSave(bool v) {
    _autoSave = v;
    notifyListeners();
  }

  void setAutoSaveInterval(int v) {
    _autoSaveInterval = v.clamp(10, 120);
    notifyListeners();
  }

  void applyPreset(String name) {
    switch (name) {
      case 'ocean':
        _accentColor = const Color(0xFF7EB8D4);
        _glassOpacity = 0.11;
        break;
      case 'slate':
        _accentColor = const Color(0xFF8BA3B5);
        _glassOpacity = 0.09;
        break;
      case 'deep':
        _accentColor = const Color(0xFF5A8AA8);
        _glassOpacity = 0.13;
        break;
      case 'mist':
        _accentColor = const Color(0xFF9BB8C9);
        _glassOpacity = 0.08;
        break;
    }
    notifyListeners();
  }
}
