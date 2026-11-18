# MyPortfolio Mobile

**Name:** Delitha Theodora  
**NPM:** 2506553585  
**Class:** PBP KKI  

MyPortfolio Mobile is the Flutter client for my personal portfolio website (built with Django in Assignments 1–6). It shows my identity, my portfolio projects and experience, and lets me draft new projects from my phone. In a later tutorial it will be connected to the Django REST API (`/api/v1/`) I built in Tutorial 07.

---

## Features

- **Profile info cards:** three `InfoCard`s showing my NPM, full name and class.
- **Welcome header:** styled like the hero section of my website, with a serif greeting, my roles (Front-End Developer, UI/UX Design, UX Researcher) as outlined chips, and two tilted stars on the sides.
- **Action menu:** four `ItemCard`s, each with its own icon and background color from my website's palette (maroon, olive, dusty rose and wine red). Every tap shows a `SnackBar`: *"You pressed the [Button Name] button!"*
  - **View Projects:** opens a list of my portfolio projects (OH26, DDP026, Symbiocle) with tech-stack chips.
  - **Add Project:** a validated form (title, category dropdown, tech stack, description, optional link). Saving shows the entered data in a dialog and clears the form. Saved projects also show up in View Projects, marked *Not synced* because they are kept in memory only.
  - **About Me:** a bottom sheet with my roles and experience.
  - **Logout:** a confirmation dialog. There is no login yet, so confirming tells the user that logout will be connected to Django authentication later instead of pretending to log out.
- **Drawer navigation:** a `LeftDrawer` on every screen with Home, View Projects and Add Project. Home goes back to the existing home screen, and other screens open on top of home, so the same screen is never stacked twice.
- **Design matching my portfolio website:** the same maroon and cream palette (`AppColors`, named after the CSS variables of the website), the same fonts (Butler for headings, TT Chocolates for body text, Genty for project titles), outlined chips and the star decoration from the website. All of it is set up once in `AppTheme`, so the widgets don't hardcode their own styles.
- **Responsive layout:** the page scrolls, the content is width-capped on web/desktop, the action grid switches between 2 and 4 columns, and the layout is tested at 320×640 without overflow.
- **Widget tests** for all of the above, plus a check that the cream text on every action card meets the WCAG AA contrast ratio.

## Tech Stack

- Flutter 3.47 (stable), Dart 3.13
- Material 3 with a custom theme in `lib/theme/` (`AppColors` + `AppTheme`) built from my website's palette
- Custom fonts (Butler, TT Chocolates, Genty) bundled as assets and declared in `pubspec.yaml`. The files were converted from the woff2 fonts used on my website.
- `material_ui` for the Material widgets (the package the Material library moves to in Flutter 3.50). No other third-party packages besides the defaults from `flutter create`

## Setup & Running

1. Install the Flutter SDK and check your environment with `flutter doctor`.
2. Clone the repository and open the folder:
   ```bash
   git clone https://github.com/theodoradelitha/myportofolio_mobile.git
   cd myportofolio_mobile
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app (Chrome is the quickest target):
   ```bash
   flutter run -d chrome
   ```
   You can also use an Android emulator or a connected device with `flutter run`.
5. Check code quality and run the tests:
   ```bash
   flutter analyze
   flutter test
   ```

## Project Structure

```
lib/
├── main.dart                     # Entry point: MyApp and MaterialApp (uses AppTheme)
├── models/
│   ├── item_homepage.dart        # Action card data: name, icon, color, optional action
│   ├── project.dart              # Project data model
│   └── experience.dart           # Experience data model
├── data/
│   ├── portfolio_data.dart       # Static content copied from my Django portfolio
│   └── project_store.dart        # In-memory project list shared between pages
├── screens/
│   ├── menu.dart                 # MyHomePage (StatelessWidget) and its action grid
│   ├── project_list_page.dart    # View Projects page
│   └── project_form_page.dart    # Add Project form (StatefulWidget) and its dialog
├── theme/
│   ├── app_colors.dart           # Color palette from my website's CSS variables
│   └── app_theme.dart            # ThemeData: colors, fonts and component styles
└── widgets/
    ├── info_card.dart            # InfoCard
    ├── item_card.dart            # ItemCard (InkWell + SnackBar)
    ├── left_drawer.dart          # Drawer menu for moving between screens
    ├── profile_header.dart       # Welcome header with role chips and stars
    ├── project_card.dart         # Card for one project
    ├── about_sheet.dart          # About Me bottom sheet
    └── portfolio_star.dart       # Star decoration from my website (CustomPainter)
