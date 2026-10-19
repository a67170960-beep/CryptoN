import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
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
      context.read<EditorService>().setProjectName(widget.projectName);
    });
  }

  Future<void> _importVideo() async {
    final status = await Permission.videos.request();
    final storage = await Permission.storage.request();
    if (!status.isGranted && !storage.isGranted) {
      // try photos permission on newer android
      await Permission.photos.request();
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      await context.read<EditorService>().importVideo(path, name);
    }
  }

  Future<void> _importAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      // For now treat as video import path for simplicity - just add as audio clip placeholder
      final path = result.files.single.path!;
      final name = result.files.single.name;
      final editor = context.read<EditorService>();
      editor.addTextClip('Audio: $name'); // temporary until full audio support
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Аудио добавлено: $name')),
      );
    }
  }

  void _addText() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Добавить текст', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Введите текст',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<EditorService>().addTextClip(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Добавить', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<EditorService>(
          builder: (context, editor, _) {
            return Column(
              children: [
                _buildTopBar(editor),
                if (editor.errorMessage != null)
                  Container(
                    width: double.infinity,
                    color: AppTheme.danger.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            editor.errorMessage!,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.white70),
                          onPressed: editor.clearError,
                        ),
                      ],
                    ),
                  ),
                Expanded(flex: 5, child: _buildPreview(editor)),
                Expanded(flex: 3, child: _buildTimeline(editor)),
                _buildTools(editor),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(EditorService editor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              editor.projectName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (editor.selectedClipId != null) ...[
            IconButton(
              icon: const Icon(Icons.content_cut_rounded, size: 20),
              color: AppTheme.textSecondary,
              tooltip: 'Split',
              onPressed: editor.splitSelectedClip,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: AppTheme.danger,
              tooltip: 'Delete',
              onPressed: editor.removeSelectedClip,
            ),
          ],
          if (editor.isExporting)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value: editor.exportProgress,
                  strokeWidth: 2.5,
                  color: AppTheme.accent,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                await editor.exportProject();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export completed (demo)')),
                  );
                }
              },
              child: const Text(
                'Export',
                style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview(EditorService editor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: LiquidGlass(
        borderRadius: 14,
        opacity: 0.06,
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (editor.isLoadingMedia)
                const CircularProgressIndicator(color: AppTheme.accent)
              else if (editor.hasVideo && editor.previewController != null)
                AspectRatio(
                  aspectRatio: editor.previewController!.value.aspectRatio,
                  child: VideoPlayer(editor.previewController!),
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off_rounded, size: 48, color: Colors.white.withOpacity(0.25)),
                    const SizedBox(height: 8),
                    Text(
                      'Нажми Media → Import Video',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                    ),
                  ],
                ),
              // Controls overlay
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        editor.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      onPressed: editor.hasVideo ? editor.togglePlay : null,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.5,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: editor.playhead.clamp(0, editor.totalDuration),
                          max: editor.totalDuration <= 0 ? 1 : editor.totalDuration,
                          onChanged: editor.setPlayhead,
                          activeColor: AppTheme.accent,
                          inactiveColor: Colors.white24,
                        ),
                      ),
                    ),
                    Text(
                      _fmt(editor.playhead),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(EditorService editor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            children: [
              const Text('Timeline', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.zoom_out, size: 18),
                color: AppTheme.textSecondary,
                onPressed: () => editor.setTimelineScale(editor.timelineScale - 0.2),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, size: 18),
                color: AppTheme.textSecondary,
                onPressed: () => editor.setTimelineScale(editor.timelineScale + 0.2),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              _track('V1', editor.videoClips, const Color(0xFF4A7C9B), editor),
              _track('A1', editor.audioClips, const Color(0xFF5C9B7A), editor),
              _track('T1', editor.textClips, const Color(0xFF8B7C9B), editor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _track(String label, List<TimelineClip> clips, Color color, EditorService editor) {
    final scale = 20.0 * editor.timelineScale;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ),
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.surface.withOpacity(0.5),
              ),
              child: Stack(
                children: clips.map((clip) {
                  final left = clip.start * scale;
                  final width = (clip.duration * scale).clamp(28.0, 800.0);
                  final selected = editor.selectedClipId == clip.id;
                  return Positioned(
                    left: left,
                    top: 3,
                    bottom: 3,
                    child: GestureDetector(
                      onTap: () => editor.selectClip(clip.id),
                      child: Container(
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: color.withOpacity(0.8),
                          border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          clip.name,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
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

  Widget _buildTools(EditorService editor) {
    final tools = <(ToolTab, IconData, String, VoidCallback?)>[
      (ToolTab.media, Icons.video_library_rounded, 'Media', _importVideo),
      (ToolTab.audio, Icons.audiotrack_rounded, 'Audio', _importAudio),
      (ToolTab.text, Icons.text_fields_rounded, 'Text', _addText),
      (ToolTab.stickers, Icons.emoji_emotions_rounded, 'Stickers', () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stickers — скоро')));
      }),
      (ToolTab.effects, Icons.auto_awesome_rounded, 'Effects', () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Effects — скоро')));
      }),
      (ToolTab.filters, Icons.photo_filter_rounded, 'Filters', () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filters — скоро')));
      }),
      (ToolTab.transition, Icons.animation_rounded, 'Transition', null),
      (ToolTab.adjust, Icons.tune_rounded, 'Adjust', null),
      (ToolTab.speed, Icons.speed_rounded, 'Speed', null),
      (ToolTab.animation, Icons.movie_filter_rounded, 'Anim', null),
      (ToolTab.canvas, Icons.crop_rounded, 'Canvas', null),
      (ToolTab.export, Icons.ios_share_rounded, 'Export', () => editor.exportProject()),
    ];

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final t = tools[index];
          final selected = editor.currentTab == t.$1;
          return GestureDetector(
            onTap: () {
              editor.setTab(t.$1);
              t.$4?.call();
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: selected ? AppTheme.accent.withOpacity(0.2) : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.$2, size: 20, color: selected ? AppTheme.accent : AppTheme.textSecondary),
                  const SizedBox(height: 3),
                  Text(
                    t.$3,
                    style: TextStyle(
                      fontSize: 9,
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
  }

  String _fmt(double sec) {
    final m = (sec / 60).floor();
    final s = (sec % 60).floor();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
