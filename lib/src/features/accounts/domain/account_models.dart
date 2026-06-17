enum AccountStatus { ativo, suspenso, excluido }

extension AccountStatusDetails on AccountStatus {
  String get apiValue {
    return switch (this) {
      AccountStatus.ativo => 'ativo',
      AccountStatus.suspenso => 'suspenso',
      AccountStatus.excluido => 'excluido',
    };
  }

  String get label {
    return switch (this) {
      AccountStatus.ativo => 'Ativo',
      AccountStatus.suspenso => 'Suspenso',
      AccountStatus.excluido => 'Excluído',
    };
  }
}

class AdminAccount {
  const AdminAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.document,
    required this.status,
    required this.registeredAt,
    required this.lastAccess,
    required this.paymentKey,
    required this.services,
    required this.relatedPayments,
    required this.relatedChats,
  });

  final String id;
  final String name;
  final String email;
  final String document;
  final AccountStatus status;
  final DateTime registeredAt;
  final DateTime lastAccess;
  final String? paymentKey;
  final List<String> services;
  final List<String> relatedPayments;
  final List<String> relatedChats;

  AdminAccount copyWith({String? name, String? email, AccountStatus? status}) {
    return AdminAccount(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      document: document,
      status: status ?? this.status,
      registeredAt: registeredAt,
      lastAccess: lastAccess,
      paymentKey: paymentKey,
      services: services,
      relatedPayments: relatedPayments,
      relatedChats: relatedChats,
    );
  }
}
