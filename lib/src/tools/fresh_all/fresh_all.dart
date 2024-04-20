part of 'bloc.dart';

class FreshAll extends Runner {
  FreshAll(this.options) {
    assert(
      o.sourceDirectory != null && o.sourceDirectory!.existsSync(),
      'A source path `${o.sourcePath}` should be exists.',
    );
  }

  @override
  String get name => 'Fresh All';

  /// See [o].
  final FreshAllOptions options;

  /// Alias for [options].
  FreshAllOptions get o => options;

  /// Reads and constructs files from [sourcePath] and copies its to
  /// the projects folders.
  @override
  Future<ResultRunner> run() async {
    final bloc = FreshAllBloc(options);

    // 1) Receiving all maintained projects.
    firstStep();
    {
      printis('Receiving all maintained projects');

      const event = GettingFreshProjectsEvent();
      final key = '$event';
      bloc.add(event);
      await bloc.completed(key);

      final all = bloc.state.projects.map((p) => '$p').toList();
      pr('Maintained projects: $all');
    }

    // 2) For each maintained projects.
    nextStep();
    {
      for (final project in bloc.state.projects) {
        if (o.filter.isEmpty || o.filter.contains(project.id)) {
          await _freshProject(project, bloc);
        } else {
          printi('\nProject `${project.id}` skipped by filter.');
        }
      }
    }

    nextStep();
    late final FreshAllResultRunner r;
    // 3) Preparing results.
    {
      printis('Preparing results');
      r = FreshAllResultRunner(ok: true, state: bloc.state);
      printi('Result prepared');
    }

    return r;
  }

  Future<void> _freshProject(
    FreshProject project,
    FreshAllBloc bloc,
  ) async {
    _freshProjectFiles(project, bloc);
    // TODO _upgradeProjectDependencies(project, bloc);
  }

  Future<void> _freshProjectFiles(
    FreshProject project,
    FreshAllBloc bloc,
  ) async {
    pr('\nFreshing the files for project `$project`...');
    increaseCurrentIndent();

    bloc.add(FreshingProjectFilesEvent(project: project));
    await bloc.completed(project.key);

    decreaseCurrentIndent();
    pr('Freshed the files for project `$project`.');
  }

  Future<void> _upgradeProjectDependencies(
    FreshProject project,
    FreshAllBloc bloc,
  ) async {
    pr('\nUpgrading dependencies for project `$project`...');
    increaseCurrentIndent();

    bloc.add(UpgradingProjectDependenciesEvent(project: project));
    await bloc.completed(project.key);

    decreaseCurrentIndent();
    pr('Upgrading dependencies for project `$project`.');
  }
}
