/// A body of work for one client, made up of milestones.
///
/// Projects exist to group and label; they hold no money of their own. Every
/// amount in the app is attached to a milestone, so a project total is always a
/// sum over its children and can never disagree with them.
class Project {
  const Project({
    required this.id,
    required this.clientId,
    required this.name,
    required this.defaultSourceId,
    required this.defaultCurrency,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.externalRef,
    this.archivedAt,
  });

  final String id;
  final String clientId;
  final String name;
  final String? description;

  /// Source prefilled when adding a milestone here.
  ///
  /// Only a form default. The milestone's own `sourceId` is what every report
  /// reads, so changing this later never rewrites history.
  final String defaultSourceId;

  /// Currency prefilled when adding a milestone here, for the same reason.
  final String defaultCurrency;

  /// The platform's own identifier — an Upwork contract id, a Fiverr order id.
  ///
  /// Module 3 uses this to attach an incoming statement row or notification to
  /// the right project without asking the user.
  final String? externalRef;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Set instead of deleting, for the same history-preserving reason as
  /// [Client.archivedAt].
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  Project copyWith({
    String? name,
    String? description,
    bool clearDescription = false,
    String? defaultSourceId,
    String? defaultCurrency,
    String? externalRef,
    bool clearExternalRef = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      clientId: clientId,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      defaultSourceId: defaultSourceId ?? this.defaultSourceId,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      externalRef: clearExternalRef ? null : (externalRef ?? this.externalRef),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  @override
  bool operator ==(Object other) => other is Project && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
