import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/experience_store.dart';
import 'package:myportofolio_mobile/data/portfolio_data.dart';
import 'package:myportofolio_mobile/models/experience.dart';
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
          // Rebuilds when an experience is added from the experience form.
          ValueListenableBuilder<List<Experience>>(
            valueListenable: ExperienceStore.experiences,
            builder: (context, experiences, _) => Column(
              children: [
                for (final experience in experiences)
                  _ExperienceTile(experience: experience),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  final Experience experience;

  const _ExperienceTile({required this.experience});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final endedAt = experience.endedAt;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const PortfolioStar(size: 22.0),
      title: Text(
        experience.title,
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience.category.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary),
          ),
          // Same label as on project cards added from the app.
          if (experience.isLocalDraft)
            Text(
              'Not synced',
              style: textTheme.labelSmall?.copyWith(color: colorScheme.error),
            ),
          Text(experience.description),
          // The entries copied from my website have no dates, so only a
          // date picked in the form is shown.
          if (endedAt != null)
            Text(
              'Ended ${MaterialLocalizations.of(context).formatShortDate(endedAt)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
