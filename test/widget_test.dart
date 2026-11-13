import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/data/project_store.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/theme/app_colors.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';

void main() {
  setUp(ProjectStore.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  Future<void> tapCard(WidgetTester tester, String name) async {
    final card = find.widgetWithText(ItemCard, name);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
  }

  group('Home page', () {
    testWidgets('shows my NPM, full name and class in three InfoCards', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(InfoCard), findsNWidgets(3));
      expect(find.widgetWithText(InfoCard, '2506553585'), findsOneWidget);
      expect(find.widgetWithText(InfoCard, 'Delitha Theodora'), findsOneWidget);
      expect(find.widgetWithText(InfoCard, 'PBP KKI'), findsOneWidget);
    });

    testWidgets('shows every action card with its icon and label', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(ItemCard), findsNWidgets(MyHomePage.items.length));
      for (final item in MyHomePage.items) {
        final card = find.widgetWithText(ItemCard, item.name);
        expect(card, findsOneWidget);
        expect(
          find.descendant(of: card, matching: find.byIcon(item.icon)),
          findsOneWidget,
        );
      }
    });

    testWidgets('gives every action card a different background color', (
      tester,
    ) async {
      await pumpApp(tester);

      final colors = tester.widgetList<ItemCard>(find.byType(ItemCard)).map((
        card,
      ) {
        final material = tester.widget<Material>(
          find
              .descendant(
                of: find.byWidget(card),
                matching: find.byType(Material),
              )
              .first,
        );
        return material.color;
      }).toSet();

      expect(colors.length, MyHomePage.items.length);
    });

    for (final item in MyHomePage.items) {
      testWidgets('tapping ${item.name} shows its SnackBar', (tester) async {
        await pumpApp(tester);
        final card = find.widgetWithText(ItemCard, item.name);
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pump();

        expect(
          find.text('You pressed the ${item.name} button!'),
          findsOneWidget,
        );
      });
    }

    testWidgets('fits a small 320x640 screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(InfoCard), findsNWidgets(3));
    });
  });

  group('Projects', () {
    testWidgets('View Projects lists the portfolio projects', (tester) async {
      await pumpApp(tester);
      await tapCard(tester, 'View Projects');

      expect(find.text('My Projects'), findsOneWidget);
      expect(find.text('OH26'), findsOneWidget);
      expect(find.text('DDP026'), findsOneWidget);

      // The list builds lazily, so scroll to the last project first.
      await tester.scrollUntilVisible(find.text('Symbiocle'), 200);
      expect(find.text('Symbiocle'), findsOneWidget);
    });

    testWidgets('Add Project validates empty and short input', (tester) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Project');

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Too short',
      );
      await tester.tap(find.text('Save Project'));
      await tester.pumpAndSettle();

      expect(find.text('Project title cannot be empty.'), findsOneWidget);
      expect(find.text('Add at least one technology.'), findsOneWidget);
      expect(
        find.text('Description must be at least 20 characters.'),
        findsOneWidget,
      );
      expect(ProjectStore.projects.value.length, 3);
    });

    testWidgets('a valid project appears in View Projects', (tester) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Project');

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Project title'),
        'MyPortfolio Mobile',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tech stack'),
        'Flutter, Dart',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Flutter client for my personal portfolio website.',
      );
      await tester.tap(find.text('Save Project'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(ProjectStore.projects.value.length, 4);

      await tapCard(tester, 'View Projects');
      await tester.scrollUntilVisible(find.text('MyPortfolio Mobile'), 200);

      expect(find.text('MyPortfolio Mobile'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Not synced'), findsOneWidget);
    });
  });

  group('Other actions', () {
    testWidgets('About Me shows my roles and experience', (tester) async {
      await pumpApp(tester);
      await tapCard(tester, 'About Me');

      expect(find.text('IDS Teaching Assistant'), findsOneWidget);
      expect(find.text('COMPFEST 18 - UX Academy Staff'), findsOneWidget);
    });

    testWidgets('Logout asks for confirmation and can be cancelled', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Logout');

      expect(find.text('Log out?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('confirming logout explains it is not connected yet', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Logout');

      await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('connected to Django authentication'),
        findsOneWidget,
      );
    });
  });

  group('Theme', () {
    double contrastRatio(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final lighter = la > lb ? la : lb;
      final darker = la > lb ? lb : la;
      return (lighter + 0.05) / (darker + 0.05);
    }

    test('cream text on every action card meets WCAG AA contrast', () {
      for (final item in MyHomePage.items) {
        expect(
          contrastRatio(item.color, AppColors.cream),
          greaterThanOrEqualTo(4.5),
          reason: '${item.name} card',
        );
      }
    });
  });
}
