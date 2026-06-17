import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../domain/dashboard_models.dart';

abstract class DashboardRemoteDataSource {
  Future<Result<DashboardSummary>> fetchDashboard();
}

class MockDashboardRemoteDataSource implements DashboardRemoteDataSource {
  const MockDashboardRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  static const dashboardPath = '/v1/admin/dashboard';

  @override
  Future<Result<DashboardSummary>> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final now = DateTime.now();

    return Success(
      DashboardSummary(
        totalUsers: 18472,
        activeAccounts: 16421,
        usersWithServices: 3924,
        blockedAccounts: 86,
        heldPayments: 43,
        openDisputes: 8,
        flaggedChats: 12,
        heldVolume: 18740.50,
        latestDisputes: [
          DisputePreview(
            id: 'DSP-1048',
            customer: 'Marina Lopes',
            provider: 'RJ Reformas',
            service: 'Reparo elétrico',
            openedAt: now.subtract(const Duration(hours: 2)),
          ),
          DisputePreview(
            id: 'DSP-1047',
            customer: 'Caio Mendes',
            provider: 'Casa Limpa Pro',
            service: 'Limpeza pós-obra',
            openedAt: now.subtract(const Duration(hours: 6)),
          ),
          DisputePreview(
            id: 'DSP-1046',
            customer: 'Fernanda Lima',
            provider: 'Auto Chave Sul',
            service: 'Chaveiro residencial',
            openedAt: now.subtract(const Duration(days: 1, hours: 3)),
          ),
        ],
        pendingPayments: const [
          PaymentPreview(
            id: 'PAY-8721',
            customer: 'Marina Lopes',
            provider: 'RJ Reformas',
            amount: 680,
            status: 'retido',
          ),
          PaymentPreview(
            id: 'PAY-8718',
            customer: 'Helena Duarte',
            provider: 'Moveis Ágeis',
            amount: 1240,
            status: 'disputa',
          ),
          PaymentPreview(
            id: 'PAY-8709',
            customer: 'Paulo Neri',
            provider: 'Pintura Fina',
            amount: 910,
            status: 'cliente_confirmou',
          ),
        ],
        recentAccounts: [
          AccountPreview(
            name: 'Ana Beatriz',
            email: 'ana@exemplo.com',
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
          AccountPreview(
            name: 'Tec Lar Serviços',
            email: 'contato@teclar.com',
            createdAt: now.subtract(const Duration(hours: 9)),
          ),
          AccountPreview(
            name: 'João Pereira',
            email: 'joao@exemplo.com',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),
    );
  }
}
