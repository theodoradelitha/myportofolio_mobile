import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/data/portfolio_data.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// In-memory list of projects shared between the project pages.
///
/// Pages listen to [projects] with a ValueListenableBuilder, so a project
/// added from the form shows up in the list right away. Nothing is persisted:
/// the list resets to the portfolio projects when the app restarts.
abstract final class ProjectStore {
  static final ValueNotifier<List<Project>> projects = ValueNotifier(
    List.unmodifiable(PortfolioData.projects),
  );

  static void add(Project project) {
    projects.value = List.unmodifiable([...projects.value, project]);
  }

  @visibleForTesting
  static void reset() {
    projects.value = List.unmodifiable(PortfolioData.projects);
  }
}
