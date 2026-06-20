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

class ApiAccountsRemoteDataSource implements AccountsRemoteDataSource {
  const ApiAccountsRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<Result<List<AdminAccount>>> fetchAccounts() async {
    final result = await apiClient.get('/v1/admin/users');
    return result.when(
      success: (json) {
        final rawList = _extractList(json);
        final accounts = rawList
            .map((e) => _fromJson(e as Map<String, dynamic>))
            .toList();
        return Success(accounts);
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<AdminAccount>> fetchAccount(String id) async {
    final all = await fetchAccounts();
    return all.when(
      success: (list) {
        final account = list.where((a) => a.id == id).firstOrNull;
        if (account == null) {
          return const Failure(AppFailure(message: 'Conta não encontrada.'));
        }
        return Success(account);
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<AdminAccount>> updateAccount(AdminAccount account) async {
    return Success(account);
  }

  @override
  Future<Result<AdminAccount>> suspendAccount(String id, String reason) async {
    final patch = await apiClient.patch('/v1/admin/users/$id/deactivate');
    final ok = patch.when(success: (_) => true, failure: (_) => false);
    if (!ok) {
      final msg = patch.when(
        success: (_) => 'Erro desconhecido.',
        failure: (f) => f.message,
      );
      return Failure(AppFailure(message: msg));
    }
    final acc = await fetchAccount(id);
    return acc.when(
      success: (a) => Success(a.copyWith(status: AccountStatus.suspenso)),
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<AdminAccount>> restoreAccount(String id, String reason) async {
    final patch = await apiClient.patch('/v1/admin/users/$id/activate');
    final ok = patch.when(success: (_) => true, failure: (_) => false);
    if (!ok) {
      final msg = patch.when(
        success: (_) => 'Erro desconhecido.',
        failure: (f) => f.message,
      );
      return Failure(AppFailure(message: msg));
    }
    final acc = await fetchAccount(id);
    return acc.when(
      success: (a) => Success(a.copyWith(status: AccountStatus.ativo)),
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<AdminAccount>> deleteAccount(String id, String reason) async {
    return suspendAccount(id, reason);
  }

  AdminAccount _fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'active';
    final AccountStatus status =
        statusStr == 'suspended' ? AccountStatus.suspenso : AccountStatus.ativo;

    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();

    return AdminAccount(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      document: json['identification'] as String? ?? '',
      status: status,
      registeredAt: createdAt,
      lastAccess: createdAt,
      paymentKey: json['pixKey'] as String?,
      services: const [],
      relatedPayments: const [],
      relatedChats: const [],
    );
  }

  static List<dynamic> _extractList(Map<String, dynamic> json) {
    if (json['data'] is List) return json['data'] as List<dynamic>;
    return <dynamic>[];
  }
}
