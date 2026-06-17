import 'package:flutter/material.dart';

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;
}

enum AdminSection { dashboard, accounts, chats, payments, audit }

extension AdminSectionDetails on AdminSection {
  String get title {
    return switch (this) {
      AdminSection.dashboard => 'Dashboard',
      AdminSection.accounts => 'Contas',
      AdminSection.chats => 'Chats',
      AdminSection.payments => 'Pagamentos',
      AdminSection.audit => 'Auditoria',
    };
  }

  IconData get icon {
    return switch (this) {
      AdminSection.dashboard => Icons.dashboard_outlined,
      AdminSection.accounts => Icons.people_alt_outlined,
      AdminSection.chats => Icons.forum_outlined,
      AdminSection.payments => Icons.payments_outlined,
      AdminSection.audit => Icons.fact_check_outlined,
    };
  }
}

class AppSession extends ChangeNotifier {
  AdminUser? _currentUser;
  AdminSection _selectedSection = AdminSection.dashboard;

  AdminUser? get currentUser => _currentUser;
  AdminSection get selectedSection => _selectedSection;
  bool get isAuthenticated => _currentUser != null;

  void signIn(AdminUser user) {
    _currentUser = user;
    _selectedSection = AdminSection.dashboard;
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    _selectedSection = AdminSection.dashboard;
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
