import 'package:flutter/foundation.dart';

import '../../../core/session/app_session.dart';
import '../data/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository, this._session);

  final AuthRepository _repository;
  final AppSession _session;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.login(email: email, password: password);
    var didLogin = false;

    result.when(
      success: (admin) {
        _session.signIn(admin);
        didLogin = true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
    return didLogin;
  }
}
