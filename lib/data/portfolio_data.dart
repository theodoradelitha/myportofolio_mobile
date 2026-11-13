import 'package:myportofolio_mobile/models/project.dart';

/// Static portfolio content taken from my Django portfolio site.
///
/// This will be replaced by data from the Django REST API once the app is
/// connected to the backend in a later tutorial.
abstract final class PortfolioData {
  static const List<String> roles = [
    'Front-End Developer',
    'UI/UX Design',
    'UX Researcher',
  ];

  static const List<Project> projects = [
    Project(
      title: 'OH26',
      techStack: ['Next.js', 'TypeScript', 'Tailwind CSS'],
      description:
          'Developed as an IT Dev selection assignment. I built the recruitment '
          'landing page by efficiently composing pre-built UI components from '
          'the design system (like the countdown timer and FAQ accordion) into '
          'a responsive layout.',
    ),
    Project(
      title: 'DDP026',
      techStack: ['Vite', 'React Router', 'TypeScript'],
      description:
          'Frontend developer for the DDP0 freshman platform. I translated UI '
          'layouts into responsive code for the Home and About pages, '
          'implementing custom features like the cherry blossom timeline and '
          'mission statements.',
    ),
    Project(
      title: 'Symbiocle',
      techStack: ['Next.js 14', 'Tailwind CSS', 'Python FastAPI'],
      description:
          'Frontend developer for a B2B circular economy platform built for the '
          'IYREF Hackathon 2026. I engineered the Next.js MVP dashboard to '
          'intuitively display AI-powered matchmaking results, connecting '
          'waste-producing factories with compatible recyclers.',
    ),
  ];
}
