import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/liquid_glass.dart';
import '../services/project_service.dart';
import 'editor_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Projects',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                GlassIconButton(
                  icon: Icons.add_rounded,
                  onTap: () {
                    final p = context.read<ProjectService>().createProject('New Project');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditorScreen(projectId: p.id, projectName: p.name),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ProjectService>(
              builder: (context, service, _) {
                if (service.projects.isEmpty) {
                  return const Center(
                    child: Text(
                      'No projects yet.\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: service.projects.length,
                  itemBuilder: (context, index) {
                    final p = service.projects[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LiquidGlass(
                        borderRadius: 14,
                        opacity: 0.08,
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          service.touch(p.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditorScreen(
                                projectId: p.id,
                                projectName: p.name,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppTheme.surfaceLight,
                              ),
                              child: const Icon(Icons.movie_creation_rounded, color: AppTheme.accent, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.clipCount} clips · ${p.resolution}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Updated ${_timeAgo(p.updatedAt)}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary.withOpacity(0.7)  ,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
                              color: AppTheme.surface,
                              onSelected: (value) {
                                if (value == 'delete') {
                                  service.deleteProject(p.id);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'rename', child: Text('Rename')),
                                const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete', style: TextStyle(color: AppTheme.danger)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
