import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/project_store.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/summary_dialog.dart';

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

  String? _validateTitle(String? value) => Validators.requiredText(
    value,
    fieldName: 'Project title',
    maxLength: _maxTitleLength,
  );

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
    await showSummaryDialog(
      context,
      title: 'Project added successfully!',
      rows: [
        SummaryRow(label: 'Title', value: project.title),
        SummaryRow(label: 'Category', value: project.category!),
        SummaryRow(label: 'Tech stack', value: project.techStack.join(', ')),
        SummaryRow(label: 'Description', value: project.description),
        SummaryRow(label: 'Link', value: project.link ?? '-'),
      ],
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
                validator: Validators.optionalWebUrl,
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
