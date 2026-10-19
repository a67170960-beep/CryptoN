import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/liquid_glass.dart';
import '../services/customization_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<CustomizationService>(
        builder: (context, custom, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              _section('Appearance'),
              _slider('Glass Opacity', custom.glassOpacity, 0.05, 0.3, custom.setGlassOpacity),
              _slider('Glass Blur', custom.glassBlur, 6, 32, custom.setGlassBlur),
              _slider('Border Radius', custom.borderRadius, 8, 28, custom.setBorderRadius),
              _switch('Enable Blur', custom.enableBlur, custom.setEnableBlur),
              _switch('Animations', custom.enableAnimations, custom.setEnableAnimations),

              const SizedBox(height: 12),
              _section('Accent Presets'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _preset('Ocean', () => custom.applyPreset('ocean')),
                  _preset('Slate', () => custom.applyPreset('slate')),
                  _preset('Deep', () => custom.applyPreset('deep')),
                  _preset('Mist', () => custom.applyPreset('mist')),
                ],
              ),

              const SizedBox(height: 20),
              _section('Editor'),
              _switch('Compact Timeline', custom.compactTimeline, custom.setCompactTimeline),
              _switch('Show Waveform', custom.showWaveform, custom.setShowWaveform),
              _switch('Snap to Grid', custom.snapToGrid, custom.setSnapToGrid),
              _slider('Timeline Height', custom.timelineHeight, 0.7, 1.5, custom.setTimelineHeight),
              _switch('Haptic Feedback', custom.hapticFeedback, custom.setHapticFeedback),
              _switch('Auto Save', custom.autoSave, custom.setAutoSave),

              const SizedBox(height: 20),
              _section('Export Quality'),
              Row(
                children: [
                  _qualityChip('Low', 0, custom.previewQuality, custom.setPreviewQuality),
                  _qualityChip('Medium', 1, custom.previewQuality, custom.setPreviewQuality),
                  _qualityChip('High', 2, custom.previewQuality, custom.setPreviewQuality),
                ],
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'CryptoN Video Editor v1.0.0\n200+ features architecture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _slider(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return LiquidGlass(
      borderRadius: 12,
      opacity: 0.07,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
              Text(value.toStringAsFixed(2), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _switch(String title, bool value, ValueChanged<bool> onChanged) {
    return LiquidGlass(
      borderRadius: 12,
      opacity: 0.07,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.accent,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  Widget _preset(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        borderRadius: 10,
        opacity: 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
      ),
    );
  }

  Widget _qualityChip(String label, int value, int current, ValueChanged<int> onSelect) {
    final selected = value == current;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? AppTheme.accent.withOpacity(0.25) : AppTheme.surfaceLight.withOpacity(0.4),
            border: Border.all(
              color: selected ? AppTheme.accent.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppTheme.accent : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
