import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/data/portfolio_data.dart';
import 'package:myportofolio_mobile/models/experience.dart';

/// In-memory list of experiences, shared by the experience form and the
/// About Me sheet.
///
/// Works the same way as ProjectStore: listeners rebuild when a new list is
/// assigned to [experiences], and nothing is saved when the app closes.
abstract final class ExperienceStore {
  static final ValueNotifier<List<Experience>> experiences = ValueNotifier(
    List.unmodifiable(PortfolioData.experiences),
  );

  static void add(Experience experience) {
    // Assigning a new list (instead of adding to the old one) is what
    // notifies the listeners.
    experiences.value = List.unmodifiable([...experiences.value, experience]);
  }

  @visibleForTesting
  static void reset() {
    experiences.value = List.unmodifiable(PortfolioData.experiences);
  }
}
