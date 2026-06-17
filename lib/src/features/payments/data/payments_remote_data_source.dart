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

class MockPaymentsRemoteDataSource implements PaymentsRemoteDataSource {
  MockPaymentsRemoteDataSource(this.apiClient) {
    _payments = _seedPayments();
  }

  final ApiClient apiClient;

  static const paymentsPath = '/v1/admin/payments';
  static const paymentDetailPath = '/v1/admin/payments/:id';
  static const refundPath = '/v1/admin/payments/:id/refund';
  static const releasePath = '/v1/admin/payments/:id/release';
  static const disputePath = '/v1/admin/payments/:id/dispute';
  static const resolvePath = '/v1/admin/payments/:id/resolve';

  late final List<AdminPayment> _payments;

  @override
  Future<Result<List<AdminPayment>>> fetchPayments() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return Success(List<AdminPayment>.from(_payments));
  }

  @override
  Future<Result<AdminPayment>> fetchPayment(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final payment = _find(id);
    if (payment == null) {
      return const Failure(AppFailure(message: 'Pagamento não encontrado.'));
    }
    return Success(payment);
  }

  @override
  Future<Result<AdminPayment>> refund(String id, String reason) {
    return _changeStatus(
      id,
      PaymentStatus.estornado,
      'Devolvido para contratante',
      reason,
    );
  }

  @override
  Future<Result<AdminPayment>> release(String id, String reason) {
    return _changeStatus(
      id,
      PaymentStatus.liberado,
      'Liberado para executor',
      reason,
    );
  }

  @override
  Future<Result<AdminPayment>> openDispute(String id, String reason) {
    return _changeStatus(id, PaymentStatus.disputa, 'Disputa aberta', reason);
  }

  @override
  Future<Result<AdminPayment>> resolve(String id, String reason) {
    return _changeStatus(
      id,
      PaymentStatus.prestadorConfirmou,
      'Marcado como resolvido',
      reason,
    );
  }

  Future<Result<AdminPayment>> _changeStatus(
    String id,
    PaymentStatus status,
    String title,
    String reason,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final payment = _find(id);
    if (payment == null) {
      return const Failure(AppFailure(message: 'Pagamento não encontrado.'));
    }

    final updated = payment.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      events: [
        PaymentEvent(
          title: title,
          description: reason,
          createdAt: DateTime.now(),
          admin: 'Admin',
        ),
        ...payment.events,
      ],
    );

    return Success(_replace(updated));
  }

  AdminPayment? _find(String id) {
    for (final payment in _payments) {
      if (payment.id == id) {
        return payment;
      }
    }
    return null;
  }

  AdminPayment _replace(AdminPayment next) {
    final index = _payments.indexWhere((payment) => payment.id == next.id);
    if (index >= 0) {
      _payments[index] = next;
    }
    return next;
  }

  List<AdminPayment> _seedPayments() {
    final now = DateTime.now();
    return [
      AdminPayment(
        id: 'PAY-8721',
        customer: 'Marina Lopes',
        provider: 'RJ Reformas',
        service: 'Reparo elétrico',
        amount: 680,
        status: PaymentStatus.retido,
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
        updatedAt: now.subtract(const Duration(minutes: 40)),
        chatId: 'CHT-2101',
        evidences: const [
          'Contratante anexou foto do quadro sem acabamento.',
          'Executor informou conclusão parcial no chat.',
        ],
        events: [
          PaymentEvent(
            title: 'Pagamento retido',
            description: 'Contratante abriu contestação após a visita.',
            createdAt: now.subtract(const Duration(hours: 5)),
            admin: 'Sistema',
          ),
          PaymentEvent(
            title: 'Pagamento criado',
            description: 'Pagamento autorizado no app.',
            createdAt: now.subtract(const Duration(days: 2, hours: 4)),
            admin: 'Sistema',
          ),
        ],
      ),
      AdminPayment(
        id: 'PAY-8718',
        customer: 'Helena Duarte',
        provider: 'Moveis Ágeis',
        service: 'Montagem de móveis',
        amount: 310,
        status: PaymentStatus.disputa,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 1)),
        chatId: 'CHT-2088',
        evidences: const [
          'Contratante relata pedido de pagamento por fora.',
          'Executor informou falta de peças.',
        ],
        events: [
          PaymentEvent(
            title: 'Disputa aberta',
            description: 'Conversa sinalizada por possível conduta irregular.',
            createdAt: now.subtract(const Duration(days: 1, hours: 1)),
            admin: 'Admin Luiza',
          ),
        ],
      ),
      AdminPayment(
        id: 'PAY-8709',
        customer: 'Paulo Neri',
        provider: 'Pintura Fina',
        service: 'Pintura de quarto',
        amount: 910,
        status: PaymentStatus.clienteConfirmou,
        createdAt: now.subtract(const Duration(days: 5, hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 9)),
        chatId: 'CHT-2061',
        evidences: const ['Contratante confirmou conclusão pelo app.'],
        events: [
          PaymentEvent(
            title: 'Contratante confirmou',
            description: 'Aguardando confirmação de quem executou.',
            createdAt: now.subtract(const Duration(hours: 9)),
            admin: 'Sistema',
          ),
        ],
      ),
      AdminPayment(
        id: 'PAY-8690',
        customer: 'Bruno Alves',
        provider: 'RJ Reformas',
        service: 'Instalação hidráulica',
        amount: 1240,
        status: PaymentStatus.servicoEmAndamento,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 3)),
        chatId: 'CHT-2031',
        evidences: const ['Executor iniciou o serviço e enviou checklist.'],
        events: [
          PaymentEvent(
            title: 'Serviço em andamento',
            description: 'Check-in do executor registrado no app.',
            createdAt: now.subtract(const Duration(days: 3)),
            admin: 'Sistema',
          ),
        ],
      ),
      AdminPayment(
        id: 'PAY-8672',
        customer: 'Rafaela Prado',
        provider: 'Casa Limpa Pro',
        service: 'Faxina recorrente',
        amount: 220,
        status: PaymentStatus.liberado,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 10)),
        chatId: 'CHT-2044',
        evidences: const ['As duas partes confirmaram conclusão.'],
        events: [
          PaymentEvent(
            title: 'Liberado para executor',
            description: 'Fluxo automático após dupla confirmação.',
            createdAt: now.subtract(const Duration(days: 10)),
            admin: 'Sistema',
          ),
        ],
      ),
    ];
  }
}
