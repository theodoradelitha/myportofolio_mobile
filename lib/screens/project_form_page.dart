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

  void _submit() {
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '"${project.title}" was added to View Projects for this session.',
          ),
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),
      drawer: const LeftDrawer(current: DrawerDestination.addProject),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Projects added here are kept in memory only and are not sent '
              'to my Django portfolio yet.',
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
              // only read when the field is created or reset.
              initialValue: _category,
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
    );
  }
}
