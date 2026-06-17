import 'package:flutter/foundation.dart';

import '../data/dashboard_repository.dart';
import '../domain/dashboard_models.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._repository);

  final DashboardRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  DashboardSummary? _summary;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardSummary? get summary => _summary;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchDashboard();
    result.when(
      success: (summary) => _summary = summary,
      failure: (failure) => _errorMessage = failure.message,
    );

    _isLoading = false;
    notifyListeners();
  }
}
