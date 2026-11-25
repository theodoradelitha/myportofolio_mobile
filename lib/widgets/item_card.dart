import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/theme/app_colors.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: const Color(0x40000000),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: AppColors.cream.withValues(alpha: 0.2),
        highlightColor: AppColors.cream.withValues(alpha: 0.1),
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("You pressed the ${item.name} button!")),
            );
          item.onTap?.call(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: AppColors.cream, size: 32.0),
              const SizedBox(height: 8.0),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
