import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/session/app_session.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/admin_scaffold.dart';
import 'features/accounts/data/accounts_remote_data_source.dart';
import 'features/accounts/data/accounts_repository.dart';
import 'features/accounts/presentation/accounts_screen.dart';
import 'features/accounts/presentation/accounts_view_model.dart';
import 'features/audit/data/audit_remote_data_source.dart';
import 'features/audit/data/audit_repository.dart';
import 'features/audit/presentation/audit_screen.dart';
import 'features/audit/presentation/audit_view_model.dart';
import 'features/auth/data/admin_auth_remote_data_source.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_view_model.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/chats/data/chats_remote_data_source.dart';
import 'features/chats/data/chats_repository.dart';
import 'features/chats/presentation/chats_screen.dart';
import 'features/chats/presentation/chats_view_model.dart';
import 'features/dashboard/data/dashboard_remote_data_source.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/dashboard/presentation/dashboard_view_model.dart';
import 'features/payments/data/payments_remote_data_source.dart';
import 'features/payments/data/payments_repository.dart';
import 'features/payments/presentation/payments_screen.dart';
import 'features/payments/presentation/payments_view_model.dart';

class TaFeitoAdminApp extends StatefulWidget {
  const TaFeitoAdminApp({super.key});

  @override
  State<TaFeitoAdminApp> createState() => _TaFeitoAdminAppState();
}

class _TaFeitoAdminAppState extends State<TaFeitoAdminApp> {
  late final ApiClient _apiClient;
  late final AppSession _session;
  late final AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: 'https://api.tafeito.app');
    _session = AppSession();
    _authViewModel = AuthViewModel(
      AuthRepository(MockAdminAuthRemoteDataSource(_apiClient)),
      _session,
    );
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _session.dispose();
    _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        return MaterialApp(
          title: 'TáFeito Admin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: _session.isAuthenticated
              ? AdminHome(apiClient: _apiClient, session: _session)
              : LoginScreen(viewModel: _authViewModel),
        );
      },
    );
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({required this.apiClient, required this.session, super.key});

  final ApiClient apiClient;
  final AppSession session;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late final DashboardViewModel _dashboardViewModel;
  late final AccountsViewModel _accountsViewModel;
  late final ChatsViewModel _chatsViewModel;
  late final PaymentsViewModel _paymentsViewModel;
  late final AuditViewModel _auditViewModel;

  @override
  void initState() {
    super.initState();
    _dashboardViewModel = DashboardViewModel(
      DashboardRepository(MockDashboardRemoteDataSource(widget.apiClient)),
    )..load();
    _accountsViewModel = AccountsViewModel(
      AccountsRepository(MockAccountsRemoteDataSource(widget.apiClient)),
    )..load();
    _chatsViewModel = ChatsViewModel(
      ChatsRepository(MockChatsRemoteDataSource(widget.apiClient)),
    )..load();
    _paymentsViewModel = PaymentsViewModel(
      PaymentsRepository(MockPaymentsRemoteDataSource(widget.apiClient)),
    )..load();
    _auditViewModel = AuditViewModel(
      AuditRepository(MockAuditRemoteDataSource(widget.apiClient)),
    )..load();
  }

  @override
  void dispose() {
    _dashboardViewModel.dispose();
    _accountsViewModel.dispose();
    _chatsViewModel.dispose();
    _paymentsViewModel.dispose();
    _auditViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      session: widget.session,
      child: switch (widget.session.selectedSection) {
        AdminSection.dashboard => DashboardScreen(
          viewModel: _dashboardViewModel,
        ),
        AdminSection.accounts => AccountsScreen(viewModel: _accountsViewModel),
        AdminSection.chats => ChatsScreen(viewModel: _chatsViewModel),
        AdminSection.payments => PaymentsScreen(viewModel: _paymentsViewModel),
        AdminSection.audit => AuditScreen(viewModel: _auditViewModel),
      },
    );
  }
}
