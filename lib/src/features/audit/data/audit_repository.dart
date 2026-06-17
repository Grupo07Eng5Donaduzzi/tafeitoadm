import '../../../core/result/result.dart';
import '../domain/audit_models.dart';
import 'audit_remote_data_source.dart';

class AuditRepository {
  const AuditRepository(this.remoteDataSource);

  final AuditRemoteDataSource remoteDataSource;

  Future<Result<List<AuditLog>>> fetchAuditLogs() {
    return remoteDataSource.fetchAuditLogs();
  }
}
