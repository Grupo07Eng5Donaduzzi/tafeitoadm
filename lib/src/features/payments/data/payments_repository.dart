import '../../../core/result/result.dart';
import '../domain/payment_models.dart';
import 'payments_remote_data_source.dart';

class PaymentsRepository {
  const PaymentsRepository(this.remoteDataSource);

  final PaymentsRemoteDataSource remoteDataSource;

  Future<Result<List<AdminPayment>>> fetchPayments() {
    return remoteDataSource.fetchPayments();
  }

  Future<Result<AdminPayment>> fetchPayment(String id) {
    return remoteDataSource.fetchPayment(id);
  }

  Future<Result<AdminPayment>> refund(String id, String reason) {
    return remoteDataSource.refund(id, reason);
  }

  Future<Result<AdminPayment>> release(String id, String reason) {
    return remoteDataSource.release(id, reason);
  }

  Future<Result<AdminPayment>> openDispute(String id, String reason) {
    return remoteDataSource.openDispute(id, reason);
  }

  Future<Result<AdminPayment>> resolve(String id, String reason) {
    return remoteDataSource.resolve(id, reason);
  }
}
