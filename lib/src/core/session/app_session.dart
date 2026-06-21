// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token = '',
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
}

enum AdminSection { accounts, payments, audit }

extension AdminSectionDetails on AdminSection {
  String get title {
    return switch (this) {
      AdminSection.accounts => 'Contas',
      AdminSection.payments => 'Pagamentos',
      AdminSection.audit => 'Auditoria',
    };
  }

  IconData get icon {
    return switch (this) {
      AdminSection.accounts => Icons.people_alt_outlined,
      AdminSection.payments => Icons.payments_outlined,
      AdminSection.audit => Icons.fact_check_outlined,
    };
  }
}

class AppSession extends ChangeNotifier {
  AppSession() {
    _restoreFromStorage();
  }

  static const _kToken = 'adm_token';
  static const _kId = 'adm_id';
  static const _kName = 'adm_name';
  static const _kEmail = 'adm_email';
  static const _kRole = 'adm_role';

  AdminUser? _currentUser;
  AdminSection _selectedSection = AdminSection.accounts;

  AdminUser? get currentUser => _currentUser;
  AdminSection get selectedSection => _selectedSection;
  bool get isAuthenticated => _currentUser != null;
  String get token => _currentUser?.token ?? '';

  void _restoreFromStorage() {
    final token = html.window.localStorage[_kToken];
    if (token == null || token.isEmpty) return;
    _currentUser = AdminUser(
      id: html.window.localStorage[_kId] ?? '',
      name: html.window.localStorage[_kName] ?? '',
      email: html.window.localStorage[_kEmail] ?? '',
      role: html.window.localStorage[_kRole] ?? '',
      token: token,
    );
  }

  void signIn(AdminUser user) {
    _currentUser = user;
    _selectedSection = AdminSection.accounts;
    html.window.localStorage[_kToken] = user.token;
    html.window.localStorage[_kId] = user.id;
    html.window.localStorage[_kName] = user.name;
    html.window.localStorage[_kEmail] = user.email;
    html.window.localStorage[_kRole] = user.role;
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    _selectedSection = AdminSection.accounts;
    html.window.localStorage.remove(_kToken);
    html.window.localStorage.remove(_kId);
    html.window.localStorage.remove(_kName);
    html.window.localStorage.remove(_kEmail);
    html.window.localStorage.remove(_kRole);
    notifyListeners();
  }

  void selectSection(AdminSection section) {
    if (_selectedSection == section) return;
    _selectedSection = section;
    notifyListeners();
  }
}