assets/
└── fonts/
    ├── butler/                   # Heading font
    ├── tt_chocolates/            # Body font
    └── genty/                    # Display font for project titles
test/
└── widget_test.dart              # Widget tests and a color contrast test
```

---

## Weekly Progress

- **Tutorial 08:** Installed Flutter, created the `myportofolio_mobile` project, split `MyHomePage` into `menu.dart`, changed it to a `StatelessWidget`, and built the `InfoCard` and `ItemCard` widgets from the tutorial.
- **Assignment 7:** Replaced the sample data with my own identity, gave every action card its own color through the `ItemHomepage` model, made the layout responsive, and added working View Projects, Add Project (with validation), About Me and Logout-confirmation flows. Moved reusable widgets and models into their own folders, switched the UI text to English, and replaced the default counter test with widget tests. Restyled the app to match my portfolio website: its color palette, fonts (Butler, TT Chocolates, Genty), chip and card styles, and the star decoration, all centralized in `AppTheme`. The work was done on the `feat/assignment-seven` branch with Conventional Commits.
- **Tutorial 09:** Added a `LeftDrawer` for navigating between Home, View Projects and Add Project, extended the Add Project form with a category `DropdownButtonFormField` and an optional, validated project link, showed the submitted data in an `AlertDialog` that resets the form, moved `menu.dart` into `screens/`, and switched the Material imports to `material_ui`. The work was done on the `feat/tutorial-nine` branch.
  - **Navigation choices:** `Navigator.push()` opens View Projects and Add Project from the home cards and the list's button, so Back returns to the previous screen. `Navigator.pop()` closes the drawer and the dialog. The drawer does not use `pushReplacement(MyHomePage())` like the tutorial example, because opening Home that way from another screen leaves two home screens in the stack. Instead, Home uses `popUntil` to go back to the existing home screen, and the other entries use `pushAndRemoveUntil`, so the stack is always home plus one screen.

---

### Assignment 7

**1. Widget tree and parent-child relationships**

Everything in Flutter is a widget, and widgets are nested inside each other, so the whole UI ends up as a tree. Every widget except the root has one parent. The parent tells its child how much space it's allowed to use (the constraints), the child picks its own size within that, and then the parent decides where to place it. A widget can also read things that an ancestor provides higher up in the tree, like the theme.

This is the main tree of my home page (I left out the `SizedBox` spacers):

```
MyApp
└── MaterialApp (theme: AppTheme.light)
    └── MyHomePage
        └── Scaffold
            ├── AppBar
            └── SingleChildScrollView
                └── Center
                    └── ConstrainedBox (maxWidth: 720)
                        └── Column
                            ├── IntrinsicHeight → Row → 3× Expanded → InfoCard
                            ├── ProfileHeader
                            ├── Text ("Quick Actions")
                            └── _ActionGrid → LayoutBuilder → GridView.count → 4× ItemCard
