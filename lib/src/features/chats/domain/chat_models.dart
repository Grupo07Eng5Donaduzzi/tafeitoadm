enum ChatStatus { aberto, revisado, sinalizado, ocorrencia }

extension ChatStatusDetails on ChatStatus {
  String get apiValue {
    return switch (this) {
      ChatStatus.aberto => 'aberto',
      ChatStatus.revisado => 'revisado',
      ChatStatus.sinalizado => 'sinalizado',
      ChatStatus.ocorrencia => 'ocorrencia',
    };
  }

  String get label {
    return switch (this) {
      ChatStatus.aberto => 'Aberto',
      ChatStatus.revisado => 'Revisado',
      ChatStatus.sinalizado => 'Sinalizado',
      ChatStatus.ocorrencia => 'Ocorrência',
    };
  }
}

class AdminChat {
  const AdminChat({
    required this.id,
    required this.customer,
    required this.provider,
    required this.service,
    required this.proposal,
    required this.paymentId,
    required this.status,
    required this.flagged,
    required this.reported,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  final String customer;
  final String provider;
  final String service;
  final String proposal;
  final String paymentId;
  final ChatStatus status;
  final bool flagged;
  final bool reported;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  AdminChat copyWith({ChatStatus? status, bool? flagged, bool? reported}) {
    return AdminChat(
      id: id,
      customer: customer,
      provider: provider,
      service: service,
      proposal: proposal,
      paymentId: paymentId,
      status: status ?? this.status,
      flagged: flagged ?? this.flagged,
      reported: reported ?? this.reported,
      updatedAt: DateTime.now(),
      messages: messages,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.author,
    required this.role,
    required this.body,
    required this.sentAt,
  });

  final String author;
  final String role;
  final String body;
  final DateTime sentAt;
}
