import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/summary_dialog.dart';
import 'package:provider/provider.dart';

/// Creates a project through the Django API. Requires a logged-in owner.
///
/// The fields match `ProjectSerializer`: title, description, tech_stack,
/// demo_link (shown as "Project URL") and image (shown as "Project Image
/// URL").
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  // Same limits as the Project model in my Django portfolio.
  static const int _maxTitleLength = 255;
  static const int _maxTechStackLength = 200;
  static const int _maxImageLength = 255;
  static const int _minDescriptionLength = 20;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _projectUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) => Validators.requiredText(
    value,
    fieldName: 'Project title',
    maxLength: _maxTitleLength,
  );

  String? _validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.length < _minDescriptionLength) {
      return 'Description must be at least $_minDescriptionLength characters.';
    }
    return null;
  }

  String? _validateTechStack(String? value) {
    final techStack = value?.trim() ?? '';
    if (_parseTechStack(techStack).isEmpty) {
      return 'Add at least one technology.';
    }
    if (techStack.length > _maxTechStackLength) {
      return 'Tech stack must be at most $_maxTechStackLength characters.';
    }
    return null;
  }

  String? _validateImageUrl(String? value) {
    final error = Validators.optionalWebUrl(value);
    if (error != null) return error;
    if ((value?.trim().length ?? 0) > _maxImageLength) {
      return 'Image URL must be at most $_maxImageLength characters.';
    }
    return null;
  }

  List<String> _parseTechStack(String input) {
    return input
        .split(',')
        .map((tech) => tech.trim())
        .where((tech) => tech.isNotEmpty)
        .toList();
  }

  Project _projectFromForm() {
    final projectUrl = _projectUrlController.text.trim();
    return Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      // Normalised to "A, B, C" so the website shows it the same way.
      techStack: _parseTechStack(_techStackController.text).join(', '),
      demoLink: projectUrl.isEmpty ? null : projectUrl,
      // Django replaces an empty image with its placeholder.
      image: _imageUrlController.text.trim(),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    // Runs every field's validator and shows their error messages.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final Project? created;
    try {
      created = await _createProject();
    } finally {
      // Stop the spinner as soon as the request is done, not after the
      // dialog below is closed.
      if (mounted) setState(() => _isSubmitting = false);
    }
    if (created == null || !mounted) return;

    // showDialog's Future completes when the dialog is closed.
    await showSummaryDialog(
      context,
      title: 'Project added successfully!',
      rows: [
        SummaryRow(label: 'Title', value: created.title),
        SummaryRow(label: 'Tech stack', value: created.techStack),
        SummaryRow(label: 'Description', value: created.description),
        SummaryRow(label: 'Project URL', value: created.demoLink ?? '-'),
        SummaryRow(
          label: 'Image',
          value: created.hasImage ? created.image : '-',
        ),
      ],
    );

    // The page may have been closed while the dialog was open.
    if (!mounted) return;
    _formKey.currentState!.reset();
  }

  /// Sends the form to Django and returns the saved project, or null when
  /// the user cancelled login or the request failed (the error is shown).
  ///
  /// A 401 means the server no longer accepts the stored token (for example
  /// it was revoked by logging out on another device). The session is
  /// cleared and the user is asked to log in again, then the save is
  /// retried once.
  Future<Project?> _createProject({bool isRetry = false}) async {
    final auth = context.read<AuthState>();
    final apiClient = context.read<ApiClient>();

    if (!await ensureLoggedIn(context)) return null;
    final token = auth.token;
    if (token == null) return null;

    try {
      return await apiClient.createProject(_projectFromForm(), token: token);
    } on ApiException catch (error) {
      if (!mounted) return null;

      if (error.isUnauthorized && !isRetry) {
        auth.clearSession();
        _showMessage('Your session has expired. Please log in again.');
        return _createProject(isRetry: true);
      }

      _showMessage(
        error.statusCode == 403
            ? 'Only the portfolio owner can add projects.'
            : error.message,
      );
      return null;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),
      drawer: const LeftDrawer(current: DrawerDestination.addProject),
      body: Form(
        key: _formKey,
        // A Column inside SingleChildScrollView builds every field at once.
        // A lazy ListView would dispose fields scrolled far off-screen, and
        // the Form can only validate and reset fields that still exist.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Saved projects are sent to my Django portfolio and appear '
                'in View Projects and on the website.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Project title'),
                textInputAction: TextInputAction.next,
                validator: _validateTitle,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 6,
                validator: _validateDescription,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _techStackController,
                decoration: const InputDecoration(
                  labelText: 'Tech stack',
                  hintText: 'e.g. Flutter, Dart, Django',
                  helperText: 'Separate technologies with commas.',
                ),
                textInputAction: TextInputAction.next,
                validator: _validateTechStack,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _projectUrlController,
                decoration: const InputDecoration(
                  labelText: 'Project URL',
                  hintText: 'https://… (optional)',
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: Validators.optionalWebUrl,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Project Image URL (optional)',
                  hintText: 'https://…',
                ),
                keyboardType: TextInputType.url,
                validator: _validateImageUrl,
              ),
              const SizedBox(height: 24.0),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
