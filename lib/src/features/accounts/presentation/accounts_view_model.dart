import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../data/accounts_repository.dart';
import '../domain/account_models.dart';

class AccountsViewModel extends ChangeNotifier {
  AccountsViewModel(this._repository);

  final AccountsRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AdminAccount> _accounts = [];
  final Set<String> _selectedAccountIds = {};
  String _query = '';
  AccountStatus? _statusFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  AccountStatus? get statusFilter => _statusFilter;
  Set<String> get selectedAccountIds => Set.unmodifiable(_selectedAccountIds);
  int get selectedCount => _selectedAccountIds.length;

  List<AdminAccount> get filteredAccounts {
    final normalizedQuery = _query.trim().toLowerCase();

    return _accounts.where((account) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          account.name.toLowerCase().contains(normalizedQuery) ||
          account.email.toLowerCase().contains(normalizedQuery) ||
          account.document.toLowerCase().contains(normalizedQuery);
      final matchesStatus =
          _statusFilter == null || account.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  bool get allFilteredSelected {
    final accounts = filteredAccounts;
    return accounts.isNotEmpty &&
        accounts.every((account) => _selectedAccountIds.contains(account.id));
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchAccounts();
    result.when(
      success: (accounts) {
        _accounts = accounts;
        _selectedAccountIds.removeWhere(
          (id) => accounts.every((account) => account.id != id),
        );
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

  void updateStatusFilter(AccountStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  bool isSelected(AdminAccount account) {
    return _selectedAccountIds.contains(account.id);
  }

  void toggleAccountSelection(AdminAccount account, bool selected) {
    if (selected) {
      _selectedAccountIds.add(account.id);
    } else {
      _selectedAccountIds.remove(account.id);
    }
    notifyListeners();
  }

  void toggleAllFiltered(bool selected) {
    final accounts = filteredAccounts;
    if (selected) {
      _selectedAccountIds.addAll(accounts.map((account) => account.id));
    } else {
      _selectedAccountIds.removeAll(accounts.map((account) => account.id));
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedAccountIds.clear();
    notifyListeners();
  }

  Future<void> updateAccount(
    AdminAccount account, {
    required String name,
    required String email,
  }) {
    return _commit(
      _repository.updateAccount(account.copyWith(name: name, email: email)),
    );
  }

  Future<void> suspendAccount(AdminAccount account, String reason) {
    return _commit(_repository.suspendAccount(account.id, reason));
  }

  Future<void> restoreAccount(AdminAccount account, String reason) {
    return _commit(_repository.restoreAccount(account.id, reason));
  }

  Future<void> deleteAccount(AdminAccount account, String reason) {
    return _commit(_repository.deleteAccount(account.id, reason));
  }

  Future<void> suspendSelected(String reason) {
    return _bulkCommit(
      _selectedAccountIds.map((id) => _repository.suspendAccount(id, reason)),
    );
  }

  Future<void> deleteSelected(String reason) {
    return _bulkCommit(
      _selectedAccountIds.map((id) => _repository.deleteAccount(id, reason)),
    );
  }

  Future<void> _bulkCommit(
    Iterable<Future<Result<AdminAccount>>> requests,
  ) async {
    final ids = Set<String>.from(_selectedAccountIds);
    for (final request in requests.toList()) {
      await _commit(request, notify: false);
    }
    _selectedAccountIds.removeAll(ids);
    notifyListeners();
  }

  Future<void> _commit(
    Future<Result<AdminAccount>> request, {
    bool notify = true,
  }) async {
    final result = await request;
    result.when(
      success: (updated) {
        final index = _accounts.indexWhere((item) => item.id == updated.id);
        if (index >= 0) {
          _accounts[index] = updated;
        }
        _errorMessage = null;
      },
      failure: (failure) => _errorMessage = failure.message,
    );
    if (notify) {
      notifyListeners();
    }
  }
}
