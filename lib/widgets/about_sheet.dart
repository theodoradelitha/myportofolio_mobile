import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/portfolio_data.dart';
import 'package:myportofolio_mobile/widgets/portfolio_star.dart';

class AboutSheet extends StatelessWidget {
  final String name;

  const AboutSheet({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
        children: [
          Text(
            name,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            PortfolioData.roles.join(' • '),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 32.0),
          Text('Experience', style: textTheme.titleLarge),
          for (final experience in PortfolioData.experiences)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const PortfolioStar(size: 22.0),
              title: Text(
                experience.title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.category.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                  Text(experience.description),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
