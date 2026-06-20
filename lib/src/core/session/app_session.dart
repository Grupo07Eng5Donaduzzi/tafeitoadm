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

enum AdminSection { accounts, chats, payments, audit }

extension AdminSectionDetails on AdminSection {
  String get title {
    return switch (this) {
      AdminSection.accounts => 'Contas',
      AdminSection.chats => 'Chats',
      AdminSection.payments => 'Pagamentos',
      AdminSection.audit => 'Auditoria',
    };
  }

  IconData get icon {
    return switch (this) {
      AdminSection.accounts => Icons.people_alt_outlined,
      AdminSection.chats => Icons.forum_outlined,
      AdminSection.payments => Icons.payments_outlined,
      AdminSection.audit => Icons.fact_check_outlined,
    };
  }
}

class AppSession extends ChangeNotifier {
  AdminUser? _currentUser;
  AdminSection _selectedSection = AdminSection.accounts;

  AdminUser? get currentUser => _currentUser;
  AdminSection get selectedSection => _selectedSection;
  bool get isAuthenticated => _currentUser != null;
  String get token => _currentUser?.token ?? '';

  void signIn(AdminUser user) {
    _currentUser = user;
    _selectedSection = AdminSection.accounts;
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    _selectedSection = AdminSection.accounts;
    notifyListeners();
  }

  void selectSection(AdminSection section) {
    if (_selectedSection == section) {
      return;
    }

    _selectedSection = section;
    notifyListeners();
  }
}
