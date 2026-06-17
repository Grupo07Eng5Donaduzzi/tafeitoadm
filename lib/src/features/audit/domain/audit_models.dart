class AuditLog {
  const AuditLog({
    required this.id,
    required this.admin,
    required this.actionType,
    required this.description,
    required this.target,
    required this.createdAt,
  });

  final String id;
  final String admin;
  final String actionType;
  final String description;
  final String target;
  final DateTime createdAt;
}
