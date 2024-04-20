part of '../fresher.dart';

/// The package for refresh.
/// See `dart pub outdated --json`.
/// See [FreshPubspec].
class FreshPackage extends Equatable implements Comparable<FreshPackage> {
  const FreshPackage({
    required this.id,
    this.kind = '',
    this.isDiscontinued = false,
    this.currentLock = '',
    this.currentYaml = '',
    this.upgradable = '',
    this.resolvable = '',
    this.latest = '',
  }) : assert(id.length > 0);

  /// Constructs a package [id] from `yaml` file that defined by [path].
  factory FreshPackage.yamlFile(String path, String id) {
    final file = WFile(path);
    if (!file.existsFile()) {
      throw PathNotFoundException(file.npath, const OSError());
    }

    final d = loadYaml(file.readAsText()!) as YamlMap;
    final dependencies = d['dependencies'] as YamlMap;
    final devDependencies = d['dependencies'] as YamlMap;
    final v = (dependencies[id] ?? devDependencies[id]) as String?;
    if (v == null) {
      throw ArgumentError('Package `$id` not found in `$path`.', 'v');
    }

    final kind = dependencies[id] == null ? 'dev' : 'direct';

    return FreshPackage(id: id, kind: kind, currentYaml: v);
  }

  /// An ID of package on pub.dev.
  final String id;

  /// A kind of the package: dev, direct, transitive.
  /// See `dart pub outdated --json`.
  final String kind;

  final bool isDiscontinued;

  /// A current version from `pubspec.lock` file.
  final String currentLock;

  /// A current version from `pubspec.yaml` file.
  final String currentYaml;

  /// An upgradable version.
  final String upgradable;

  /// A resolvable version.
  final String resolvable;

  /// A latest version.
  /// See [getLatestVersion].
  final String latest;

  bool get hasVersionLock => currentLock.isNotEmpty;

  bool get hasVersionYaml => currentYaml.isNotEmpty;

  /// Parse a text [s] to [semver](https://semver.org/spec/v2.0.0-rc.1.html).
  /// Thanks [pub_semver](https://pub.dev/packages/pub_semver).
  /// See [tryParseSemVer].
  static Version parseSemVer(String s) => Version.parse(s);

  /// Returns `null` if [s] is not parsed to [semver](https://semver.org/spec/v2.0.0-rc.1.html).
  /// See [parseSemVer].
  static Version? tryParseSemVer(String s) {
    if (s.isEmpty) {
      return null;
    }

    try {
      return parseSemVer(s);
    } on FormatException catch (_) {
      // skip
    }

    return null;
  }

  /// A request to get the latest version from pub.dev.
  /// Thanks [pub_updater](https://pub.dev/packages/pub_updater).
  /// ! The latest is not resolvable version.
  Future<String> get getLatestVersion => PubUpdater().getLatestVersion(id);

  @override
  List<Object?> get props => [
        id,
        kind,
        isDiscontinued,
        currentLock,
        currentYaml,
        upgradable,
        resolvable,
        latest,
      ];

  /// ! Compare by [id] and [currentYaml] version.
  @override
  int compareTo(FreshPackage other) =>
      '$id $currentYaml'.compareTo('${other.id} ${other.currentYaml}');

  @override
  String toString() => props.sjsonInLine;
}