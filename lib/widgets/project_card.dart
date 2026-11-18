import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/widgets/portfolio_star.dart';

/// Mobile version of the project card on my website: Genty title with a
/// large and a small star, the description, then the tech stack.
class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(project.title, style: textTheme.displaySmall),
                ),
                const PortfolioStar(size: 34.0, flipped: true),
                const Padding(
                  padding: EdgeInsets.only(top: 14.0),
                  child: PortfolioStar(size: 22.0, flipped: true),
                ),
              ],
            ),
            if (project.isLocalDraft)
              Text(
                'Not synced',
                style: textTheme.labelSmall?.copyWith(color: colorScheme.error),
              ),
            const SizedBox(height: 12.0),
            Text(
              project.description,
              style: textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tech Stack',
              style: textTheme.displaySmall?.copyWith(fontSize: 22.0),
            ),
            const SizedBox(height: 8.0),
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
