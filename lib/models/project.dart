import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// A portfolio project, matching `ProjectSerializer` in my Django backend.
///
/// `FieldRename.snake` maps each camelCase field to the snake_case key DRF
/// uses, so [techStack] is read from and written to `tech_stack`. The
/// serializer's star fields (`star_count`, `is_starred`, `starred_by_names`)
/// are not used by the app, so they are not declared and are ignored when
/// parsing.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.techStack,
    this.demoLink,
    this.image = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// The image Django saves when a project is created without one. It is a
  /// placeholder, so the app shows no image for it.
  static const String placeholderImage = 'img/blank-folder.svg';

  /// UUID assigned by Django. Null for a project that has not been saved
  /// yet, and never sent in a request body because the server creates it.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;

  /// Comma-separated technologies, stored as one string by Django, for
  /// example "Flutter, Dart, Django".
  final String techStack;

  /// Link to the live project or its repository. Django allows it to be
  /// null or empty.
  final String? demoLink;

  /// Either a full image URL or a path inside the website's static folder,
  /// such as "img/oh-project.webp". Empty when the API leaves it out.
  @JsonKey(defaultValue: '')
  final String image;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  /// [techStack] split into separate technologies, for showing as chips.
  List<String> get techStackItems => techStack
      .split(',')
      .map((tech) => tech.trim())
      .where((tech) => tech.isNotEmpty)
      .toList();

  /// Whether the project has a real image to show.
  bool get hasImage => image.isNotEmpty && image != placeholderImage;

  /// Absolute URL of [image]. Static paths are resolved against the Django
  /// server, which serves them under `/static/`.
  String imageUrl(String baseUrl) {
    final uri = Uri.tryParse(image);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return image;
    }
    final path = image.startsWith('/') ? image.substring(1) : image;
    return '$baseUrl/static/$path';
  }
}
