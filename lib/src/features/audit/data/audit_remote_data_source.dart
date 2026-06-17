import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../domain/audit_models.dart';

abstract class AuditRemoteDataSource {
  Future<Result<List<AuditLog>>> fetchAuditLogs();
}

class MockAuditRemoteDataSource implements AuditRemoteDataSource {
  const MockAuditRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  static const auditLogsPath = '/v1/admin/audit-logs';

  @override
  Future<Result<List<AuditLog>>> fetchAuditLogs() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final now = DateTime.now();

    return Success([
      AuditLog(
        id: 'AUD-9104',
        admin: 'Admin Luiza',
        actionType: 'pagamento',
        description: 'Admin Luiza liberou pagamento PAY-8672',
        target: 'PAY-8672',
        createdAt: now.subtract(const Duration(minutes: 28)),
      ),
      AuditLog(
        id: 'AUD-9103',
        admin: 'Admin Camila',
        actionType: 'conta',
        description: 'Admin Camila suspendeu conta USR-1003',
        target: 'USR-1003',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AuditLog(
        id: 'AUD-9102',
        admin: 'Admin Rafael',
        actionType: 'chat',
        description: 'Admin Rafael marcou chat CHT-2044 como revisado',
        target: 'CHT-2044',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      AuditLog(
        id: 'AUD-9101',
        admin: 'Admin Camila',
        actionType: 'pagamento',
        description: 'Admin Camila abriu disputa no pagamento PAY-8718',
        target: 'PAY-8718',
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      AuditLog(
        id: 'AUD-9100',
        admin: 'Admin Luiza',
        actionType: 'chat',
        description: 'Admin Luiza sinalizou conversa CHT-2101',
        target: 'CHT-2101',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      AuditLog(
        id: 'AUD-9099',
        admin: 'Admin Rafael',
        actionType: 'conta',
        description: 'Admin Rafael recuperou conta USR-1006',
        target: 'USR-1006',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ]);
  }
}
