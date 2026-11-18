import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/theme/app_colors.dart';

/// The screens that can be opened from the drawer.
enum DrawerDestination { home, projects, addProject }

/// Navigation menu that slides in from the left of every main screen.
class LeftDrawer extends StatelessWidget {
  /// The screen this drawer belongs to. Its entry is highlighted, and tapping
  /// it only closes the drawer instead of opening the same screen again.
  final DrawerDestination current;

  const LeftDrawer({super.key, required this.current});

  void _navigate(BuildContext context, DrawerDestination destination) {
    final navigator = Navigator.of(context);

    // The open drawer is part of the current route, so pop() closes it.
    navigator.pop();
    if (destination == current) return;

    // The home screen is always the first route, because MaterialApp starts
    // the stack with it. Going back to it instead of pushing a new home
    // screen avoids having two home screens in the stack.
    bool isHome(Route<dynamic> route) => route.isFirst;

    if (destination == DrawerDestination.home) {
      navigator.popUntil(isHome);
      return;
    }

    // Remove every screen above home, then open the new one on top of it.
    // The stack is always [home, destination], so Back returns to home and
    // the same screen is never stacked twice.
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => destination == DrawerDestination.projects
            ? const ProjectListPage()
            : const ProjectFormPage(),
      ),
      isHome,
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required DrawerDestination destination,
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: destination == current,
      onTap: () => _navigate(context, destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: AppColors.bgCreamLight,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.maroonMain),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'MyPortfolio',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.cream,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Explore my projects and experiences!',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.creamLight,
                  ),
                ),
              ],
            ),
          ),
          _buildTile(
            context,
            destination: DrawerDestination.home,
            icon: Icons.home_outlined,
            label: 'Home',
          ),
          _buildTile(
            context,
            destination: DrawerDestination.projects,
            icon: Icons.folder_outlined,
            label: 'View Projects',
          ),
          _buildTile(
            context,
            destination: DrawerDestination.addProject,
            icon: Icons.add_circle_outline,
            label: 'Add Project',
          ),
        ],
      ),
    );
  }
}
