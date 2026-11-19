import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/data/experience_store.dart';
import 'package:myportofolio_mobile/data/project_store.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/theme/app_colors.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

void main() {
  setUp(() {
    ProjectStore.reset();
    ExperienceStore.reset();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  Future<void> tapCard(WidgetTester tester, String name) async {
    final card = find.widgetWithText(ItemCard, name);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    // The card's floating SnackBar would otherwise cover buttons at the
    // bottom of the next screen.
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(
    WidgetTester tester, {
    String label = 'Save Project',
  }) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    // Lay out the scrolled list before reading the button's position.
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> openDrawerAndTap(WidgetTester tester, String entry) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, entry));
    await tester.pumpAndSettle();
  }

  /// Counts screens in the whole route stack, including covered ones.
  int screensInStack(Type type) =>
      find.byType(type, skipOffstage: false).evaluate().length;

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
      await tapSave(tester);

      expect(find.text('Project title cannot be empty.'), findsOneWidget);
      expect(find.text('Add at least one technology.'), findsOneWidget);
      expect(
        find.text('Description must be at least 20 characters.'),
        findsOneWidget,
      );
      expect(ProjectStore.projects.value.length, 3);
    });

    testWidgets('an invalid link is rejected but an empty one is allowed', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Project');
      final linkField = find.widgetWithText(TextFormField, 'Project link');

      await tester.enterText(linkField, 'not a link');
      await tapSave(tester);
      expect(
        find.text('Enter a full link starting with http:// or https://'),
        findsOneWidget,
      );

      await tester.enterText(linkField, '');
      await tapSave(tester);
      expect(
        find.text('Enter a full link starting with http:// or https://'),
        findsNothing,
      );
    });

    testWidgets('saves the chosen category and link with the project', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Project');

      // The dropdown starts on the first category.
      expect(find.text('Web Development'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      // The open menu also lists the items, so tap the last match.
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();

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
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Project link'),
        'https://github.com/example/myportofolio_mobile',
      );
      await tapSave(tester);

      final saved = ProjectStore.projects.value.last;
      expect(saved.category, 'Mobile Development');
      expect(saved.link, 'https://github.com/example/myportofolio_mobile');
      expect(find.text('Category: Mobile Development'), findsOneWidget);
      expect(
        find.text('Link: https://github.com/example/myportofolio_mobile'),
        findsOneWidget,
      );

      // After OK the dropdown is back on its default category.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Mobile Development'), findsNothing);
      expect(find.text('Web Development'), findsOneWidget);
    });

    testWidgets('validates the whole form on a short screen', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Future<void> fill(String label, String text) async {
        final field = find.widgetWithText(TextFormField, label);
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.enterText(field, text);
      }

      await pumpApp(tester);
      await tapCard(tester, 'Add Project');

      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();

      // Leave the title empty and fill everything below it, so the title is
      // scrolled out of view when Save is pressed.
      await fill('Tech stack', 'Flutter, Dart');
      await fill('Description', 'Flutter client for my personal portfolio.');
      await fill('Project link', 'https://example.com');
      await tapSave(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsNothing);
      expect(ProjectStore.projects.value.length, 3);
      expect(
        find.text('Project title cannot be empty.', skipOffstage: false),
        findsOneWidget,
      );
      // The off-screen dropdown keeps the chosen category.
      expect(
        find.descendant(
          of: find.byType(DropdownButtonFormField<String>, skipOffstage: false),
          matching: find.text('Mobile Development', skipOffstage: false),
        ),
        findsOneWidget,
      );
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
      await tapSave(tester);
      expect(ProjectStore.projects.value.length, 4);

      // The dialog lists what was entered, then OK clears the form.
      final dialog = find.byType(AlertDialog);
      expect(
        find.descendant(
          of: dialog,
          matching: find.text('Project added successfully!'),
        ),
        findsOneWidget,
      );
      for (final line in [
        'Title: MyPortfolio Mobile',
        'Category: Web Development',
        'Tech stack: Flutter, Dart',
        'Description: Flutter client for my personal portfolio website.',
        'Link: -',
      ]) {
        expect(
          find.descendant(of: dialog, matching: find.text(line)),
          findsOneWidget,
        );
      }

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(dialog, findsNothing);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      for (final field in tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      )) {
        expect(field.controller!.text, isEmpty);
      }

      await openDrawerAndTap(tester, 'View Projects');
      await tester.scrollUntilVisible(find.text('MyPortfolio Mobile'), 200);

      expect(find.text('MyPortfolio Mobile'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Not synced'), findsOneWidget);
    });
  });

  group('Experience form', () {
    const saveExperience = 'Save Experience';

    Finder field(String label) => find.widgetWithText(TextFormField, label);

    /// Scrolls to a field first, so this also works on short screens.
    Future<void> fill(WidgetTester tester, String label, String text) async {
      await tester.ensureVisible(field(label));
      await tester.pumpAndSettle();
      await tester.enterText(field(label), text);
    }

    Future<void> fillRequired(WidgetTester tester) async {
      await fill(tester, 'Role / Position', 'Software Engineer Intern');
      await fill(tester, 'Description', 'Built internal tools in Flutter.');
    }

    /// Opens the date picker from the End date field and picks the first
    /// day of the current month, which is never after today.
    Future<DateTime> pickFirstOfMonth(WidgetTester tester) async {
      await tester.ensureVisible(field('End date'));
      await tester.pumpAndSettle();
      await tester.tap(field('End date'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.text('1'),
        ),
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final now = DateTime.now();
      return DateTime(now.year, now.month);
    }

    String formatDate(WidgetTester tester, DateTime date) {
      final context = tester.element(find.byType(ExperienceFormPage));
      return MaterialLocalizations.of(context).formatShortDate(date);
    }

    testWidgets('Add Experience card pushes the form and Back returns home', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Experience');

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Add Experience'),
        ),
        findsOneWidget,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(screensInStack(ExperienceFormPage), 0);
    });

    testWidgets('the drawer opens the form and Home returns to home', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawerAndTap(tester, 'Add Project');
      await openDrawerAndTap(tester, 'Add Experience');

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(screensInStack(ProjectFormPage), 0);

      // Its own entry is highlighted and only closes the drawer.
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Add Experience'))
            .selected,
        isTrue,
      );
      await tester.tap(find.widgetWithText(ListTile, 'Add Experience'));
      await tester.pumpAndSettle();
      expect(screensInStack(ExperienceFormPage), 1);

      await openDrawerAndTap(tester, 'Home');
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(screensInStack(MyHomePage), 1);
      expect(screensInStack(ExperienceFormPage), 0);
    });

    testWidgets('rejects empty and whitespace-only required fields', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawerAndTap(tester, 'Add Experience');

      await tapSave(tester, label: saveExperience);
      expect(find.text('Role cannot be empty.'), findsOneWidget);
      expect(find.text('Description cannot be empty.'), findsOneWidget);

      // Spaces only are trimmed away, so they count as empty too.
      await fill(tester, 'Role / Position', '   ');
      await fill(tester, 'Description', '  \n  ');
      await tapSave(tester, label: saveExperience);
      expect(find.text('Role cannot be empty.'), findsOneWidget);
      expect(find.text('Description cannot be empty.'), findsOneWidget);

      expect(find.byType(AlertDialog), findsNothing);
      expect(ExperienceStore.experiences.value.length, 2);
    });

    testWidgets('checks the role length and the thumbnail URL', (tester) async {
      await pumpApp(tester);
      await openDrawerAndTap(tester, 'Add Experience');

      await fill(tester, 'Role / Position', 'a' * 256);
      await fill(tester, 'Description', 'Built internal tools in Flutter.');
      // A URL keyboard does not stop text without http:// or https://.
      await fill(tester, 'Thumbnail URL', 'www.example.com/thumb.png');
      await tapSave(tester, label: saveExperience);

      expect(find.text('Role must be at most 255 characters.'), findsOneWidget);
      expect(
        find.text('Enter a full link starting with http:// or https://'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      // Exactly 255 characters and an empty thumbnail are both allowed.
      await fill(tester, 'Role / Position', 'a' * 255);
      await fill(tester, 'Thumbnail URL', '');
      await tapSave(tester, label: saveExperience);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('picks the end date from a date picker and can clear it', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawerAndTap(tester, 'Add Experience');

      await tester.ensureVisible(field('End date'));
      await tester.pumpAndSettle();
      await tester.tap(field('End date'));
      await tester.pumpAndSettle();

      // Only past dates can be picked, because an end date is for an
      // experience that has finished.
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(picker.firstDate, DateTime(2000));
      expect(picker.lastDate, DateUtils.dateOnly(DateTime.now()));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final picked = await pickFirstOfMonth(tester);
      expect(
        tester.widget<TextFormField>(field('End date')).controller!.text,
        formatDate(tester, picked),
      );

      await tester.tap(find.byTooltip('Clear end date'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(field('End date')).controller!.text,
        isEmpty,
      );

      // Without an end date the summary calls the experience ongoing.
      await fillRequired(tester);
      await tapSave(tester, label: saveExperience);
      expect(find.text('End date: Ongoing'), findsOneWidget);
    });

    testWidgets('a valid experience is summarised and appears in About Me', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Experience');

      // The dropdown starts on the Django model's default category.
      expect(find.text('Full-Time'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Volunteer').last);
      await tester.pumpAndSettle();

      await fill(tester, 'Role / Position', '  Software Engineer Intern ');
      await fill(tester, 'Description', 'Built internal tools in Flutter.');
      await fill(tester, 'Thumbnail URL', 'https://example.com/thumb.png');
      final endedAt = await pickFirstOfMonth(tester);
      final endDateText = formatDate(tester, endedAt);
      await tapSave(tester, label: saveExperience);

      final dialog = find.byType(AlertDialog);
      expect(
        find.descendant(
          of: dialog,
          matching: find.text('Experience added successfully!'),
        ),
        findsOneWidget,
      );
      for (final line in [
        'Role / Position: Software Engineer Intern',
        'Category: Volunteer',
        'Description: Built internal tools in Flutter.',
        'Thumbnail: https://example.com/thumb.png',
        'End date: $endDateText',
      ]) {
        expect(
          find.descendant(of: dialog, matching: find.text(line)),
          findsOneWidget,
        );
      }

      final saved = ExperienceStore.experiences.value.last;
      expect(saved.title, 'Software Engineer Intern');
      expect(saved.endedAt, endedAt);
      expect(saved.isLocalDraft, isTrue);

      // OK closes only the dialog: the form is still open, and reset.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(dialog, findsNothing);
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      for (final textField in tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      )) {
        expect(textField.controller!.text, isEmpty);
      }
      expect(find.text('Full-Time'), findsOneWidget);
      expect(find.byTooltip('Clear end date'), findsNothing);

      await openDrawerAndTap(tester, 'Home');
      await tapCard(tester, 'About Me');
      expect(find.text('Software Engineer Intern'), findsOneWidget);
      expect(find.text('Not synced'), findsOneWidget);
      expect(find.text('Ended $endDateText'), findsOneWidget);
    });

    testWidgets('Save stays reachable on a phone with the keyboard open', (
      tester,
    ) async {
      const screenHeight = 640.0;
      const keyboardHeight = 300.0;
      tester.view.physicalSize = const Size(320, screenHeight);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await openDrawerAndTap(tester, 'Add Experience');
      await fillRequired(tester);
      await fill(tester, 'Thumbnail URL', 'https://example.com/thumb.png');

      final save = find.text(saveExperience);
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      // The button is scrolled into the space above the keyboard.
      expect(
        tester.getRect(save).bottom,
        lessThanOrEqualTo(screenHeight - keyboardHeight),
      );

      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('Drawer navigation', () {
    testWidgets('opens from the home screen and lists every screen', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      final drawer = find.byType(LeftDrawer);
      expect(drawer, findsOneWidget);
      for (final entry in [
        'Home',
        'View Projects',
        'Add Project',
        'Add Experience',
      ]) {
        expect(
          find.descendant(of: drawer, matching: find.text(entry)),
          findsOneWidget,
        );
      }
    });

    testWidgets('Home returns to the existing home screen', (tester) async {
      await pumpApp(tester);
      await openDrawerAndTap(tester, 'Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);

      await openDrawerAndTap(tester, 'Home');

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(screensInStack(MyHomePage), 1);
      expect(screensInStack(ProjectFormPage), 0);
    });

    testWidgets('never stacks the same screen twice', (tester) async {
      await pumpApp(tester);
      // Home -> View Projects -> Add Project (through the list's button).
      await tapCard(tester, 'View Projects');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await openDrawerAndTap(tester, 'View Projects');

      expect(find.byType(ProjectListPage), findsOneWidget);
      expect(screensInStack(ProjectListPage), 1);
      expect(screensInStack(ProjectFormPage), 0);

      // The system Back button now goes straight home.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Add Project card pushes the form and Back returns home', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
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
