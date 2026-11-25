import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

void main() {
  group('Project JSON', () {
    test('reads the snake_case fields Django sends', () {
      final project = Project.fromJson({
        'id': '11111111-1111-1111-1111-111111111111',
        'title': 'OH26',
        'description': 'Landing page',
        'tech_stack': 'Next.js, TypeScript',
        'demo_link': 'https://example.com',
        'image': 'img/oh-project.webp',
        // Extra serializer fields the app doesn't use are ignored.
        'star_count': 3,
        'is_starred': true,
        'starred_by_names': 'a, b, c',
      });

      expect(project.id, '11111111-1111-1111-1111-111111111111');
      expect(project.title, 'OH26');
      expect(project.description, 'Landing page');
      expect(project.techStack, 'Next.js, TypeScript');
      expect(project.demoLink, 'https://example.com');
      expect(project.image, 'img/oh-project.webp');
    });

    test('accepts a null demo_link and a missing image', () {
      final project = Project.fromJson({
        'id': 'x',
        'title': 'Symbiocle',
        'description': 'Dashboard',
        'tech_stack': 'Next.js',
        'demo_link': null,
      });

      expect(project.demoLink, isNull);
      expect(project.image, '');
      expect(project.hasImage, isFalse);
    });

    test('toJson uses snake_case keys and never sends the id', () {
      const project = Project(
        id: 'server-id',
        title: 'App',
        description: 'Mobile app',
        techStack: 'Flutter, Dart',
        demoLink: 'https://example.com',
        image: 'https://example.com/a.png',
      );

      expect(project.toJson(), {
        'title': 'App',
        'description': 'Mobile app',
        'tech_stack': 'Flutter, Dart',
        'demo_link': 'https://example.com',
        'image': 'https://example.com/a.png',
      });
    });

    test('round-trips through JSON', () {
      const original = Project(
        title: 'App',
        description: 'Mobile app',
        techStack: 'Flutter',
      );
      final copy = Project.fromJson({...original.toJson(), 'id': 'new-id'});

      expect(copy.title, original.title);
      expect(copy.techStack, original.techStack);
      expect(copy.demoLink, isNull);
      expect(copy.id, 'new-id');
    });
  });

  group('Project helpers', () {
    Project withImage(String image, {String techStack = 'Dart'}) => Project(
      title: 't',
      description: 'd',
      techStack: techStack,
      image: image,
    );

    test('techStackItems splits and trims the comma-separated string', () {
      expect(
        withImage('', techStack: ' Flutter,Dart , ,Django ').techStackItems,
        ['Flutter', 'Dart', 'Django'],
      );
    });

    test('the default placeholder image counts as no image', () {
      expect(withImage(Project.placeholderImage).hasImage, isFalse);
      expect(withImage('img/oh-project.webp').hasImage, isTrue);
    });

    test('imageUrl keeps full URLs and resolves static paths', () {
      const base = 'http://10.0.2.2:8000';
      expect(
        withImage('https://cdn.example.com/a.png').imageUrl(base),
        'https://cdn.example.com/a.png',
      );
      expect(
        withImage('img/oh-project.webp').imageUrl(base),
        '$base/static/img/oh-project.webp',
      );
      expect(withImage('/img/a.png').imageUrl(base), '$base/static/img/a.png');
    });
  });
}
