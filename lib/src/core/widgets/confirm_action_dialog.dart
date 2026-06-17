import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Future<String?> showConfirmActionDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  bool destructive = false,
  bool requiresReason = true,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => ConfirmActionDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
      requiresReason: requiresReason,
    ),
  );
}

class ConfirmActionDialog extends StatefulWidget {
  const ConfirmActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.destructive,
    required this.requiresReason,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool destructive;
  final bool requiresReason;

  @override
  State<ConfirmActionDialog> createState() => _ConfirmActionDialogState();
}

class _ConfirmActionDialogState extends State<ConfirmActionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confirmColor = widget.destructive
        ? AppColors.danger
        : AppColors.primary;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (widget.requiresReason) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Motivo/observação',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (!widget.requiresReason) {
                      return null;
                    }
                    if (value == null || value.trim().length < 4) {
                      return 'Informe um motivo com pelo menos 4 caracteres.';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_reasonController.text.trim());
            }
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
