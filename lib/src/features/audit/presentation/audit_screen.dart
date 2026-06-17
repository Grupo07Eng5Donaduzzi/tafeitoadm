import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../domain/audit_models.dart';
import 'audit_view_model.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({required this.viewModel, super.key});

  final AuditViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.filteredLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuditFilters(viewModel: viewModel),
            const SizedBox(height: 16),
            _AuditList(logs: viewModel.filteredLogs),
          ],
        );
      },
    );
  }
}

class _AuditFilters extends StatelessWidget {
  const _AuditFilters({required this.viewModel});

  final AuditViewModel viewModel;

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
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String?>(
                  initialValue: viewModel.adminFilter,
                  decoration: const InputDecoration(labelText: 'Admin'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    for (final admin in viewModel.admins)
                      DropdownMenuItem<String?>(
                        value: admin,
                        child: Text(admin),
                      ),
                  ],
                  onChanged: viewModel.updateAdminFilter,
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String?>(
                  initialValue: viewModel.typeFilter,
                  decoration: const InputDecoration(labelText: 'Tipo de ação'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    for (final type in viewModel.actionTypes)
                      DropdownMenuItem<String?>(
                        value: type,
                        child: Text(_labelForType(type)),
                      ),
                  ],
                  onChanged: viewModel.updateTypeFilter,
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<int?>(
                  initialValue: viewModel.periodDays,
                  decoration: const InputDecoration(labelText: 'Período'),
                  items: const [
                    DropdownMenuItem<int?>(value: null, child: Text('Todos')),
                    DropdownMenuItem<int?>(value: 1, child: Text('24 horas')),
                    DropdownMenuItem<int?>(value: 7, child: Text('7 dias')),
                    DropdownMenuItem<int?>(value: 30, child: Text('30 dias')),
                  ],
                  onChanged: viewModel.updatePeriod,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.fact_check_outlined, size: 18),
                label: Text('${viewModel.filteredLogs.length} registros'),
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

class _AuditList extends StatelessWidget {
  const _AuditList({required this.logs});

  final List<AuditLog> logs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhum registro de auditoria encontrado.'),
              )
            else
              for (final log in logs) _AuditTile(log: log),
          ],
        ),
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.log});

  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: () => showAuditLogDialog(context, log),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.description,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${log.admin} · ${log.target} · ${AppFormatters.dateTime(log.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                log.id,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (log.actionType) {
      'conta' => Icons.people_alt_outlined,
      'chat' => Icons.forum_outlined,
      'pagamento' => Icons.payments_outlined,
      _ => Icons.fact_check_outlined,
    };
  }

  Color get _iconColor {
    return switch (log.actionType) {
      'conta' => AppColors.primary,
      'chat' => AppColors.warning,
      'pagamento' => AppColors.success,
      _ => AppColors.info,
    };
  }
}

Future<void> showAuditLogDialog(BuildContext context, AuditLog log) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Detalhe da auditoria',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuditDetailLine(label: 'ID', value: log.id),
            _AuditDetailLine(label: 'Admin', value: log.admin),
            _AuditDetailLine(
              label: 'Tipo de ação',
              value: _labelForType(log.actionType),
            ),
            _AuditDetailLine(label: 'Alvo', value: log.target),
            _AuditDetailLine(
              label: 'Data e hora',
              value: AppFormatters.dateTime(log.createdAt),
            ),
            const SizedBox(height: 12),
            Text(
              'Descrição',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(log.description),
            ),
            const SizedBox(height: 12),
            _AuditDetailLine(
              label: 'Endpoint relacionado',
              value: _endpointHint(log),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AuditDetailLine extends StatelessWidget {
  const _AuditDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

String _labelForType(String value) {
  return switch (value) {
    'conta' => 'Conta',
    'chat' => 'Chat',
    'pagamento' => 'Pagamento',
    _ => value,
  };
}

String _endpointHint(AuditLog log) {
  return switch (log.actionType) {
    'conta' => '/v1/admin/users/${log.target}',
    'chat' => '/v1/admin/chats/${log.target}',
    'pagamento' => '/v1/admin/payments/${log.target}',
    _ => '/v1/admin/audit-logs/${log.id}',
  };
}
