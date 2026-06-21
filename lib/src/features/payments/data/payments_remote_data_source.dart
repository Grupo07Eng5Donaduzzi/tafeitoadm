import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../domain/payment_models.dart';

abstract class PaymentsRemoteDataSource {
  Future<Result<List<AdminPayment>>> fetchPayments();
  Future<Result<AdminPayment>> fetchPayment(String id);
  Future<Result<AdminPayment>> refund(String id, String reason);
  Future<Result<AdminPayment>> release(String id, String reason);
  Future<Result<AdminPayment>> openDispute(String id, String reason);
  Future<Result<AdminPayment>> resolve(String id, String reason);
}

class ApiPaymentsRemoteDataSource implements PaymentsRemoteDataSource {
  const ApiPaymentsRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<Result<List<AdminPayment>>> fetchPayments() async {
    final result = await apiClient.get('/v1/admin/payments');
    return result.when(
      success: (json) {
        final rawList = _extractList(json);
        final payments = rawList
            .map((e) => _fromJson(e as Map<String, dynamic>))
            .toList();
        return Success(payments);
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<AdminPayment>> fetchPayment(String id) async {
    final all = await fetchPayments();
    return all.when(
      success: (list) {
        final payment = list.where((p) => p.id == id).firstOrNull;
        if (payment == null) {
          return const Failure(AppFailure(message: 'Pagamento não encontrado.'));
        }
        return Success(payment);
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<AdminPayment>> refund(String id, String reason) async {
    final post = await apiClient.post(
      '/v1/admin/payments/$id/refund',
      body: {'pixKey': reason},
    );
    final ok = post.when(success: (_) => true, failure: (_) => false);
    if (!ok) {
      final msg = post.when(
        success: (_) => 'Erro desconhecido.',
        failure: (f) => f.message,
      );
      return Failure(AppFailure(message: msg));
    }
    final payment = await fetchPayment(id);
    return payment.when(
      success: (p) => Success(p.copyWith(status: PaymentStatus.estornado)),
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<AdminPayment>> release(String id, String reason) async {
    final post = await apiClient.post('/v1/admin/payments/$id/mark-paid');
    final ok = post.when(success: (_) => true, failure: (_) => false);
    if (!ok) {
      final msg = post.when(
        success: (_) => 'Erro desconhecido.',
        failure: (f) => f.message,
      );
      return Failure(AppFailure(message: msg));
    }
    final payment = await fetchPayment(id);
    return payment.when(
      success: (p) => Success(p.copyWith(status: PaymentStatus.liberado)),
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<AdminPayment>> openDispute(String id, String reason) {
    return fetchPayment(id);
  }

  @override
  Future<Result<AdminPayment>> resolve(String id, String reason) {
    return fetchPayment(id);
  }

  AdminPayment _fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'PENDING';
    final PaymentStatus status = switch (statusStr) {
      'AWAITING_PAYMENT' => PaymentStatus.aguardandoPagamento,
      'ACCEPTED' => PaymentStatus.clienteConfirmou,
      'PROVIDER_CONFIRMED' => PaymentStatus.prestadorConfirmou,
      'COMPLETED' => PaymentStatus.liberado,
      'CANCELLED' => PaymentStatus.estornado,
      _ => PaymentStatus.servicoEmAndamento,
    };

    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();
    final updatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
        : DateTime.now();

    return AdminPayment(
      id: json['id'] as String? ?? '',
      customer: json['clientName'] as String? ?? 'N/D',
      provider: json['providerName'] as String? ?? 'N/D',
      service: 'N/D',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      events: const [],
      evidences: const [],
      chatId: '',
    );
  }

  static List<dynamic> _extractList(Map<String, dynamic> json) {
    if (json['data'] is List) return json['data'] as List<dynamic>;
    return <dynamic>[];
  }
}
