import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/portfolio_star.dart';
import 'package:provider/provider.dart';

/// Shows every field of one project from the API.
class ProjectDetailPage extends StatelessWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final demoLink = project.demoLink ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Only projects with a real image get the image section.
                if (project.hasImage) ...[
                  _ProjectImage(
                    url: project.imageUrl(context.read<ApiClient>().baseUrl),
                  ),
                  const SizedBox(height: 16.0),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(project.title, style: textTheme.displaySmall),
                    ),
                    const PortfolioStar(size: 34.0, flipped: true),
                  ],
                ),
                const SizedBox(height: 16.0),
                _Section(
                  title: 'Description',
                  child: Text(
                    project.description,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
                _Section(
                  title: 'Tech Stack',
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: project.techStackItems
                        .map((tech) => Chip(label: Text(tech)))
                        .toList(),
                  ),
                ),
                _Section(
                  title: 'Project URL',
                  // Selectable so the link can be copied into a browser.
                  child: demoLink.isEmpty
                      ? Text(
                          'No link provided.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        )
                      : SelectableText(
                          demoLink,
                          style: TextStyle(color: colorScheme.tertiary),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.displaySmall?.copyWith(fontSize: 22.0)),
          const SizedBox(height: 8.0),
          child,
        ],
      ),
    );
  }
}

class _ProjectImage extends StatelessWidget {
  final String url;

  const _ProjectImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          semanticLabel: 'Project image',
          // On Flutter Web, images from another origin need CORS headers,
          // which runserver's static files and many image hosts don't send.
          // Falling back to an HTML <img> element shows them anyway. Other
          // platforms ignore this setting.
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          // A broken link or blocked image shows a placeholder instead of
          // Flutter's error widget.
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48.0,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
