import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, this.compact = false, super.key});

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = _colorFor(normalized);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.26)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelFor(normalized),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static Color _colorFor(String status) {
    return switch (status) {
      'ativo' ||
      'cliente_confirmou' ||
      'prestador_confirmou' ||
      'liberado' ||
      'revisado' => AppColors.success,
      'suspenso' ||
      'retido' ||
      'servico_em_andamento' ||
      'aguardando_pagamento' => AppColors.warning,
      'excluido' ||
      'estornado' ||
      'disputa' ||
      'sinalizado' ||
      'ocorrencia' => AppColors.danger,
      _ => AppColors.info,
    };
  }

  static String _labelFor(String status) {
    return switch (status) {
      'ativo' => 'Ativo',
      'suspenso' => 'Suspenso',
      'excluido' => 'Excluído',
      'aguardando_pagamento' => 'Aguardando pagamento',
      'retido' => 'Retido',
      'servico_em_andamento' => 'Serviço em andamento',
      'cliente_confirmou' => 'Contratante confirmou',
      'prestador_confirmou' => 'Executor confirmou',
      'disputa' => 'Disputa',
      'liberado' => 'Liberado',
      'estornado' => 'Estornado',
      'aberto' => 'Aberto',
      'revisado' => 'Revisado',
      'sinalizado' => 'Sinalizado',
      'ocorrencia' => 'Ocorrência',
      _ => status.replaceAll('_', ' '),
    };
  }
}
