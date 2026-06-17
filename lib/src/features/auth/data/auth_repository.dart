import '../../../core/result/result.dart';
import '../../../core/session/app_session.dart';
import 'admin_auth_remote_data_source.dart';

class AuthRepository {
  const AuthRepository(this.remoteDataSource);

  final AdminAuthRemoteDataSource remoteDataSource;

  Future<Result<AdminUser>> login({
    required String email,
    required String password,
  }) {
    return remoteDataSource.login(email: email, password: password);
  }
}
