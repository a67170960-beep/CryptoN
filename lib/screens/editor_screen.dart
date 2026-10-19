import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/liquid_glass.dart';
import '../services/editor_service.dart';

class EditorScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const EditorScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editor = context.read<EditorService>();
      editor.setProjectName(widget.projectName);
      editor.loadDemoTimeline();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _TopBar(projectName: widget.projectName),

            // Preview area
            Expanded(
              flex: 5,
              child: _PreviewArea(),
            ),

            // Timeline
            Expanded(
              flex: 3,
              child: _TimelineArea(),
            ),

            // Tools
            _ToolsBar(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String projectName;
  const _TopBar({required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              projectName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Consumer<EditorService>(
            builder: (context, editor, _) {
              if (editor.isExporting) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: editor.exportProgress,
                      strokeWidth: 2.5,
                      color: AppTheme.accent,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          TextButton(
            onPressed: () {
              context.read<EditorService>().exportProject().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export completed')),
                );
              });
            },
            child: const Text(
              'Export',
              style: TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: LiquidGlass(
        borderRadius: 16,
        opacity: 0.07,
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.play_circle_outline_rounded,
                size: 64,
                color: Colors.white38,
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Consumer<EditorService>(
                  builder: (context, editor, _) {
                    return Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            editor.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          onPressed: editor.togglePlay,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2.5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: editor.playhead.clamp(0, editor.totalDuration),
                              max: editor.totalDuration,
                              onChanged: editor.setPlayhead,
                              activeColor: AppTheme.accent,
                              inactiveColor: Colors.white24,
                            ),
                          ),
                        ),
                        Text(
                          _fmt(editor.playhead),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double sec) {
    final m = (sec / 60).floor();
    final s = (sec % 60).floor();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _TimelineArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EditorService>(
      builder: (context, editor, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // Timeline header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      'Timeline',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.zoom_out_rounded, size: 20),
                      color: AppTheme.textSecondary,
                      onPressed: () => editor.setTimelineScale(editor.timelineScale - 0.2),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in_rounded, size: 20),
                      color: AppTheme.textSecondary,
                      onPressed: () => editor.setTimelineScale(editor.timelineScale + 0.2),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              // Tracks
              Expanded(
                child: ListView(
                  children: [
                    _Track(
                      label: 'V1',
                      clips: editor.clips.where((c) => c.type == 'video').toList(),
                      color: const Color(0xFF4A7C9B),
                    ),
                    _Track(
                      label: 'A1',
                      clips: editor.clips.where((c) => c.type == 'audio').toList(),
                      color: const Color(0xFF5C9B7A),
                    ),
                    _Track(
                      label: 'T1',
                      clips: editor.clips.where((c) => c.type == 'text').toList(),
                      color: const Color(0xFF8B7C9B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Track extends StatelessWidget {
  final String label;
  final List<TimelineClip> clips;
  final Color color;

  const _Track({
    required this.label,
    required this.clips,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.surface.withOpacity(0.6),
              ),
              child: Stack(
                children: clips.map((clip) {
                  final left = clip.start * 18.0; // simple scale
                  final width = clip.duration * 18.0;
                  return Positioned(
                    left: left,
                    top: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onTap: () => context.read<EditorService>().selectClip(clip.id),
                      child: Container(
                        width: width.clamp(30, 400),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: color.withOpacity(0.75),
                          border: Border.all(
                            color: context.watch<EditorService>().selectedClipId == clip.id
                                ? Colors.white
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          clip.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tools = [
      (ToolTab.media, Icons.video_library_rounded, 'Media'),
      (ToolTab.audio, Icons.audiotrack_rounded, 'Audio'),
      (ToolTab.text, Icons.text_fields_rounded, 'Text'),
      (ToolTab.stickers, Icons.emoji_emotions_rounded, 'Stickers'),
      (ToolTab.effects, Icons.auto_awesome_rounded, 'Effects'),
      (ToolTab.filters, Icons.photo_filter_rounded, 'Filters'),
      (ToolTab.transition, Icons.animation_rounded, 'Transition'),
      (ToolTab.adjust, Icons.tune_rounded, 'Adjust'),
      (ToolTab.speed, Icons.speed_rounded, 'Speed'),
      (ToolTab.animation, Icons.movie_filter_rounded, 'Anim'),
      (ToolTab.canvas, Icons.crop_rounded, 'Canvas'),
      (ToolTab.export, Icons.ios_share_rounded, 'Export'),
    ];

    return Consumer<EditorService>(
      builder: (context, editor, _) {
        return Container(
          height: 78,
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.95),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final t = tools[index];
              final selected = editor.currentTab == t.$1;
              return GestureDetector(
                onTap: () => editor.setTab(t.$1),
                child: Container(
                  width: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: selected ? AppTheme.accent.withOpacity(0.2) : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        t.$2,
                        size: 22,
                        color: selected ? AppTheme.accent : AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.$3,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected ? AppTheme.accent : AppTheme.textSecondary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
