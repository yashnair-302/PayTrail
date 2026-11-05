/// A person or company that owes money.
class Client {
  const Client({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.email,
    this.phone,
    this.notes,
    this.archivedAt,
  });

  final String id;
  final String name;
  final String? company;

  /// Used by the reminder engine to prefill the `mailto:` draft, and by the
  /// email parser to attribute an incoming payment to the right client.
  final String? email;

  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  ///
  /// Clients are referenced by projects, milestones and payments; a hard delete
  /// would take years of income history with it and break the tax export. The
  /// UI hides archived clients, and every aggregate query filters them out.
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  /// Name with the company appended when both are known.
  String get displayName {
    final String? trimmedCompany = company?.trim();
    if (trimmedCompany == null || trimmedCompany.isEmpty) return name;
    if (trimmedCompany == name) return name;
    return '$name · $trimmedCompany';
  }

  /// The first letter, for the avatar in the client list.
  String get initials {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  Client copyWith({
    String? name,
    String? company,
    bool clearCompany = false,
    String? email,
    bool clearEmail = false,
    String? phone,
    bool clearPhone = false,
    String? notes,
    bool clearNotes = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      company: clearCompany ? null : (company ?? this.company),
      email: clearEmail ? null : (email ?? this.email),
      phone: clearPhone ? null : (phone ?? this.phone),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  @override
  bool operator ==(Object other) => other is Client && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
