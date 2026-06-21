import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../domain/chat_models.dart';

abstract class ChatsRemoteDataSource {
  Future<Result<List<AdminChat>>> fetchChats();
  Future<Result<List<ChatMessage>>> fetchMessages(String chatId);
  Future<Result<AdminChat>> markReviewed(String chatId);
  Future<Result<AdminChat>> flagChat(String chatId);
  Future<Result<AdminChat>> openIncident(String chatId, String reason);
}

class ApiChatsRemoteDataSource implements ChatsRemoteDataSource {
  const ApiChatsRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<Result<List<AdminChat>>> fetchChats() async {
    final result = await apiClient.get('/v1/admin/chats');
    return result.when(
      success: (json) {
        final rawList = _extractList(json);
        final chats = rawList
            .map((e) => _chatFromJson(e as Map<String, dynamic>))
            .toList();
        return Success(chats);
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  @override
  Future<Result<List<ChatMessage>>> fetchMessages(String chatId) async {
    final result = await apiClient.get('/v1/admin/chats/$chatId/messages');
    return result.when(
      success: (json) {
        final rawList = _extractList(json);
        final messages = rawList
            .map((e) => _messageFromJson(e as Map<String, dynamic>))
            .toList();
        return Success(messages);
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  // Read-only panel — no server-side flag/review/incident endpoints
  @override
  Future<Result<AdminChat>> markReviewed(String chatId) => _noOp(chatId);

  @override
  Future<Result<AdminChat>> flagChat(String chatId) => _noOp(chatId);

  @override
  Future<Result<AdminChat>> openIncident(String chatId, String reason) =>
      _noOp(chatId);

  Future<Result<AdminChat>> _noOp(String chatId) async {
    final chats = await fetchChats();
    return chats.when(
      success: (list) {
        final chat = list.where((c) => c.id == chatId).firstOrNull;
        if (chat == null) {
          return const Failure(AppFailure(message: 'Conversa não encontrada.'));
        }
        return Success(chat);
      },
      failure: (f) => Failure(AppFailure(message: f.message)),
    );
  }

  AdminChat _chatFromJson(Map<String, dynamic> json) {
    final names = (json['participantNames'] as List?)?.cast<String>() ?? [];
    final rawDate =
        (json['lastMessageAt'] ?? json['createdAt']) as String?;
    final updatedAt = rawDate != null
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    return AdminChat(
      id: json['conversationId'] as String? ?? '',
      customer: names.isNotEmpty ? names[0] : 'N/D',
      provider: names.length > 1 ? names[1] : 'N/D',
      service: 'N/D',
      proposal: 'Proposta',
      paymentId: '',
      status: json['isActive'] == true ? ChatStatus.aberto : ChatStatus.revisado,
      flagged: false,
      reported: false,
      updatedAt: updatedAt,
      messages: const [],
    );
  }

  ChatMessage _messageFromJson(Map<String, dynamic> json) {
    final sentAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();

    return ChatMessage(
      author: json['senderId'] as String? ?? 'N/D',
      role: 'Participante',
      body: json['content'] as String? ?? '',
      sentAt: sentAt,
    );
  }

  static List<dynamic> _extractList(Map<String, dynamic> json) {
    if (json['data'] is List) return json['data'] as List<dynamic>;
    return <dynamic>[];
  }
}
