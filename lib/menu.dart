import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/data/portfolio_data.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:myportofolio_mobile/widgets/profile_header.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const String npm = "2506553585";
  static const String nama = "Delitha Theodora";
  static const String kelas = "PBP KKI";

  static const List<ItemHomepage> items = [
    ItemHomepage("View Projects", Icons.folder, Color(0xFF1976D2)),
    ItemHomepage("Add Project", Icons.add_circle, Color(0xFF2E7D32)),
    ItemHomepage("Logout", Icons.logout, Color(0xFFD32F2F)),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('MyPortfolio')),
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
                const SizedBox(height: 16.0),
                const ProfileHeader(name: nama, roles: PortfolioData.roles),
                const SizedBox(height: 24.0),
                Text(
                  'Quick Actions',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
        final crossAxisCount = constraints.maxWidth >= 560 ? 4 : 2;

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
