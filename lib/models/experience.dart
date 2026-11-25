/// One entry of the Experience section of my portfolio.
///
/// The fields follow the Experience model of my Django portfolio. Django
/// fills in the start date itself when an entry is created, so the app only
/// knows the optional end date.
class Experience {
  /// The role or position, such as "IDS Teaching Assistant".
  final String title;

  /// One of [categories], such as "Volunteer".
  final String category;
  final String description;

  /// Link to an image for the experience, if there is one.
  final String? thumbnail;

  /// When the experience ended. Null while it is still ongoing.
  final DateTime? endedAt;

  /// True for experiences added from the app. These only live in memory
  /// until the app is connected to the Django backend.
  final bool isLocalDraft;

  /// The category choices of the Django model, in the same order.
  static const List<String> categories = [
    'Internship',
    'Research',
    'Volunteer',
    'Part-Time',
    'Full-Time',
    'Freelance',
  ];

  /// The Django model's default category.
  static const String defaultCategory = 'Full-Time';

  const Experience({
    required this.title,
    required this.category,
    required this.description,
    this.thumbnail,
    this.endedAt,
    this.isLocalDraft = false,
  });

  bool get isOngoing => endedAt == null;
}
