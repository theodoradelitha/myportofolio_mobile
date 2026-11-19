import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/portfolio_data.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/theme/app_colors.dart';
import 'package:myportofolio_mobile/widgets/about_sheet.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/profile_header.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const String npm = "2506553585";
  static const String nama = "Delitha Theodora";
  static const String kelas = "PBP KKI";

  static const List<ItemHomepage> items = [
    ItemHomepage(
      "View Projects",
      Icons.folder,
      AppColors.maroonMain,
      onTap: _openProjectList,
    ),
    ItemHomepage(
      "Add Project",
      Icons.add_circle,
      AppColors.olive,
      onTap: _openProjectForm,
    ),
    ItemHomepage(
      "Add Experience",
      Icons.work,
      AppColors.vintageBurgundy,
      onTap: _openExperienceForm,
    ),
    ItemHomepage(
      "About Me",
      Icons.person,
      AppColors.maroonMuted,
      onTap: _showAboutSheet,
    ),
    ItemHomepage(
      "Logout",
      Icons.logout,
      AppColors.maroonWineRed,
      onTap: _confirmLogout,
    ),
  ];

  static void _openProjectList(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProjectListPage()));
  }

  static void _openProjectForm(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProjectFormPage()));
  }

  // push() keeps the home screen underneath, so the system Back button and
  // the AppBar's back arrow both return to it.
  static void _openExperienceForm(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ExperienceFormPage()));
  }

  static void _showAboutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const AboutSheet(name: nama),
    );
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of MyPortfolio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            // Destructive action, styled like `.button-danger` on the website.
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroonWineRed,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // There is no login yet, so be upfront instead of pretending to log out.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Logout will work once the app is connected to Django '
            'authentication.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('MyPortfolio')),
      drawer: const LeftDrawer(current: DrawerDestination.home),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Keeps the layout readable when running on wide web/desktop windows.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InfoCard(title: 'NPM', content: npm),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Name', content: nama),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Class', content: kelas),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                const ProfileHeader(name: nama, roles: PortfolioData.roles),
                const SizedBox(height: 24.0),
                Text(
                  'Quick Actions',
                  style: textTheme.titleLarge?.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: textTheme.titleLarge?.color,
                    decorationThickness: 2.0,
                  ),
                ),
                const SizedBox(height: 12.0),
                const _ActionGrid(items: items),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final List<ItemHomepage> items;

  const _ActionGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // A card needs about 135 px of width for its label, so phones get
        // 2 columns, wider screens 3, and at the full 720 px content width
        // all five actions fit on one row.
        final crossAxisCount = switch (constraints.maxWidth) {
          >= 720 => 5,
          >= 440 => 3,
          _ => 2,
        };

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.2,
          // The page itself scrolls, so the grid only needs to size itself.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: items.map((item) => ItemCard(item)).toList(),
        );
      },
    );
  }
}
