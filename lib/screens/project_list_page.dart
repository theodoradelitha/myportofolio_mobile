import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/data/project_store.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Projects')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProjectFormPage())),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
      ),
      body: ValueListenableBuilder<List<Project>>(
        valueListenable: ProjectStore.projects,
        builder: (context, projects, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 88.0),
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

    // Styled like the website's toast: cream box with a burgundy accent bar.
    // A one-sided border can't be combined with rounded corners in a
    // BoxDecoration, so the bar is its own child and the box clips it.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colorScheme.outline),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4.0, color: colorScheme.tertiary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.tertiary),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'These projects are copied from my portfolio website. '
                        'Live data from the Django API will be added in a '
                        'later tutorial.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
