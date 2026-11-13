class Project {
  final String title;
  final List<String> techStack;
  final String description;

  /// True for projects added from the app. These only live in memory until
  /// the app is connected to the Django backend.
  final bool isLocalDraft;

  const Project({
    required this.title,
    required this.techStack,
    required this.description,
    this.isLocalDraft = false,
  });
}
