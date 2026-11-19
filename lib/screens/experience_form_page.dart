import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/experience_store.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/summary_dialog.dart';

/// Form for adding an entry to the Experience section of my portfolio.
///
/// The fields and rules follow the Experience model and ExperienceForm of my
/// Django portfolio.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  // Same limit as `title = models.CharField(max_length=255)` in Django.
  static const int _maxRoleLength = 255;

  /// Earliest end date the date picker offers.
  static final DateTime _earliestEndDate = DateTime(2000);

  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();

  /// Shows the picked end date as text. The date itself is kept in
  /// [_endedAt], so it never has to be parsed back from this text.
  final _endDateController = TextEditingController();

  /// The dropdown and the date picker have no text controller of their own,
  /// so their values are kept in state.
  String _category = Experience.defaultCategory;
  DateTime? _endedAt;

  @override
  void dispose() {
    _roleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      MaterialLocalizations.of(context).formatShortDate(date);

  Future<void> _pickEndDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    // An end date records a finished experience, so the picker only offers
    // dates up to today. Ongoing experiences leave the field empty.
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? today,
      firstDate: _earliestEndDate,
      lastDate: today,
      helpText: 'Select end date',
    );
    if (picked == null || !mounted) return;

    setState(() => _endedAt = picked);
    _endDateController.text = _formatDate(picked);
  }

  void _clearEndDate() {
    setState(() => _endedAt = null);
    _endDateController.clear();
  }

  Future<void> _submit() async {
    // Runs every field's validator and shows their error messages.
    if (!_formKey.currentState!.validate()) return;

    // Close the keyboard so the whole dialog is visible.
    FocusScope.of(context).unfocus();

    final thumbnail = _thumbnailController.text.trim();
    final experience = Experience(
      title: _roleController.text.trim(),
      category: _category,
      description: _descriptionController.text.trim(),
      thumbnail: thumbnail.isEmpty ? null : thumbnail,
      endedAt: _endedAt,
      isLocalDraft: true,
    );
    ExperienceStore.add(experience);

    await showSummaryDialog(
      context,
      title: 'Experience added successfully!',
      rows: [
        SummaryRow(label: 'Role / Position', value: experience.title),
        SummaryRow(label: 'Category', value: experience.category),
        SummaryRow(label: 'Description', value: experience.description),
        SummaryRow(label: 'Thumbnail', value: experience.thumbnail ?? '-'),
        SummaryRow(
          label: 'End date',
          value: experience.isOngoing
              ? 'Ongoing'
              : _formatDate(experience.endedAt!),
        ),
      ],
    );

    // The page may have been closed while the dialog was open.
    if (!mounted) return;
    _resetForm();
  }

  /// Clears every field so another experience can be entered.
  void _resetForm() {
    // reset() puts every field back to its initial value: empty text for the
    // controller-backed fields (including the end date text) and the default
    // category for the dropdown.
    _formKey.currentState!.reset();
    setState(() {
      _category = Experience.defaultCategory;
      _endedAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Experience')),
      drawer: const LeftDrawer(current: DrawerDestination.addExperience),
      body: Form(
        key: _formKey,
        // Every field is built at once inside the scroll view, so the Form
        // can validate and reset all of them. When the keyboard opens, the
        // Scaffold shrinks the body and the fields scroll above it.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            // Same width cap as the home screen, so the fields don't stretch
            // across a wide browser window.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Saved experiences appear in About Me until the app is '
                    'closed. They are not sent to my Django portfolio yet.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role / Position',
                      hintText: 'e.g. Software Engineer Intern',
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) => Validators.requiredText(
                      value,
                      fieldName: 'Role',
                      maxLength: _maxRoleLength,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    // The default, not the current choice, so that reset()
                    // goes back to it.
                    initialValue: Experience.defaultCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: Experience.categories
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
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe what you did…',
                      alignLabelWithHint: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 6,
                    validator: (value) => Validators.requiredText(
                      value,
                      fieldName: 'Description',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _thumbnailController,
                    decoration: const InputDecoration(
                      labelText: 'Thumbnail URL',
                      hintText: 'https://… (optional)',
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    validator: Validators.optionalWebUrl,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _endDateController,
                    // Typing is disabled: the date can only come from the
                    // picker, so it is always a real date in the allowed range.
                    readOnly: true,
                    onTap: _pickEndDate,
                    decoration: InputDecoration(
                      labelText: 'End date',
                      hintText: 'Tap to pick a date',
                      helperText: 'Leave empty if this experience is ongoing.',
                      suffixIcon: _endedAt == null
                          ? const Icon(Icons.calendar_today_outlined)
                          : IconButton(
                              tooltip: 'Clear end date',
                              icon: const Icon(Icons.clear),
                              onPressed: _clearEndDate,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Experience'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
