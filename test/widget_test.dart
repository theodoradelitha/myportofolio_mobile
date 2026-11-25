import 'package:material_ui/material_ui.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/data/experience_store.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/login_page.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_detail_page.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_colors.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_backend.dart';

void main() {
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend();
    ExperienceStore.reset();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));
    await tester.pumpAndSettle();
  }

  AuthState authState(WidgetTester tester) =>
      tester.element(find.byType(Navigator).first).read<AuthState>();

  /// Logs in as the portfolio owner without going through the login screen.
  Future<void> logIn(
    WidgetTester tester, {
    String username = FakeBackend.ownerUsername,
  }) async {
    await authState(tester).login(username, FakeBackend.password);
    await tester.pumpAndSettle();
  }

  /// Fills in and submits the login screen.
  Future<void> submitLogin(
    WidgetTester tester, {
    String username = FakeBackend.ownerUsername,
    String password = FakeBackend.password,
  }) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      username,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      password,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
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
        // Logged in, so Add Project and Logout don't replace the SnackBar
        // with a login prompt or a "not logged in" message.
        await logIn(tester);
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
    Finder field(String label) => find.widgetWithText(TextFormField, label);

    Future<void> fill(WidgetTester tester, String label, String text) async {
      await tester.ensureVisible(field(label));
      await tester.pumpAndSettle();
      await tester.enterText(field(label), text);
    }

    Future<void> fillValidProject(WidgetTester tester) async {
      await fill(tester, 'Project title', 'MyPortfolio Mobile');
      await fill(
        tester,
        'Description',
        'Flutter client for my personal portfolio website.',
      );
      await fill(tester, 'Tech stack', 'Flutter,  Dart ,');
    }

    Future<void> openFormLoggedIn(WidgetTester tester) async {
      await pumpApp(tester);
      await logIn(tester);
      await tapCard(tester, 'Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);
    }

    Iterable<http.Request> projectPosts() => backend.requests.where(
      (r) => r.method == 'POST' && r.url.path == '/api/v1/projects/',
    );

    testWidgets('View Projects lists projects from the API once', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'View Projects');

      expect(find.text('My Projects'), findsOneWidget);
      expect(find.text('OH26'), findsOneWidget);
      expect(find.text('Symbiocle'), findsOneWidget);
      expect(find.text('TypeScript'), findsOneWidget);

      // Rebuilding the page must not start another request.
      await tester.pump();
      await tester.pumpAndSettle();
      expect(backend.projectListRequests, 1);
      // The public list is fetched without a token.
      expect(backend.requests.single.headers['Authorization'], isNull);
    });

    testWidgets('shows a spinner while the request is running', (tester) async {
      backend.holdProjectList = Completer<void>();
      await pumpApp(tester);
      // pumpAndSettle would keep advancing time while the spinner animates,
      // until the request timed out, so pump just past the page transition.
      await tester.tap(find.widgetWithText(ItemCard, 'View Projects'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('OH26'), findsNothing);

      backend.holdProjectList!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('OH26'), findsOneWidget);
    });

    testWidgets('shows a friendly error and recovers with Retry', (
      tester,
    ) async {
      backend.failProjectListWith = 500;
      await pumpApp(tester);
      await tapCard(tester, 'View Projects');

      expect(find.text('Failed to load projects'), findsOneWidget);
      expect(
        find.text('The server ran into an error. Please try again later.'),
        findsOneWidget,
      );
      // The raw response body is never shown.
      expect(find.textContaining('Traceback'), findsNothing);

      backend.failProjectListWith = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load projects'), findsNothing);
      expect(find.text('OH26'), findsOneWidget);
    });

    testWidgets('an empty list can still be pulled to refresh', (tester) async {
      backend = FakeBackend(projects: []);
      await pumpApp(tester);
      await tapCard(tester, 'View Projects');
      expect(find.text('No projects found.'), findsOneWidget);

      backend.projects.add({...FakeBackend.defaultProjects.first});
      await tester.fling(
        find.text('No projects found.'),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('No projects found.'), findsNothing);
      expect(find.text('OH26'), findsOneWidget);
      expect(backend.projectListRequests, 2);
    });

    testWidgets('tapping a project opens its details with its image', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'View Projects');
      await tester.tap(find.text('OH26'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectDetailPage), findsOneWidget);
      expect(
        find.text('Recruitment landing page for OH 2026.'),
        findsOneWidget,
      );
      expect(find.text('Tailwind CSS'), findsOneWidget);
      expect(find.text('https://example.com/oh26'), findsOneWidget);
      // A static path is loaded from the Django server's static folder.
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        '${FakeBackend.baseUrl}/static/img/oh-project.webp',
      );
    });

    testWidgets('the default placeholder image is not shown', (tester) async {
      await pumpApp(tester);
      await tapCard(tester, 'View Projects');
      await tester.tap(find.text('Symbiocle'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectDetailPage), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.text('No link provided.'), findsOneWidget);
    });

    testWidgets('Add Project asks a logged-out user to log in first', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Project');

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);

      // Leaving the login screen does not open the form.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(screensInStack(ProjectFormPage), 0);
    });

    testWidgets('login validates input and rejects wrong credentials', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Project');

      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Username cannot be empty.'), findsOneWidget);
      expect(find.text('Password cannot be empty.'), findsOneWidget);
      expect(backend.requests, isEmpty);

      await submitLogin(tester, password: 'wrong-password');
      expect(find.text('Invalid username or password.'), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(authState(tester).isLoggedIn, isFalse);
    });

    testWidgets('logging in continues to the project form', (tester) async {
      await pumpApp(tester);
      await tapCard(tester, 'Add Project');
      await submitLogin(tester);

      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(authState(tester).isLoggedIn, isTrue);
    });

    testWidgets('the form validates required fields and links', (tester) async {
      await openFormLoggedIn(tester);

      await fill(tester, 'Description', 'Too short');
      await fill(tester, 'Project URL', 'not a link');
      await fill(tester, 'Project Image URL (optional)', 'ftp://x');
      await tapSave(tester);

      expect(find.text('Project title cannot be empty.'), findsOneWidget);
      expect(find.text('Add at least one technology.'), findsOneWidget);
      expect(
        find.text('Description must be at least 20 characters.'),
        findsOneWidget,
      );
      expect(
        find.text('Enter a full link starting with http:// or https://'),
        findsNWidgets(2),
      );
      expect(projectPosts(), isEmpty);
    });

    testWidgets('validates the whole form on a short screen', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await openFormLoggedIn(tester);
      // Leave the title empty and fill everything below it, so the title is
      // scrolled out of view when Save is pressed.
      await fill(tester, 'Description', 'Flutter client for my portfolio.');
      await fill(tester, 'Tech stack', 'Flutter, Dart');
      await fill(tester, 'Project URL', 'https://example.com');
      await tapSave(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsNothing);
      expect(projectPosts(), isEmpty);
      expect(
        find.text('Project title cannot be empty.', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('a valid project is sent to Django and listed', (tester) async {
      await openFormLoggedIn(tester);
      await fillValidProject(tester);
      await tapSave(tester);

      final post = projectPosts().single;
      expect(post.headers['Authorization'], 'Token ${authState(tester).token}');
      expect(post.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(post.body), {
        'title': 'MyPortfolio Mobile',
        'description': 'Flutter client for my personal portfolio website.',
        'tech_stack': 'Flutter, Dart',
        'demo_link': null,
        'image': '',
      });

      // The dialog shows what the server saved, then OK clears the form.
      final dialog = find.byType(AlertDialog);
      for (final line in [
        'Project added successfully!',
        'Title: MyPortfolio Mobile',
        'Tech stack: Flutter, Dart',
        'Description: Flutter client for my personal portfolio website.',
        'Project URL: -',
        'Image: -',
      ]) {
        expect(
          find.descendant(of: dialog, matching: find.text(line)),
          findsOneWidget,
        );
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(dialog, findsNothing);
      for (final field in tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      )) {
        expect(field.controller!.text, isEmpty);
      }

      await openDrawerAndTap(tester, 'View Projects');
      await tester.scrollUntilVisible(find.text('MyPortfolio Mobile'), 200);
      expect(find.text('MyPortfolio Mobile'), findsOneWidget);
    });

    testWidgets('the list reloads after adding a project from its button', (
      tester,
    ) async {
      await pumpApp(tester);
      await logIn(tester);
      await tapCard(tester, 'View Projects');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await fillValidProject(tester);
      await tapSave(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(ProjectListPage), findsOneWidget);
      expect(backend.projectListRequests, 2);
      await tester.scrollUntilVisible(find.text('MyPortfolio Mobile'), 200);
      expect(find.text('MyPortfolio Mobile'), findsOneWidget);
    });

    testWidgets('a rejected token logs out and asks to log in again', (
      tester,
    ) async {
      await openFormLoggedIn(tester);
      await fillValidProject(tester);
      backend.revokeAllTokens();

      await tapSave(tester);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(authState(tester).isLoggedIn, isFalse);

      await submitLogin(tester);
      // The save is retried with the new token and succeeds.
      expect(projectPosts(), hasLength(2));
      expect(find.text('Project added successfully!'), findsOneWidget);
      expect(backend.projects.last['title'], 'MyPortfolio Mobile');
    });

    testWidgets('a logged-in visitor is told only the owner can add', (
      tester,
    ) async {
      await pumpApp(tester);
      await logIn(tester, username: FakeBackend.visitorUsername);
      await tapCard(tester, 'Add Project');
      await fillValidProject(tester);
      await tapSave(tester);

      expect(
        find.text('Only the portfolio owner can add projects.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(authState(tester).isLoggedIn, isTrue);
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
      await logIn(tester);
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
        'Login',
      ]) {
        expect(
          find.descendant(of: drawer, matching: find.text(entry)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: drawer, matching: find.text('Logout')),
        findsNothing,
      );
    });

    testWidgets('Login and Logout entries follow the session', (tester) async {
      await pumpApp(tester);
      await openDrawerAndTap(tester, 'Login');
      expect(find.byType(LoginPage), findsOneWidget);
      await submitLogin(tester);

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('Logged in successfully.'), findsOneWidget);

      await openDrawerAndTap(tester, 'Logout');
      expect(authState(tester).isLoggedIn, isFalse);
      expect(backend.tokens, isEmpty);
      expect(find.text('You have been logged out.'), findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);
    });

    testWidgets('Add Project in the drawer asks to log in first', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawerAndTap(tester, 'Add Project');
      expect(find.byType(LoginPage), findsOneWidget);

      await submitLogin(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);
    });

    testWidgets('Home returns to the existing home screen', (tester) async {
      await pumpApp(tester);
      await logIn(tester);
      await openDrawerAndTap(tester, 'Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);

      await openDrawerAndTap(tester, 'Home');

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(screensInStack(MyHomePage), 1);
      expect(screensInStack(ProjectFormPage), 0);
    });

    testWidgets('never stacks the same screen twice', (tester) async {
      await pumpApp(tester);
      await logIn(tester);
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
      await logIn(tester);
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

    testWidgets('Logout says so when nobody is logged in', (tester) async {
      await pumpApp(tester);
      await tapCard(tester, 'Logout');
      // tapCard clears the card's SnackBar, so show the next one again.
      await tester.tap(find.widgetWithText(ItemCard, 'Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsNothing);
      expect(find.text("You're not logged in."), findsOneWidget);
    });

    testWidgets('Logout asks for confirmation and can be cancelled', (
      tester,
    ) async {
      await pumpApp(tester);
      await logIn(tester);
      await tapCard(tester, 'Logout');

      expect(find.text('Log out?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(authState(tester).isLoggedIn, isTrue);
    });

    testWidgets('confirming logout revokes the token on the server', (
      tester,
    ) async {
      await pumpApp(tester);
      await logIn(tester);
      final token = authState(tester).token;
      await tapCard(tester, 'Logout');

      await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
      await tester.pumpAndSettle();

      final logout = backend.requests.last;
      expect(logout.url.path, '/api/v1/auth/logout/');
      expect(logout.headers['Authorization'], 'Token $token');
      expect(backend.tokens, isEmpty);
      expect(authState(tester).isLoggedIn, isFalse);
      expect(find.text('You have been logged out.'), findsOneWidget);
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
