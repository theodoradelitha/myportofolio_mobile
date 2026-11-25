import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_page.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

/// Lists the projects from the Django API. Anyone can view it.
class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  // Created in initState, not in build: build runs again on every rebuild
  // (keyboard, theme, setState), and each run would send a new request.
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = context.read<ApiClient>().getProjects();
  }

  /// Starts a new request. Returning its Future lets RefreshIndicator keep
  /// its spinner until the list has loaded.
  Future<void> _reload() async {
    final future = context.read<ApiClient>().getProjects();
    // A block body: an arrow would return the Future from the callback,
    // which setState rejects.
    setState(() {
      _projectsFuture = future;
    });
    try {
      await future;
    } catch (_) {
      // The FutureBuilder already shows the error; the pull gesture only
      // needs to know the request finished.
    }
  }

  Future<void> _openForm() async {
    final navigator = Navigator.of(context);
    if (!await ensureLoggedIn(context)) return;

    await navigator.push(
      MaterialPageRoute<void>(builder: (_) => const ProjectFormPage()),
    );
    // Show projects that were added while the form was open.
    if (mounted) _reload();
  }

  void _openDetail(Project project) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProjectDetailPage(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Projects')),
      drawer: const LeftDrawer(current: DrawerDestination.projects),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
      ),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is ApiException
                ? error.message
                : 'Something went wrong while loading projects.';
            return _ErrorState(message: message, onRetry: _reload);
          }

          final projects = snapshot.data ?? const <Project>[];

          if (projects.isEmpty) {
            // A plain Center can't be scrolled, so pull-to-refresh would
            // never trigger. AlwaysScrollableScrollPhysics lets it scroll
            // (and refresh) even though the content fits on screen.
            return RefreshIndicator(
              onRefresh: _reload,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const Center(child: Text('No projects found.')),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              // Bottom padding keeps the last card clear of the FAB.
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 88.0),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectCard(
                  project: project,
                  onTap: () => _openDetail(project),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48.0, color: colorScheme.error),
            const SizedBox(height: 12.0),
            Text(
              'Failed to load projects',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16.0),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
