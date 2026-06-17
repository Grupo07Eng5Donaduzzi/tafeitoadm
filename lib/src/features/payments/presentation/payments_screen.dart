import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/payment_models.dart';
import 'payments_view_model.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({required this.viewModel, super.key});

  final PaymentsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.filteredPayments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PaymentFilters(viewModel: viewModel),
            const SizedBox(height: 16),
            _PaymentsTable(viewModel: viewModel),
          ],
        );
      },
    );
  }
}

class _PaymentFilters extends StatelessWidget {
  const _PaymentFilters({required this.viewModel});

  final PaymentsViewModel viewModel;

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
                width: 420,
                child: TextField(
                  onChanged: viewModel.updateQuery,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por ID, pessoa, serviço ou chat',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                width: 230,
                child: DropdownButtonFormField<PaymentStatus?>(
                  initialValue: viewModel.statusFilter,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem<PaymentStatus?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    for (final status in PaymentStatus.values)
                      DropdownMenuItem<PaymentStatus?>(
                        value: status,
                        child: Text(status.label),
                      ),
                  ],
                  onChanged: viewModel.updateStatusFilter,
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<int?>(
                  initialValue: viewModel.periodDays,
                  decoration: const InputDecoration(labelText: 'Período'),
                  items: const [
                    DropdownMenuItem<int?>(value: null, child: Text('Todos')),
                    DropdownMenuItem<int?>(value: 7, child: Text('7 dias')),
                    DropdownMenuItem<int?>(value: 30, child: Text('30 dias')),
                    DropdownMenuItem<int?>(value: 90, child: Text('90 dias')),
                  ],
                  onChanged: viewModel.updatePeriod,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.payments_outlined, size: 18),
                label: Text('${viewModel.filteredPayments.length} pagamentos'),
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

class _PaymentsTable extends StatelessWidget {
  const _PaymentsTable({required this.viewModel});

  final PaymentsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final payments = viewModel.filteredPayments;

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth > 1040
                      ? constraints.maxWidth
                      : 1040,
                ),
                child: DataTable(
                  showCheckboxColumn: false,
                  headingTextStyle: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Contratante')),
                    DataColumn(label: Text('Executor')),
                    DataColumn(label: Text('Serviço')),
                    DataColumn(label: Text('Valor')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Criado em')),
                    DataColumn(label: Text('Atualizado em')),
                  ],
                  rows: [
                    for (final payment in payments)
                      DataRow(
                        onSelectChanged: (_) {
                          viewModel.selectPayment(payment);
                          showPaymentDetailDialog(
                            context,
                            payment: payment,
                            viewModel: viewModel,
                          );
                        },
                        cells: [
                          DataCell(Text(payment.id)),
                          DataCell(Text(payment.customer)),
                          DataCell(Text(payment.provider)),
                          DataCell(Text(payment.service)),
                          DataCell(
                            Text(AppFormatters.currency(payment.amount)),
                          ),
                          DataCell(
                            StatusBadge(status: payment.status.apiValue),
                          ),
                          DataCell(Text(AppFormatters.date(payment.createdAt))),
                          DataCell(
                            Text(AppFormatters.dateTime(payment.updatedAt)),
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
}

Future<void> showPaymentDetailDialog(
  BuildContext context, {
  required AdminPayment payment,
  required PaymentsViewModel viewModel,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        _PaymentDetailDialog(payment: payment, viewModel: viewModel),
  );
}

class _PaymentDetailDialog extends StatelessWidget {
  const _PaymentDetailDialog({required this.payment, required this.viewModel});

  final AdminPayment payment;
  final PaymentsViewModel viewModel;

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
          Expanded(
            child: Text(
              payment.id,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          StatusBadge(status: payment.status.apiValue),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppFormatters.currency(payment.amount),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 28,
                runSpacing: 10,
                children: [
                  _DetailLine(label: 'Contratante', value: payment.customer),
                  _DetailLine(label: 'Executor', value: payment.provider),
                  _DetailLine(label: 'Serviço', value: payment.service),
                  _DetailLine(label: 'Chat vinculado', value: payment.chatId),
                  _DetailLine(
                    label: 'Criado em',
                    value: AppFormatters.dateTime(payment.createdAt),
                  ),
                  _DetailLine(
                    label: 'Atualizado em',
                    value: AppFormatters.dateTime(payment.updatedAt),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _EvidenceList(items: payment.evidences),
              const SizedBox(height: 18),
              _EventTimeline(events: payment.events),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _confirm(
                  context,
                  title: 'Liberar para executor',
                  message:
                      'O valor será marcado como liberado para quem executou o serviço.',
                  confirmLabel: 'Liberar',
                  action: viewModel.releaseSelected,
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Liberar para executor'),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirm(
                  context,
                  title: 'Devolver para contratante',
                  message:
                      'O pagamento será marcado como estornado para quem contratou.',
                  confirmLabel: 'Devolver',
                  destructive: true,
                  action: viewModel.refundSelected,
                ),
                icon: const Icon(Icons.undo_outlined),
                label: const Text('Devolver para contratante'),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirm(
                  context,
                  title: 'Abrir disputa',
                  message: 'O pagamento será movido para análise de disputa.',
                  confirmLabel: 'Abrir disputa',
                  destructive: true,
                  action: viewModel.disputeSelected,
                ),
                icon: const Icon(Icons.gavel_outlined),
                label: const Text('Abrir disputa'),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirm(
                  context,
                  title: 'Marcar como resolvido',
                  message: 'Registre a observação da resolução administrativa.',
                  confirmLabel: 'Resolver',
                  action: viewModel.resolveSelected,
                ),
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Marcar como resolvido'),
              ),
            ],
          ),
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
      width: 300,
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

class _EvidenceList extends StatelessWidget {
  const _EvidenceList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidências/observações',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.attachment_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}

class _EventTimeline extends StatelessWidget {
  const _EventTimeline({required this.events});

  final List<PaymentEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico de eventos',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final event in events)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(event.description),
                const SizedBox(height: 4),
                Text(
                  '${event.admin} · ${AppFormatters.dateTime(event.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
