import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/dashboard_models.dart';
import 'dashboard_view_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({required this.viewModel, super.key});

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.summary == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = viewModel.summary;
        if (summary == null) {
          return _ErrorState(
            message: viewModel.errorMessage ?? 'Não foi possível carregar.',
            onRetry: viewModel.load,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetricsGrid(summary: summary),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1080;
                final panels = [
                  _DisputesPanel(disputes: summary.latestDisputes),
                  _PendingPaymentsPanel(payments: summary.pendingPayments),
                  _RecentAccountsPanel(accounts: summary.recentAccounts),
                ];

                if (!wide) {
                  return Column(
                    children: [
                      for (final panel in panels) ...[
                        panel,
                        const SizedBox(height: 16),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final panel in panels) ...[
                      Expanded(child: panel),
                      if (panel != panels.last) const SizedBox(width: 16),
                    ],
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      StatCard(
        label: 'Usuários totais',
        value: summary.totalUsers.toString(),
        subtitle: 'Base completa do app',
        icon: Icons.groups_outlined,
        color: AppColors.primary,
      ),
      StatCard(
        label: 'Contas ativas',
        value: summary.activeAccounts.toString(),
        subtitle: 'Com acesso liberado',
        icon: Icons.verified_user_outlined,
        color: AppColors.success,
      ),
      StatCard(
        label: 'Usuários com serviços',
        value: summary.usersWithServices.toString(),
        subtitle: 'Oferecem algum serviço',
        icon: Icons.home_repair_service_outlined,
        color: AppColors.info,
      ),
      StatCard(
        label: 'Contas suspensas/excluídas',
        value: summary.blockedAccounts.toString(),
        subtitle: 'Exigem acompanhamento',
        icon: Icons.block_outlined,
        color: AppColors.danger,
      ),
      StatCard(
        label: 'Pagamentos retidos',
        value: summary.heldPayments.toString(),
        subtitle: 'Aguardando decisão',
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.warning,
      ),
      StatCard(
        label: 'Disputas abertas',
        value: summary.openDisputes.toString(),
        subtitle: 'Casos em análise',
        icon: Icons.gavel_outlined,
        color: AppColors.danger,
      ),
      StatCard(
        label: 'Chats sinalizados',
        value: summary.flaggedChats.toString(),
        subtitle: 'Conversas para revisão',
        icon: Icons.report_outlined,
        color: AppColors.warning,
      ),
      StatCard(
        label: 'Volume financeiro retido',
        value: AppFormatters.currency(summary.heldVolume),
        subtitle: 'Total sob retenção',
        icon: Icons.savings_outlined,
        color: AppColors.primary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1180
            ? 4
            : constraints.maxWidth >= 720
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 132,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) => metrics[index],
        );
      },
    );
  }
}

class _DisputesPanel extends StatelessWidget {
  const _DisputesPanel({required this.disputes});

  final List<DisputePreview> disputes;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Últimas disputas',
      icon: Icons.gavel_outlined,
      children: [
        for (final dispute in disputes)
          _PanelRow(
            title: '${dispute.id} · ${dispute.service}',
            subtitle: '${dispute.customer} x ${dispute.provider}',
            trailing: AppFormatters.dateTime(dispute.openedAt),
          ),
      ],
    );
  }
}

class _PendingPaymentsPanel extends StatelessWidget {
  const _PendingPaymentsPanel({required this.payments});

  final List<PaymentPreview> payments;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Pagamentos aguardando decisão',
      icon: Icons.payments_outlined,
      children: [
        for (final payment in payments)
          _PanelRow(
            title: '${payment.id} · ${AppFormatters.currency(payment.amount)}',
            subtitle: '${payment.customer} → ${payment.provider}',
            badge: StatusBadge(status: payment.status, compact: true),
          ),
      ],
    );
  }
}

class _RecentAccountsPanel extends StatelessWidget {
  const _RecentAccountsPanel({required this.accounts});

  final List<AccountPreview> accounts;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Contas recentes',
      icon: Icons.person_add_alt_1_outlined,
      children: [
        for (final account in accounts)
          _PanelRow(
            title: account.name,
            subtitle: account.email,
            trailing: AppFormatters.dateTime(account.createdAt),
          ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final child in children) child,
          ],
        ),
      ),
    );
  }
}

class _PanelRow extends StatelessWidget {
  const _PanelRow({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String? trailing;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (badge != null)
            badge!
          else if (trailing != null)
            Text(
              trailing!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
