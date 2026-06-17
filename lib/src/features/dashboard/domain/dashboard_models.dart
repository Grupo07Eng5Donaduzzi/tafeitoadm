class DashboardSummary {
  const DashboardSummary({
    required this.totalUsers,
    required this.activeAccounts,
    required this.usersWithServices,
    required this.blockedAccounts,
    required this.heldPayments,
    required this.openDisputes,
    required this.flaggedChats,
    required this.heldVolume,
    required this.latestDisputes,
    required this.pendingPayments,
    required this.recentAccounts,
  });

  final int totalUsers;
  final int activeAccounts;
  final int usersWithServices;
  final int blockedAccounts;
  final int heldPayments;
  final int openDisputes;
  final int flaggedChats;
  final double heldVolume;
  final List<DisputePreview> latestDisputes;
  final List<PaymentPreview> pendingPayments;
  final List<AccountPreview> recentAccounts;
}

class DisputePreview {
  const DisputePreview({
    required this.id,
    required this.customer,
    required this.provider,
    required this.service,
    required this.openedAt,
  });

  final String id;
  final String customer;
  final String provider;
  final String service;
  final DateTime openedAt;
}

class PaymentPreview {
  const PaymentPreview({
    required this.id,
    required this.customer,
    required this.provider,
    required this.amount,
    required this.status,
  });

  final String id;
  final String customer;
  final String provider;
  final double amount;
  final String status;
}

class AccountPreview {
  const AccountPreview({
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String name;
  final String email;
  final DateTime createdAt;
}
