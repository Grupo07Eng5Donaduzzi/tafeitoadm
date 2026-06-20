import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../domain/audit_models.dart';

abstract class AuditRemoteDataSource {
  Future<Result<List<AuditLog>>> fetchAuditLogs();
}

class ApiAuditRemoteDataSource implements AuditRemoteDataSource {
  const ApiAuditRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<Result<List<AuditLog>>> fetchAuditLogs() async {
    final result = await apiClient.get('/v1/admin/audit');
    return result.when(
      success: (json) {
        final rawList = _extractList(json);
        final logs = rawList
            .map((e) => _fromJson(e as Map<String, dynamic>))
            .toList();
        return Success(logs);
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  AuditLog _fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();

    return AuditLog(
      id: json['id'] as String? ?? '',
      admin: json['adminName'] as String? ?? 'Admin',
      actionType: json['targetType'] as String? ?? json['action'] as String? ?? '',
      description: json['description'] as String? ?? '',
      target: json['targetId'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  static List<dynamic> _extractList(Map<String, dynamic> json) {
    if (json['data'] is List) return json['data'] as List<dynamic>;
    return <dynamic>[];
  }
}
