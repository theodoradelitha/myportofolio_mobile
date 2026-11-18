class Project {
  final String title;
  final List<String> techStack;
  final String description;

  /// Kind of project, such as "Web Development". Optional because the
  /// projects copied from my website don't have one.
  final String? category;

  /// Link to the live project or its repository, if there is one.
  final String? link;

  /// True for projects added from the app. These only live in memory until
  /// the app is connected to the Django backend.
  final bool isLocalDraft;

  const Project({
    required this.title,
    required this.techStack,
    required this.description,
    this.category,
    this.link,
    this.isLocalDraft = false,
  });
}