```

A few places where the parent-child relationship actually mattered in my code:
- `ConstrainedBox` caps its child at 720 px, so on a wide browser window the content doesn't stretch across the whole screen.
- Each `Expanded` forces its `InfoCard` to take exactly one third of the `Row`. `IntrinsicHeight` makes all three cards as tall as the tallest one. That matters because my name wraps onto two lines and the NPM doesn't.
- The `GridView` sits inside a `SingleChildScrollView`, which gives it unlimited height. A scrollable grid can't size itself with unlimited height, so I set `shrinkWrap: true` (only as tall as its items) and `NeverScrollableScrollPhysics` (the page scrolls, not the grid).
- `ItemCard` calls `Theme.of(context)` to get its text style. It can do that because `MaterialApp`, an ancestor, provides the theme.

**2. Widgets used in this project**

*App structure*
- `MaterialApp`: the root of the app. It sets the theme and handles navigation.
- `Scaffold`: the basic page layout (app bar + body) on every page.
- `AppBar`: the maroon top bar with the page title (MyPortfolio, My Projects, Add Project).
- `SafeArea`: keeps the About Me sheet away from the notch and the home indicator.

*Layout*
- `Column` / `Row`: stack widgets vertically / horizontally.
- `Expanded`: makes the three InfoCards share the row width equally.
- `IntrinsicHeight`: keeps the InfoCards the same height. I also use it in the info note on the projects page so the accent bar is as tall as the text.
- `Center`, `Padding`, `SizedBox`: alignment, inner spacing, and fixed gaps.
- `ConstrainedBox`: limits the content to 720 px wide.
- `SingleChildScrollView`: lets the home page scroll on small screens.
- `LayoutBuilder`: reads the available width so the action grid can switch between 2 and 4 columns.
- `GridView.count`: the grid of action cards.
- `ListView`: the scrollable content on the project list, the form, and the About Me sheet.
- `Wrap`: lays out the role chips and tech-stack chips and moves them to the next line when there's no room.
- `Stack` + `Positioned`: place the two stars at the corners of the welcome section, behind the text.
- `Container`: the info note on the projects page (cream box, border, and the burgundy accent bar).
- `FittedBox`: shrinks the NPM slightly on very narrow screens instead of breaking the number in half.

*Content and styling*
- `Text`, `Icon`: text and icons.
- `Card`: the cream surface of the InfoCards and project cards.
- `Chip`: my roles on the home page and the tech stack of each project.
- `ListTile`: each experience entry in the About Me sheet.
- `Divider`: the line under my roles in the About Me sheet.
- `CustomPaint`, `Transform`: used inside `PortfolioStar` to draw the star from my website and to rotate or mirror it.

*Interaction*
- `Material` + `InkWell`: give each action card its own background color and rounded shape, and show the ripple when it's tapped.
- `SnackBar` (shown with `ScaffoldMessenger`): the "You pressed the ... button!" message and the other short notices.
- `AlertDialog` (opened with `showDialog`) with a `TextButton` (Cancel) and a `FilledButton` (Logout): the logout confirmation.
- `showModalBottomSheet`: opens the About Me sheet.
- `Navigator` + `MaterialPageRoute`: open the project list and the Add Project form.
- `FloatingActionButton.extended`: the "Add Project" shortcut on the project list.

*Forms and state*
- `Form` + `TextFormField`: the Add Project inputs and their validators.
- `FilledButton.icon`: the Save Project button.
- `ValueListenableBuilder`: rebuilds the project list whenever `ProjectStore.projects` changes.

*My own widgets*
- `MyApp`, `MyHomePage`, `InfoCard`, `ItemCard`, `ProfileHeader`, `PortfolioStar`, `ProjectCard`, `AboutSheet`, `ProjectListPage` and `ProjectFormPage`.
- The private helpers `_ActionGrid` (in `menu.dart`) and `_DataSourceNote` (in `project_list_page.dart`).

**3. Purpose of `MaterialApp`**

`MaterialApp` is the root of my app (`MyApp` returns it), and it sets up everything the Material widgets underneath it depend on:
- **Theme:** I pass `theme: AppTheme.light`, which holds my website's colors and fonts and the styles for the AppBar, cards, buttons, inputs, chips and SnackBars. Every widget below can read it with `Theme.of(context)`. That's why my widgets don't have colors hardcoded everywhere.
- **Navigation:** it creates the `Navigator`, so I can push the project list and the form as new pages and get a back button for free.
- **SnackBars:** it creates a `ScaffoldMessenger` above the `Navigator`. Because of that, when I tap "View Projects", the "You pressed..." SnackBar stays visible even though a new page opens right after it.
- **Other basics:** text direction and localizations, which widgets like `TextFormField` and `AlertDialog` need.

If I removed it, widgets like `Scaffold`, `AppBar` and `TextFormField` would complain about missing ancestors. That's why it's normally the root widget: it sets all of this up once for the whole app.

**4. `StatelessWidget` vs `StatefulWidget`**

A `StatelessWidget` doesn't keep any data that changes. What it shows depends only on what's passed into its constructor plus what it reads from above (like the theme). A `StatefulWidget` comes with a separate `State` object that survives rebuilds, so it can hold data that changes, call `setState()` to redraw, and use lifecycle methods like `initState()` and `dispose()`.

Most of my app is stateless:
- `MyHomePage`, `InfoCard` and `ItemCard` only display data that doesn't change while the page is open.
- In `MyHomePage`, the NPM, name, class and the list of `ItemHomepage` items are all `static const`, so the page itself can be created with `const MyHomePage()`.

`ProjectFormPage` is my only `StatefulWidget`. Its `State` owns three `TextEditingController`s and a `GlobalKey<FormState>`. These have to stay the same object across rebuilds, otherwise the text I typed would be lost. The controllers also have to be cleaned up, which I do in `dispose()`. I don't actually call `setState()` in the form: the validation messages are handled by the `Form` itself when I call `_formKey.currentState!.validate()`.

The project list works differently. The projects live in `ProjectStore.projects`, a `ValueNotifier<List<Project>>`. `ProjectListPage` stays stateless and uses a `ValueListenableBuilder` to listen to it. When I save a project, `ProjectStore.add()` assigns a *new* list to `projects.value`. Assigning a new list is what notifies the listeners, so the list page rebuilds and shows the new project. Adding to the old list in place wouldn't trigger it.

**5. `BuildContext`**

`BuildContext` is basically a widget's position in the widget tree, and Flutter passes it into every `build` method. Methods like `Theme.of(context)`, `Navigator.of(context)` and `ScaffoldMessenger.of(context)` use that position to look upward and find the nearest ancestor of that type. So which context you use matters, not just that you have one.

How I use it in my app:
- **Theme:** `InfoCard`, `ItemCard`, `ProfileHeader`, `ProjectCard`, `AboutSheet` and `PortfolioStar` all call `Theme.of(context)` for their colors and text styles.
- **SnackBar and actions:** in `ItemCard`, `onTap` first calls `ScaffoldMessenger.of(context)` to show the SnackBar. Then it passes the same `context` into the card's action (`item.onTap?.call(context)`). That's how the static methods in `MyHomePage`, like `_openProjectList`, can call `Navigator.of(context).push(...)` even though they aren't inside a `build` method.
- **Inside a `State`:** in `ProjectFormPage`, the `State` has its own `context`. I use it to show the "added" SnackBar and to `pop()` back after saving.
- **Two contexts in the logout dialog:** `showDialog` gives the builder its own `dialogContext`, and I use that one to close the dialog with `Navigator.of(dialogContext).pop(true)`.
- **`context.mounted`:** `_confirmLogout` is `async` and waits for the dialog with `await showDialog(...)`. While it's waiting, the page could be removed from the tree. So after the `await`, I check `if (confirmed != true || !context.mounted) return;` before using `context` again to show the SnackBar.

**6. Hot reload vs hot restart**

**Hot reload** (`r` in the terminal) injects my changed code into the running app and rebuilds the widgets, but keeps the current state. If I'm on the Add Project form with some text typed in and I change a padding or a color, the change shows up right away and I'm still on the same page with my text still there.

**Hot restart** (`R`) loads the new code too, but throws away all the state and runs the app again from `main()`. I end up back on the home page, and anything kept only in memory is gone. For example, projects I added through the form disappear, because `ProjectStore` only stores them in memory.

Hot reload isn't enough when the change is in code that only runs once:
- **`main()`:** hot reload doesn't run it again.
- **Static fields that are already created:** `ProjectStore.projects` is a static `ValueNotifier` that gets its starting list from `PortfolioData.projects` the first time it's used (for example, when I open View Projects). After that, hot reload won't recreate it. So if I edit the project data in `PortfolioData`, the list keeps showing the old projects until I do a hot restart.

A **full restart** (stopping the app and running `flutter run` again) is needed when the change isn't Dart code at all and has to be built into the app:
- native Android or iOS files, like `AndroidManifest.xml` or Gradle settings;
- changes to `pubspec.yaml`, like adding a package. My fonts are also declared there, so after adding new font files the safest option is to rebuild the app.

---

### AI Disclosure & Reflection (Assignment 7)

**1. Tools Used:** Claude (Claude Code, running in VS Code)

**2. Prompting Strategy:**

For this assignment, I mainly used AI as a learning assistant while implementing the Flutter application myself. Since I was still unfamiliar with some Flutter concepts, I asked questions whenever I encountered something I did not understand. Instead of immediately asking AI to write the code for me, I focused on understanding the concepts, asking for explanations using examples from my own project, and getting guidance on how to implement certain features. I also used it to debug errors, review my code, and understand why certain approaches worked better than others.

**3. Specific Assisted Parts:**

- **Understanding Flutter Concepts:** I asked AI to explain concepts such as the widget tree, `StatelessWidget` vs `StatefulWidget`, `BuildContext`, and how Flutter handles rebuilding widgets. I also asked for examples based on my own implementation so I could understand how these concepts were applied.

- **Widget Composition & Layout:** I consulted AI when deciding how to structure my widgets, reuse components, and organize my Flutter files. I also asked about different layout widgets and how to make the application responsive.

- **State Management:** I asked AI to explain how `ValueNotifier` and `ValueListenableBuilder` work together, particularly how changes to the project list can be reflected in the UI without using `setState()`.

- **Navigation & User Interactions:** I used AI to clarify how navigation works with `Navigator` and `MaterialPageRoute`, as well as how to implement interactions such as SnackBars, dialogs, and form validation.

- **Debugging & Testing:** When I encountered errors or unexpected behavior, I shared the relevant code or error messages and asked AI to help identify the cause. This included debugging widget tests and understanding issues related to `pumpWidget()` and `ListView` lazy loading.

- **UI Styling:** I consulted AI on how to translate the visual design of my existing Django portfolio into Flutter, particularly its color palette, typography, spacing, and overall design consistency.

**4. Critical Analysis of AI Limitations & Manual Fixes:**

- **Understanding Before Implementation:** Sometimes AI provided solutions without fully explaining the reasoning behind them. I had to ask follow-up questions to understand what the code actually did instead of simply copying the suggested solution.

- **Context and Requirements:** Some initial suggestions did not fully match my requirements. For example, I had to clarify that the application and README should use English rather than Indonesian.

- **Debugging:** AI suggestions were not always immediately correct. My widget tests initially failed due to issues involving repeated `pumpWidget()` calls and the lazy building behavior of `ListView`. I had to investigate the errors and understand the suggested fixes before applying them.

- **Git Workflow:** Claude initially suggested merging the feature branch into `main`, which I did not want to do. I clarified that I wanted to keep the branch separate and handle the merge myself.

- **Independent Implementation:** Although AI helped me understand concepts and troubleshoot problems, I still needed to write the code, adapt the suggestions to my project, and make implementation decisions myself. I found that asking questions and understanding the reasoning behind a solution was more useful than simply accepting code without knowing how it worked.

**5. Prompting History/Log:**

- `i dont really understand how the widget tree works. can you explain it using my own app?`

- `what's the difference between statelesswidget and statefulwidget? how do i know which one i should use?`

- `can you explain what buildcontext actually does? im still confused about how it works`

- `how does valuenotifier work with valuelistenablebuilder? can you walk me through the process?`

- `im trying to make this layout responsive. what widgets should i use and why?`

- `can you give me a hint on how to implement this instead of writing the whole code for me?`

- `im getting this error. can you explain why it happens and help me figure out how to fix it?`

- `why isnt my widget test finding the project? can you explain how listview builds its children?`

- `can you review my code and tell me if there are any problems or things i should improve?`

- `can you quiz me about my code so i can understand how it works better?`