import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../../../core/session/app_session.dart';

abstract class AdminAuthRemoteDataSource {
  Future<Result<AdminUser>> login({
    required String email,
    required String password,
  });
}

class MockAdminAuthRemoteDataSource implements AdminAuthRemoteDataSource {
  const MockAdminAuthRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  static const loginPath = '/v1/admin/auth/login';

  @override
  Future<Result<AdminUser>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));

    if (!email.contains('@') || password.length < 4) {
      return const Failure(
        AppFailure(message: 'E-mail ou senha inválidos para o acesso admin.'),
      );
    }

    return Success(
      AdminUser(
        id: 'adm_001',
        name: email.split('@').first.isEmpty ? 'Admin' : 'Admin Camila',
        email: email,
        role: 'Operações',
      ),
    );
  }
}
