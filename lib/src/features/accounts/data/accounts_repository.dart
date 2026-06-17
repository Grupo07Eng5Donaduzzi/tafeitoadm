import '../../../core/result/result.dart';
import '../domain/account_models.dart';
import 'accounts_remote_data_source.dart';

class AccountsRepository {
  const AccountsRepository(this.remoteDataSource);

  final AccountsRemoteDataSource remoteDataSource;

  Future<Result<List<AdminAccount>>> fetchAccounts() {
    return remoteDataSource.fetchAccounts();
  }

  Future<Result<AdminAccount>> fetchAccount(String id) {
    return remoteDataSource.fetchAccount(id);
  }

  Future<Result<AdminAccount>> updateAccount(AdminAccount account) {
    return remoteDataSource.updateAccount(account);
  }

  Future<Result<AdminAccount>> suspendAccount(String id, String reason) {
    return remoteDataSource.suspendAccount(id, reason);
  }

  Future<Result<AdminAccount>> restoreAccount(String id, String reason) {
    return remoteDataSource.restoreAccount(id, reason);
  }

  Future<Result<AdminAccount>> deleteAccount(String id, String reason) {
    return remoteDataSource.deleteAccount(id, reason);
  }
}
