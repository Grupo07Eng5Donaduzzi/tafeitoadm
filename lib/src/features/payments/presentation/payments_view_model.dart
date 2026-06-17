import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../data/payments_repository.dart';
import '../domain/payment_models.dart';

class PaymentsViewModel extends ChangeNotifier {
  PaymentsViewModel(this._repository);

  final PaymentsRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AdminPayment> _payments = [];
  AdminPayment? _selectedPayment;
  String _query = '';
  PaymentStatus? _statusFilter;
  int? _periodDays;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdminPayment? get selectedPayment => _selectedPayment;
  String get query => _query;
  PaymentStatus? get statusFilter => _statusFilter;
  int? get periodDays => _periodDays;

  List<AdminPayment> get filteredPayments {
    final now = DateTime.now();
    final normalizedQuery = _query.trim().toLowerCase();
    return _payments.where((payment) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          payment.id.toLowerCase().contains(normalizedQuery) ||
          payment.customer.toLowerCase().contains(normalizedQuery) ||
          payment.provider.toLowerCase().contains(normalizedQuery) ||
          payment.service.toLowerCase().contains(normalizedQuery) ||
          payment.chatId.toLowerCase().contains(normalizedQuery);
      final matchesStatus =
          _statusFilter == null || payment.status == _statusFilter;
      final matchesPeriod =
          _periodDays == null ||
          payment.createdAt.isAfter(now.subtract(Duration(days: _periodDays!)));
      return matchesQuery && matchesStatus && matchesPeriod;
    }).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchPayments();
    result.when(
      success: (payments) {
        _payments = payments;
        _selectedPayment = payments.isEmpty ? null : payments.first;
      },
      failure: (failure) => _errorMessage = failure.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void updateStatusFilter(PaymentStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void updatePeriod(int? value) {
    _periodDays = value;
    notifyListeners();
  }

  void selectPayment(AdminPayment payment) {
    _selectedPayment = payment;
    notifyListeners();
  }

  Future<void> releaseSelected(String reason) {
    final payment = _selectedPayment;
    if (payment == null) {
      return Future<void>.value();
    }
    return _commit(_repository.release(payment.id, reason));
  }

  Future<void> refundSelected(String reason) {
    final payment = _selectedPayment;
    if (payment == null) {
      return Future<void>.value();
    }
    return _commit(_repository.refund(payment.id, reason));
  }

  Future<void> disputeSelected(String reason) {
    final payment = _selectedPayment;
    if (payment == null) {
      return Future<void>.value();
    }
    return _commit(_repository.openDispute(payment.id, reason));
  }

  Future<void> resolveSelected(String reason) {
    final payment = _selectedPayment;
    if (payment == null) {
      return Future<void>.value();
    }
    return _commit(_repository.resolve(payment.id, reason));
  }

  Future<void> _commit(Future<Result<AdminPayment>> request) async {
    final result = await request;
    result.when(
      success: (updated) {
        final index = _payments.indexWhere((item) => item.id == updated.id);
        if (index >= 0) {
          _payments[index] = updated;
        }
        _selectedPayment = updated;
        _errorMessage = null;
      },
      failure: (failure) => _errorMessage = failure.message,
    );
    notifyListeners();
  }
}
