import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/data/portfolio_data.dart';

class AboutSheet extends StatelessWidget {
  final String name;

  const AboutSheet({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
        children: [
          Text(
            name,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(PortfolioData.roles.join(' • '), style: textTheme.bodyMedium),
          const SizedBox(height: 20.0),
          Text(
            'Experience',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          for (final experience in PortfolioData.experiences)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.work_outline),
              title: Text(experience.title),
              subtitle: Text(
                '${experience.category} · ${experience.description}',
              ),
            ),
        ],
      ),
    );
  }
}
