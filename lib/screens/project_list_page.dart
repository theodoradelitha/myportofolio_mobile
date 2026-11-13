import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/data/project_store.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Projects')),
      body: ValueListenableBuilder<List<Project>>(
        valueListenable: ProjectStore.projects,
        builder: (context, projects, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const _DataSourceNote(),
              const SizedBox(height: 8.0),
              for (final project in projects) ProjectCard(project: project),
            ],
          );
        },
      ),
    );
  }
}

class _DataSourceNote extends StatelessWidget {
  const _DataSourceNote();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'These projects are copied from my portfolio website. Live data '
              'from the Django API will be added in a later tutorial.',
              style: TextStyle(color: colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
