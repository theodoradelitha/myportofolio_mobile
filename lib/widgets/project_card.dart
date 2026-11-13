import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (project.isLocalDraft)
                  Text(
                    'Not synced',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(project.description, style: textTheme.bodyMedium),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: project.techStack
                  .map(
                    (tech) => Chip(
                      label: Text(tech),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
