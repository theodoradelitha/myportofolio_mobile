import 'package:myportofolio_mobile/models/experience.dart';

/// Static portfolio content taken from my Django portfolio site.
///
/// Projects now come from the Django REST API. The roles and experiences
/// below are still static until their API is connected.
abstract final class PortfolioData {
  static const List<String> roles = [
    'Front-End Developer',
    'UI/UX Design',
    'UX Researcher',
  ];

  static const List<Experience> experiences = [
    Experience(
      title: 'COMPFEST 18 - UX Academy Staff',
      category: 'Volunteer',
      description:
          'Managed applicant outreach and facilitated interactive UX camp '
          'sessions.',
    ),
    Experience(
      title: 'IDS Teaching Assistant',
      category: 'Part-Time',
      description:
          'Assisted students in understanding course material, guided '
          'practical sessions, and evaluated assignments.',
    ),
  ];
}
