import 'package:material_ui/material_ui.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 6.0),
            _fitValue(
              Text(
                content,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Multi-word values (like a full name) wrap at spaces. A single long word
  /// (like the NPM) would be split mid-number on narrow screens, so it is
  /// scaled down to fit instead.
  Widget _fitValue(Widget text) {
    if (content.contains(' ')) return text;
    return FittedBox(fit: BoxFit.scaleDown, child: text);
  }
}
