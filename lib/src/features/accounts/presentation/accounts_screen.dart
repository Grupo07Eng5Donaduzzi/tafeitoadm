import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/account_models.dart';
import 'accounts_view_model.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({required this.viewModel, super.key});

  final AccountsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.filteredAccounts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccountsFilters(viewModel: viewModel),
            const SizedBox(height: 12),
            _BulkActionsBar(viewModel: viewModel),
            const SizedBox(height: 12),
            _AccountsTable(viewModel: viewModel),
          ],
        );
      },
    );
  }
}

class _AccountsFilters extends StatelessWidget {
  const _AccountsFilters({required this.viewModel});

  final AccountsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 520,
                child: TextField(
                  onChanged: viewModel.updateQuery,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nome, e-mail ou documento',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<AccountStatus?>(
                  initialValue: viewModel.statusFilter,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem<AccountStatus?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    for (final status in AccountStatus.values)
                      DropdownMenuItem<AccountStatus?>(
                        value: status,
                        child: Text(status.label),
                      ),
                  ],
                  onChanged: viewModel.updateStatusFilter,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.filter_list, size: 18),
                label: Text('${viewModel.filteredAccounts.length} contas'),
                side: const BorderSide(color: AppColors.border),
                backgroundColor: AppColors.background,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulkActionsBar extends StatelessWidget {
  const _BulkActionsBar({required this.viewModel});

  final AccountsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final hasSelection = viewModel.selectedCount > 0;

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                avatar: const Icon(Icons.check_box_outlined, size: 18),
                label: Text('${viewModel.selectedCount} selecionadas'),
                side: const BorderSide(color: AppColors.border),
                backgroundColor: AppColors.background,
              ),
              OutlinedButton.icon(
                onPressed: hasSelection ? viewModel.clearSelection : null,
                icon: const Icon(Icons.clear_outlined),
                label: const Text('Limpar seleção'),
              ),
              OutlinedButton.icon(
                onPressed: hasSelection
                    ? () => _confirmBulk(
                        context,
                        title: 'Suspender contas',
                        message:
                            'As contas selecionadas serão bloqueadas para uso no app.',
                        confirmLabel: 'Suspender',
                        action: viewModel.suspendSelected,
                      )
                    : null,
                icon: const Icon(Icons.block_outlined),
                label: const Text('Suspender selecionadas'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBulk(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function(String reason) action,
    bool destructive = false,
  }) async {
    final reason = await showConfirmActionDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
    );

    if (reason == null) {
      return;
    }

    await action(reason);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$confirmLabel em massa concluído.')),
    );
  }
}

class _AccountsTable extends StatelessWidget {
  const _AccountsTable({required this.viewModel});

  final AccountsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final accounts = viewModel.filteredAccounts;

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth > 900
                      ? constraints.maxWidth
                      : 900,
                ),
                child: DataTable(
                  showCheckboxColumn: false,
                  headingTextStyle: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                  dataTextStyle: Theme.of(context).textTheme.bodyMedium,
                  columns: [
                    DataColumn(
                      label: Checkbox(
                        value: viewModel.allFilteredSelected,
                        onChanged: accounts.isEmpty
                            ? null
                            : (value) =>
                                  viewModel.toggleAllFiltered(value ?? false),
                      ),
                    ),
                    const DataColumn(label: Text('Nome')),
                    const DataColumn(label: Text('E-mail')),
                    const DataColumn(label: Text('Status')),
                    const DataColumn(label: Text('Cadastro')),
                    const DataColumn(label: Text('Último acesso')),
                  ],
                  rows: [
                    for (final account in accounts)
                      DataRow(
                        selected: viewModel.isSelected(account),
                        cells: [
                          DataCell(
                            Checkbox(
                              value: viewModel.isSelected(account),
                              onChanged: (value) =>
                                  viewModel.toggleAccountSelection(
                                    account,
                                    value ?? false,
                                  ),
                            ),
                          ),
                          _openableCell(context, account, Text(account.name)),
                          _openableCell(context, account, Text(account.email)),
                          _openableCell(
                            context,
                            account,
                            StatusBadge(status: account.status.apiValue),
                          ),
                          _openableCell(
                            context,
                            account,
                            Text(AppFormatters.date(account.registeredAt)),
                          ),
                          _openableCell(
                            context,
                            account,
                            Text(AppFormatters.dateTime(account.lastAccess)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DataCell _openableCell(
    BuildContext context,
    AdminAccount account,
    Widget child,
  ) {
    return DataCell(
      child,
      onTap: () => showAccountDetailDialog(
        context,
        account: account,
        viewModel: viewModel,
      ),
    );
  }
}

Future<void> showAccountDetailDialog(
  BuildContext context, {
  required AdminAccount account,
  required AccountsViewModel viewModel,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        _AccountDetailDialog(account: account, viewModel: viewModel),
  );
}

class _AccountDetailDialog extends StatelessWidget {
  const _AccountDetailDialog({required this.account, required this.viewModel});

  final AdminAccount account;
  final AccountsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFE8EEFF),
            child: Icon(Icons.person_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  account.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBadge(status: account.status.apiValue),
              const SizedBox(height: 18),
              Wrap(
                spacing: 24,
                runSpacing: 8,
                children: [
                  _DetailLine(label: 'ID', value: account.id),
                  _DetailLine(label: 'Documento', value: account.document),
                  _DetailLine(
                    label: 'Cadastro',
                    value: AppFormatters.date(account.registeredAt),
                  ),
                  _DetailLine(
                    label: 'Pix/chave de pagamento',
                    value: account.paymentKey ?? 'Não informado',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (account.status != AccountStatus.suspenso)
              OutlinedButton.icon(
                onPressed: () => _confirm(
                  context,
                  title: 'Suspender conta',
                  message: 'A conta será bloqueada para uso no app.',
                  confirmLabel: 'Suspender',
                  destructive: true,
                  action: (reason) => viewModel.suspendAccount(account, reason),
                ),
                icon: const Icon(Icons.block_outlined),
                label: const Text('Suspender'),
              ),
            if (account.status == AccountStatus.suspenso)
              OutlinedButton.icon(
                onPressed: () => _confirm(
                  context,
                  title: 'Reativar conta',
                  message: 'A conta voltará para o status ativo.',
                  confirmLabel: 'Reativar',
                  action: (reason) => viewModel.restoreAccount(account, reason),
                ),
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Reativar conta'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function(String reason) action,
    bool destructive = false,
  }) async {
    final reason = await showConfirmActionDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
    );

    if (reason == null) {
      return;
    }

    await action(reason);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$confirmLabel concluído.')));
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

