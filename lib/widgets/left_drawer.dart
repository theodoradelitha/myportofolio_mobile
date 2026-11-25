import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_colors.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// The screens that can be opened from the drawer.
enum DrawerDestination { home, projects, addProject, addExperience }

/// Navigation menu that slides in from the left of every main screen.
class LeftDrawer extends StatelessWidget {
  /// The screen this drawer belongs to. Its entry is highlighted, and tapping
  /// it only closes the drawer instead of opening the same screen again.
  final DrawerDestination current;

  const LeftDrawer({super.key, required this.current});

  Future<void> _navigate(
    BuildContext context,
    DrawerDestination destination,
  ) async {
    final navigator = Navigator.of(context);

    // The open drawer is part of the current route, so pop() closes it.
    navigator.pop();
    if (destination == current) return;

    // The home screen is always the first route, because MaterialApp starts
    // the stack with it. Going back to it instead of pushing a new home
    // screen avoids having two home screens in the stack.
    bool isHome(Route<dynamic> route) => route.isFirst;

    // Remove every screen above home, then open the new one on top of it.
    // The stack is always [home, page], so Back returns to home and the same
    // screen is never stacked twice.
    void openOnTopOfHome(Widget page) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => page),
        isHome,
      );
    }

    // A switch over an enum must cover every value, so adding a destination
    // without deciding where it goes is a compile error.
    switch (destination) {
      case DrawerDestination.home:
        navigator.popUntil(isHome);
      case DrawerDestination.projects:
        openOnTopOfHome(const ProjectListPage());
      case DrawerDestination.addProject:
        // Called before any await, while the drawer's context is mounted.
        // After the await only the captured navigator is used.
        if (!await ensureLoggedIn(context) || !navigator.mounted) return;
        openOnTopOfHome(const ProjectFormPage());
      case DrawerDestination.addExperience:
        openOnTopOfHome(const ExperienceFormPage());
    }
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

  Future<void> _login(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (await ensureLoggedIn(context)) {
      _showMessage(messenger, 'Logged in successfully.');
    }
  }

  Future<void> _logout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final authState = context.read<AuthState>();
    Navigator.of(context).pop();
    await authState.logout();
    _showMessage(messenger, 'You have been logged out.');
  }

  void _showMessage(ScaffoldMessengerState messenger, String message) {
    if (!messenger.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // watch (not read) so the drawer rebuilds when the user logs in or out.
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

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
          _buildTile(
            context,
            destination: DrawerDestination.addExperience,
            icon: Icons.work_outline,
            label: 'Add Experience',
          ),
          const Divider(),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => _login(context),
            ),
        ],
      ),
    );
  }
}
