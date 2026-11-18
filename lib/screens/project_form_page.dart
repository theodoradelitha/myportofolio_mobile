import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/project_store.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  // Same limits as the Project model in my Django portfolio.
  static const int _maxTitleLength = 255;
  static const int _maxTechStackLength = 200;
  static const int _minDescriptionLength = 20;

  static const List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _techStackController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  /// The dropdown has no controller, so its value is kept in state.
  String _category = _categories.first;

  @override
  void dispose() {
    _titleController.dispose();
    _techStackController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Project title cannot be empty.';
    if (title.length > _maxTitleLength) {
      return 'Title must be at most $_maxTitleLength characters.';
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

  String? _validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.length < _minDescriptionLength) {
      return 'Description must be at least $_minDescriptionLength characters.';
    }
    return null;
  }

  /// The link is optional, but if one is given it must be a full web address.
  String? _validateLink(String? value) {
    final link = value?.trim() ?? '';
    if (link.isEmpty) return null;

    final uri = Uri.tryParse(link);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) return 'Enter a full link starting with http:// or https://';
    return null;
  }

  List<String> _parseTechStack(String input) {
    return input
        .split(',')
        .map((tech) => tech.trim())
        .where((tech) => tech.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    // Runs every field's validator and shows their error messages.
    if (!_formKey.currentState!.validate()) return;

    final link = _linkController.text.trim();
    final project = Project(
      title: _titleController.text.trim(),
      techStack: _parseTechStack(_techStackController.text),
      description: _descriptionController.text.trim(),
      category: _category,
      link: link.isEmpty ? null : link,
      isLocalDraft: true,
    );
    ProjectStore.add(project);

    // showDialog pushes the dialog as a new route and its Future completes
    // when that route is popped, by OK or by tapping outside the dialog.
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Project added successfully!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProjectDetail(label: 'Title', value: project.title),
              _ProjectDetail(label: 'Category', value: project.category!),
              _ProjectDetail(
                label: 'Tech stack',
                value: project.techStack.join(', '),
              ),
              _ProjectDetail(label: 'Description', value: project.description),
              _ProjectDetail(label: 'Link', value: project.link ?? '-'),
            ],
          ),
        ),
        actions: [
          TextButton(
            // Pop with the dialog's own context so only the dialog closes.
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // The page may have been closed while the dialog was open.
    if (!mounted) return;
    _resetForm();
  }

  /// Clears every field so another project can be entered.
  void _resetForm() {
    // reset() sets each field back to its initial value: empty text for the
    // controller-backed fields and the default category for the dropdown.
    _formKey.currentState!.reset();
    setState(() => _category = _categories.first);
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
                'Saved projects appear in View Projects until the app is '
                'closed. They are not sent to my Django portfolio yet.',
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
              DropdownButtonFormField<String>(
                // initialValue replaces the deprecated `value` parameter. It is
                // read when the field is created and again when the form is
                // reset, so it points at the default, not the current choice.
                initialValue: _categories.first,
                // Fill the field's width instead of sizing to the longest
                // category, which overflows on narrow screens.
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  setState(() => _category = newValue);
                },
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
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Project link',
                  hintText: 'https://… (optional)',
                ),
                keyboardType: TextInputType.url,
                validator: _validateLink,
              ),
              const SizedBox(height: 24.0),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Save Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One "Label: value" line in the confirmation dialog.
class _ProjectDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ProjectDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
