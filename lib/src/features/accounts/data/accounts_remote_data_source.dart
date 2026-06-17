import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../domain/account_models.dart';

abstract class AccountsRemoteDataSource {
  Future<Result<List<AdminAccount>>> fetchAccounts();
  Future<Result<AdminAccount>> fetchAccount(String id);
  Future<Result<AdminAccount>> updateAccount(AdminAccount account);
  Future<Result<AdminAccount>> suspendAccount(String id, String reason);
  Future<Result<AdminAccount>> restoreAccount(String id, String reason);
  Future<Result<AdminAccount>> deleteAccount(String id, String reason);
}

class MockAccountsRemoteDataSource implements AccountsRemoteDataSource {
  MockAccountsRemoteDataSource(this.apiClient) {
    _accounts = _seedAccounts();
  }

  final ApiClient apiClient;

  static const usersPath = '/v1/admin/users';
  static const userDetailPath = '/v1/admin/users/:id';
  static const suspendPath = '/v1/admin/users/:id/suspend';
  static const restorePath = '/v1/admin/users/:id/restore';

  late final List<AdminAccount> _accounts;
  String? lastAdminNote;

  @override
  Future<Result<List<AdminAccount>>> fetchAccounts() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return Success(List<AdminAccount>.from(_accounts));
  }

  @override
  Future<Result<AdminAccount>> fetchAccount(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final account = _accounts.where((account) => account.id == id).firstOrNull;
    if (account == null) {
      return const Failure(AppFailure(message: 'Conta não encontrada.'));
    }
    return Success(account);
  }

  @override
  Future<Result<AdminAccount>> updateAccount(AdminAccount account) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return Success(_replace(account));
  }

  @override
  Future<Result<AdminAccount>> suspendAccount(String id, String reason) async {
    lastAdminNote = reason;
    return _changeStatus(id, AccountStatus.suspenso);
  }

  @override
  Future<Result<AdminAccount>> restoreAccount(String id, String reason) async {
    lastAdminNote = reason;
    return _changeStatus(id, AccountStatus.ativo);
  }

  @override
  Future<Result<AdminAccount>> deleteAccount(String id, String reason) async {
    lastAdminNote = reason;
    return _changeStatus(id, AccountStatus.excluido);
  }

  Future<Result<AdminAccount>> _changeStatus(
    String id,
    AccountStatus status,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final account = _accounts.where((account) => account.id == id).firstOrNull;
    if (account == null) {
      return const Failure(AppFailure(message: 'Conta não encontrada.'));
    }
    return Success(_replace(account.copyWith(status: status)));
  }

  AdminAccount _replace(AdminAccount next) {
    final index = _accounts.indexWhere((account) => account.id == next.id);
    if (index >= 0) {
      _accounts[index] = next;
    }
    return next;
  }

  List<AdminAccount> _seedAccounts() {
    final now = DateTime.now();
    return [
      AdminAccount(
        id: 'USR-1001',
        name: 'Marina Lopes',
        email: 'marina.lopes@email.com',
        document: '123.456.789-10',
        status: AccountStatus.ativo,
        registeredAt: now.subtract(const Duration(days: 210)),
        lastAccess: now.subtract(const Duration(hours: 4)),
        paymentKey: null,
        services: const [],
        relatedPayments: const ['PAY-8721', 'PAY-8610'],
        relatedChats: const ['CHT-2101', 'CHT-1984'],
      ),
      AdminAccount(
        id: 'USR-1002',
        name: 'RJ Reformas',
        email: 'atendimento@rjreformas.com',
        document: '38.912.210/0001-40',
        status: AccountStatus.ativo,
        registeredAt: now.subtract(const Duration(days: 186)),
        lastAccess: now.subtract(const Duration(hours: 1)),
        paymentKey: 'pix@rjreformas.com',
        services: const ['Reparo elétrico', 'Pintura', 'Instalação hidráulica'],
        relatedPayments: const ['PAY-8721', 'PAY-8690'],
        relatedChats: const ['CHT-2101'],
      ),
      AdminAccount(
        id: 'USR-1003',
        name: 'Caio Mendes',
        email: 'caio.mendes@email.com',
        document: '422.019.318-77',
        status: AccountStatus.suspenso,
        registeredAt: now.subtract(const Duration(days: 80)),
        lastAccess: now.subtract(const Duration(days: 2)),
        paymentKey: null,
        services: const [],
        relatedPayments: const ['PAY-8702'],
        relatedChats: const ['CHT-2070'],
      ),
      AdminAccount(
        id: 'USR-1004',
        name: 'Casa Limpa Pro',
        email: 'financeiro@casalimpapro.com',
        document: '21.402.117/0001-99',
        status: AccountStatus.ativo,
        registeredAt: now.subtract(const Duration(days: 132)),
        lastAccess: now.subtract(const Duration(hours: 10)),
        paymentKey: '21999123456',
        services: const ['Limpeza pós-obra', 'Faxina recorrente'],
        relatedPayments: const ['PAY-8715', 'PAY-8702'],
        relatedChats: const ['CHT-2070', 'CHT-2044'],
      ),
      AdminAccount(
        id: 'USR-1005',
        name: 'Helena Duarte',
        email: 'helena.duarte@email.com',
        document: '090.551.778-32',
        status: AccountStatus.ativo,
        registeredAt: now.subtract(const Duration(days: 44)),
        lastAccess: now.subtract(const Duration(minutes: 42)),
        paymentKey: null,
        services: const [],
        relatedPayments: const ['PAY-8718'],
        relatedChats: const ['CHT-2088'],
      ),
      AdminAccount(
        id: 'USR-1006',
        name: 'Moveis Ágeis',
        email: 'agenda@moveisageis.com',
        document: '17.303.883/0001-61',
        status: AccountStatus.excluido,
        registeredAt: now.subtract(const Duration(days: 320)),
        lastAccess: now.subtract(const Duration(days: 19)),
        paymentKey: 'moveisageis@pix.com',
        services: const ['Montagem de móveis', 'Desmontagem para mudança'],
        relatedPayments: const ['PAY-8718'],
        relatedChats: const ['CHT-2088'],
      ),
    ];
  }
}
