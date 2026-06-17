enum PaymentStatus {
  aguardandoPagamento,
  retido,
  servicoEmAndamento,
  clienteConfirmou,
  prestadorConfirmou,
  disputa,
  liberado,
  estornado,
}

extension PaymentStatusDetails on PaymentStatus {
  String get apiValue {
    return switch (this) {
      PaymentStatus.aguardandoPagamento => 'aguardando_pagamento',
      PaymentStatus.retido => 'retido',
      PaymentStatus.servicoEmAndamento => 'servico_em_andamento',
      PaymentStatus.clienteConfirmou => 'cliente_confirmou',
      PaymentStatus.prestadorConfirmou => 'prestador_confirmou',
      PaymentStatus.disputa => 'disputa',
      PaymentStatus.liberado => 'liberado',
      PaymentStatus.estornado => 'estornado',
    };
  }

  String get label {
    return switch (this) {
      PaymentStatus.aguardandoPagamento => 'Aguardando pagamento',
      PaymentStatus.retido => 'Retido',
      PaymentStatus.servicoEmAndamento => 'Serviço em andamento',
      PaymentStatus.clienteConfirmou => 'Contratante confirmou',
      PaymentStatus.prestadorConfirmou => 'Executor confirmou',
      PaymentStatus.disputa => 'Disputa',
      PaymentStatus.liberado => 'Liberado',
      PaymentStatus.estornado => 'Estornado',
    };
  }
}

class AdminPayment {
  const AdminPayment({
    required this.id,
    required this.customer,
    required this.provider,
    required this.service,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.events,
    required this.evidences,
    required this.chatId,
  });

  final String id;
  final String customer;
  final String provider;
  final String service;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PaymentEvent> events;
  final List<String> evidences;
  final String chatId;

  AdminPayment copyWith({
    PaymentStatus? status,
    DateTime? updatedAt,
    List<PaymentEvent>? events,
  }) {
    return AdminPayment(
      id: id,
      customer: customer,
      provider: provider,
      service: service,
      amount: amount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      events: events ?? this.events,
      evidences: evidences,
      chatId: chatId,
    );
  }
}

class PaymentEvent {
  const PaymentEvent({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.admin,
  });

  final String title;
  final String description;
  final DateTime createdAt;
  final String admin;
}
