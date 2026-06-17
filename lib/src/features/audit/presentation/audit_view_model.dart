import 'package:flutter/foundation.dart';

import '../data/audit_repository.dart';
import '../domain/audit_models.dart';

class AuditViewModel extends ChangeNotifier {
  AuditViewModel(this._repository);

  final AuditRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AuditLog> _logs = [];
  String? _adminFilter;
  String? _typeFilter;
  int? _periodDays;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get adminFilter => _adminFilter;
  String? get typeFilter => _typeFilter;
  int? get periodDays => _periodDays;

  List<String> get admins {
    final values = _logs.map((log) => log.admin).toSet().toList()..sort();
    return values;
  }

  List<String> get actionTypes {
    final values = _logs.map((log) => log.actionType).toSet().toList()..sort();
    return values;
  }

  List<AuditLog> get filteredLogs {
    final now = DateTime.now();
    return _logs.where((log) {
      final matchesAdmin = _adminFilter == null || log.admin == _adminFilter;
      final matchesType = _typeFilter == null || log.actionType == _typeFilter;
      final matchesPeriod =
          _periodDays == null ||
          log.createdAt.isAfter(now.subtract(Duration(days: _periodDays!)));
      return matchesAdmin && matchesType && matchesPeriod;
    }).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchAuditLogs();
    result.when(
      success: (logs) => _logs = logs,
      failure: (failure) => _errorMessage = failure.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  void updateAdminFilter(String? value) {
    _adminFilter = value;
    notifyListeners();
  }

  void updateTypeFilter(String? value) {
    _typeFilter = value;
    notifyListeners();
  }

  void updatePeriod(int? value) {
    _periodDays = value;
    notifyListeners();
  }
}
