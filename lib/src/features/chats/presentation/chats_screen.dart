import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/chat_models.dart';
import 'chats_view_model.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({required this.viewModel, super.key});

  final ChatsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.filteredChats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChatFilters(viewModel: viewModel),
            const SizedBox(height: 16),
            _ChatInbox(viewModel: viewModel),
          ],
        );
      },
    );
  }
}

class _ChatFilters extends StatelessWidget {
  const _ChatFilters({required this.viewModel});

  final ChatsViewModel viewModel;

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
                    labelText: 'Buscar por pessoa, serviço ou mensagem',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<ChatStatus?>(
                  initialValue: viewModel.statusFilter,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem<ChatStatus?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    for (final status in ChatStatus.values)
                      DropdownMenuItem<ChatStatus?>(
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
                    DropdownMenuItem<int?>(value: 1, child: Text('24 horas')),
                    DropdownMenuItem<int?>(value: 7, child: Text('7 dias')),
                    DropdownMenuItem<int?>(value: 30, child: Text('30 dias')),
                  ],
                  onChanged: viewModel.updatePeriod,
                ),
              ),
              FilterChip(
                selected: viewModel.flaggedOnly,
                onSelected: viewModel.updateFlaggedOnly,
                label: const Text('Sinalizado/denunciado'),
                avatar: const Icon(Icons.flag_outlined, size: 18),
                backgroundColor: AppColors.background,
                side: const BorderSide(color: AppColors.border),
              ),
              Chip(
                avatar: const Icon(Icons.forum_outlined, size: 18),
                label: Text('${viewModel.filteredChats.length} conversas'),
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

class _ChatInbox extends StatelessWidget {
  const _ChatInbox({required this.viewModel});

  final ChatsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final chats = viewModel.filteredChats;

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (chats.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhuma conversa encontrada.'),
              )
            else
              for (final chat in chats)
                _InboxRow(
                  chat: chat,
                  onTap: () {
                    viewModel.selectChat(chat);
                    showChatDialog(context, chat: chat, viewModel: viewModel);
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.chat, required this.onTap});

  final AdminChat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = chat.messages.isEmpty ? null : chat.messages.last;
    final preview = latest == null ? 'Sem mensagens.' : latest.body;
    final participants = '${chat.customer} ↔ ${chat.provider}';

    return Material(
      color: chat.flagged || chat.reported
          ? const Color(0xFFFFF7F7)
          : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Icon(
                chat.flagged || chat.reported
                    ? Icons.flag_outlined
                    : Icons.forum_outlined,
                color: chat.flagged || chat.reported
                    ? AppColors.danger
                    : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 250,
                child: Text(
                  participants,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            chat.service,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          status: chat.status.apiValue,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppFormatters.date(chat.updatedAt),
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
}

Future<void> showChatDialog(
  BuildContext context, {
  required AdminChat chat,
  required ChatsViewModel viewModel,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ChatDialog(chat: chat, viewModel: viewModel),
  );
}

class _ChatDialog extends StatefulWidget {
  const _ChatDialog({required this.chat, required this.viewModel});

  final AdminChat chat;
  final ChatsViewModel viewModel;

  @override
  State<_ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<_ChatDialog> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final viewModel = widget.viewModel;
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      insetPadding: _expanded
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${chat.customer} ↔ ${chat.provider}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: chat.status.apiValue),
          const SizedBox(width: 8),
          IconButton(
            tooltip: _expanded ? 'Reduzir modal' : 'Expandir chat',
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            icon: Icon(_expanded ? Icons.close_fullscreen : Icons.open_in_full),
          ),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: _expanded ? size.width - 96 : 860,
        height: _expanded ? size.height - 230 : null,
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final messages = _MessagesColumn(chat: chat);
              final contextPanel = _ChatContextPanel(
                chat: chat,
                viewModel: viewModel,
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    contextPanel,
                    const SizedBox(height: 18),
                    messages,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: messages),
                  const SizedBox(width: 18),
                  SizedBox(width: 280, child: contextPanel),
                ],
              );
            },
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
                onPressed: viewModel.markSelectedReviewed,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como revisado'),
              ),
              OutlinedButton.icon(
                onPressed: viewModel.flagSelected,
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Sinalizar conversa'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                onPressed: () => _openIncident(context),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Abrir ocorrência'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openIncident(BuildContext context) async {
    final reason = await showConfirmActionDialog(
      context,
      title: 'Abrir ocorrência',
      message:
          'Registre o motivo para vincular esta conversa a uma ocorrência.',
      confirmLabel: 'Abrir ocorrência',
      destructive: true,
    );

    if (reason == null) {
      return;
    }

    await widget.viewModel.openIncident(reason);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ocorrência aberta.')));
  }
}

class _MessagesColumn extends StatelessWidget {
  const _MessagesColumn({required this.chat});

  final AdminChat chat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mensagens',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (final message in chat.messages)
          _MessageBubble(message: message, customer: chat.customer),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.customer});

  final ChatMessage message;
  final String customer;

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.author == customer;

    return Align(
      alignment: isCustomer ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCustomer ? AppColors.background : const Color(0xFFE8EEFF),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${message.author} · ${message.role}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(message.body),
            const SizedBox(height: 6),
            Text(
              AppFormatters.dateTime(message.sentAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatContextPanel extends StatelessWidget {
  const _ChatContextPanel({required this.chat, required this.viewModel});

  final AdminChat chat;
  final ChatsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dados da conversa',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        _ContextLine(label: 'Contratante', value: chat.customer),
        _ContextLine(label: 'Executor', value: chat.provider),
        _ContextLine(label: 'Serviço', value: chat.service),
        _ContextLine(label: 'Orçamento/proposta', value: chat.proposal),
        _ContextLine(label: 'Pagamento ligado', value: chat.paymentId),
        _ContextLine(
          label: 'Atualizado em',
          value: AppFormatters.dateTime(chat.updatedAt),
        ),
      ],
    );
  }
}

class _ContextLine extends StatelessWidget {
  const _ContextLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
