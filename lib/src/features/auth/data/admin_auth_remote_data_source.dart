import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../../../core/session/app_session.dart';

abstract class AdminAuthRemoteDataSource {
  Future<Result<AdminUser>> login({
    required String email,
    required String password,
  });
}

class ApiAdminAuthRemoteDataSource implements AdminAuthRemoteDataSource {
  const ApiAdminAuthRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  static const _loginPath = '/v1/admin/auth/login';

  @override
  Future<Result<AdminUser>> login({
    required String email,
    required String password,
  }) async {
    final result = await apiClient.post(
      _loginPath,
      body: {'email': email, 'password': password},
    );

    return result.when(
      success: (json) {
        final token = json['accessToken'] as String? ?? '';
        final adminJson = json['admin'] as Map<String, dynamic>? ?? {};
        return Success(
          AdminUser(
            id: adminJson['id'] as String? ?? '',
            name: adminJson['name'] as String? ?? email.split('@').first,
            email: email,
            role: 'Admin',
            token: token,
          ),
        );
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }
}
