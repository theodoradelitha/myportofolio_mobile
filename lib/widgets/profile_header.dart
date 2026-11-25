import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/portfolio_star.dart';

/// Welcome section modelled on the hero of my portfolio website: a serif
/// heading, outlined role chips and two tilted stars on the sides.
class ProfileHeader extends StatelessWidget {
  final String name;
  final List<String> roles;

  const ProfileHeader({super.key, required this.name, required this.roles});

  static const double _starTilt = 15 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      // Pass the full width through so the content is centered on the page,
      // not shrunk to its own width at the top-left of the Stack.
      fit: StackFit.passthrough,
      children: [
        const Positioned(
          top: 0,
          left: 0,
          child: PortfolioStar(size: 36.0, angle: -_starTilt),
        ),
        const Positioned(
          right: 0,
          bottom: 0,
          child: PortfolioStar(size: 42.0, angle: _starTilt),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
          child: Column(
            children: [
              Text(
                'Welcome to MyPortfolio Mobile!',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 4.0),
              Text(
                "Hi, I'm $name.",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                runSpacing: 8.0,
                children: roles.map((role) => Chip(label: Text(role))).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
