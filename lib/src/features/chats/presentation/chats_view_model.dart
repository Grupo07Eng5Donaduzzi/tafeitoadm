import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../data/chats_repository.dart';
import '../domain/chat_models.dart';

class ChatsViewModel extends ChangeNotifier {
  ChatsViewModel(this._repository);

  final ChatsRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AdminChat> _chats = [];
  AdminChat? _selectedChat;
  String _query = '';
  ChatStatus? _statusFilter;
  int? _periodDays;
  bool _flaggedOnly = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdminChat? get selectedChat => _selectedChat;
  String get query => _query;
  ChatStatus? get statusFilter => _statusFilter;
  int? get periodDays => _periodDays;
  bool get flaggedOnly => _flaggedOnly;

  List<AdminChat> get filteredChats {
    final normalizedQuery = _query.trim().toLowerCase();
    final now = DateTime.now();

    return _chats.where((chat) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          chat.customer.toLowerCase().contains(normalizedQuery) ||
          chat.provider.toLowerCase().contains(normalizedQuery) ||
          chat.service.toLowerCase().contains(normalizedQuery) ||
          chat.messages.any(
            (message) => message.body.toLowerCase().contains(normalizedQuery),
          );
      final matchesStatus =
          _statusFilter == null || chat.status == _statusFilter;
      final matchesPeriod =
          _periodDays == null ||
          chat.updatedAt.isAfter(now.subtract(Duration(days: _periodDays!)));
      final matchesFlag = !_flaggedOnly || chat.flagged || chat.reported;

      return matchesQuery && matchesStatus && matchesPeriod && matchesFlag;
    }).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchChats();
    result.when(
      success: (chats) {
        _chats = chats;
        _selectedChat = chats.isEmpty ? null : chats.first;
      },
      failure: (failure) => _errorMessage = failure.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void updateStatusFilter(ChatStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void updatePeriod(int? value) {
    _periodDays = value;
    notifyListeners();
  }

  void updateFlaggedOnly(bool value) {
    _flaggedOnly = value;
    notifyListeners();
  }

  void selectChat(AdminChat chat) {
    _selectedChat = chat;
    notifyListeners();
  }

  Future<void> markSelectedReviewed() {
    final chat = _selectedChat;
    if (chat == null) {
      return Future<void>.value();
    }
    return _commit(_repository.markReviewed(chat.id));
  }

  Future<void> flagSelected() {
    final chat = _selectedChat;
    if (chat == null) {
      return Future<void>.value();
    }
    return _commit(_repository.flagChat(chat.id));
  }

  Future<void> openIncident(String reason) {
    final chat = _selectedChat;
    if (chat == null) {
      return Future<void>.value();
    }
    return _commit(_repository.openIncident(chat.id, reason));
  }

  Future<void> _commit(Future<Result<AdminChat>> request) async {
    final result = await request;
    result.when(
      success: (updated) {
        final index = _chats.indexWhere((item) => item.id == updated.id);
        if (index >= 0) {
          _chats[index] = updated;
        }
        _selectedChat = updated;
        _errorMessage = null;
      },
      failure: (failure) => _errorMessage = failure.message,
    );
    notifyListeners();
  }
}
