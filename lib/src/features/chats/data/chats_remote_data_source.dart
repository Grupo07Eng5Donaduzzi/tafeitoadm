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

class MockChatsRemoteDataSource implements ChatsRemoteDataSource {
  MockChatsRemoteDataSource(this.apiClient) {
    _chats = _seedChats();
  }

  final ApiClient apiClient;

  static const chatsPath = '/v1/admin/chats';
  static const chatMessagesPath = '/v1/admin/chats/:id/messages';
  static const reviewPath = '/v1/admin/chats/:id/review';
  static const flagPath = '/v1/admin/chats/:id/flag';

  late final List<AdminChat> _chats;
  String? lastIncidentReason;

  @override
  Future<Result<List<AdminChat>>> fetchChats() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    return Success(List<AdminChat>.from(_chats));
  }

  @override
  Future<Result<List<ChatMessage>>> fetchMessages(String chatId) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final chat = _find(chatId);
    if (chat == null) {
      return const Failure(AppFailure(message: 'Conversa não encontrada.'));
    }
    return Success(chat.messages);
  }

  @override
  Future<Result<AdminChat>> markReviewed(String chatId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final chat = _find(chatId);
    if (chat == null) {
      return const Failure(AppFailure(message: 'Conversa não encontrada.'));
    }
    return Success(
      _replace(chat.copyWith(status: ChatStatus.revisado, flagged: false)),
    );
  }

  @override
  Future<Result<AdminChat>> flagChat(String chatId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final chat = _find(chatId);
    if (chat == null) {
      return const Failure(AppFailure(message: 'Conversa não encontrada.'));
    }
    return Success(
      _replace(chat.copyWith(status: ChatStatus.sinalizado, flagged: true)),
    );
  }

  @override
  Future<Result<AdminChat>> openIncident(String chatId, String reason) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    lastIncidentReason = reason;
    final chat = _find(chatId);
    if (chat == null) {
      return const Failure(AppFailure(message: 'Conversa não encontrada.'));
    }
    return Success(
      _replace(
        chat.copyWith(
          status: ChatStatus.ocorrencia,
          flagged: true,
          reported: true,
        ),
      ),
    );
  }

  AdminChat? _find(String id) {
    for (final chat in _chats) {
      if (chat.id == id) {
        return chat;
      }
    }
    return null;
  }

  AdminChat _replace(AdminChat next) {
    final index = _chats.indexWhere((chat) => chat.id == next.id);
    if (index >= 0) {
      _chats[index] = next;
    }
    return next;
  }

  List<AdminChat> _seedChats() {
    final now = DateTime.now();

    return [
      AdminChat(
        id: 'CHT-2101',
        customer: 'Marina Lopes',
        provider: 'RJ Reformas',
        service: 'Reparo elétrico',
        proposal: 'Troca de disjuntor e revisão do quadro por R\$ 680,00',
        paymentId: 'PAY-8721',
        status: ChatStatus.sinalizado,
        flagged: true,
        reported: true,
        updatedAt: now.subtract(const Duration(minutes: 34)),
        messages: [
          ChatMessage(
            author: 'Marina Lopes',
            role: 'Contratante',
            body: 'O serviço ficou incompleto e o pagamento ainda está retido.',
            sentAt: now.subtract(const Duration(hours: 3)),
          ),
          ChatMessage(
            author: 'RJ Reformas',
            role: 'Executor',
            body: 'Concluí a parte elétrica. Só falta a contratante confirmar.',
            sentAt: now.subtract(const Duration(hours: 2, minutes: 48)),
          ),
          ChatMessage(
            author: 'Marina Lopes',
            role: 'Contratante',
            body: 'Enviei fotos do quadro sem acabamento pelo app.',
            sentAt: now.subtract(const Duration(minutes: 36)),
          ),
        ],
      ),
      AdminChat(
        id: 'CHT-2070',
        customer: 'Caio Mendes',
        provider: 'Casa Limpa Pro',
        service: 'Limpeza pós-obra',
        proposal: 'Limpeza completa em apartamento de 72m² por R\$ 520,00',
        paymentId: 'PAY-8702',
        status: ChatStatus.aberto,
        flagged: false,
        reported: false,
        updatedAt: now.subtract(const Duration(hours: 4)),
        messages: [
          ChatMessage(
            author: 'Casa Limpa Pro',
            role: 'Executor',
            body: 'Consigo começar amanhã às 9h.',
            sentAt: now.subtract(const Duration(hours: 7)),
          ),
          ChatMessage(
            author: 'Caio Mendes',
            role: 'Contratante',
            body: 'Perfeito, o pagamento já está no app.',
            sentAt: now.subtract(const Duration(hours: 6, minutes: 50)),
          ),
        ],
      ),
      AdminChat(
        id: 'CHT-2088',
        customer: 'Helena Duarte',
        provider: 'Moveis Ágeis',
        service: 'Montagem de móveis',
        proposal: 'Montagem de guarda-roupa com duas portas por R\$ 310,00',
        paymentId: 'PAY-8718',
        status: ChatStatus.ocorrencia,
        flagged: true,
        reported: true,
        updatedAt: now.subtract(const Duration(days: 1, hours: 2)),
        messages: [
          ChatMessage(
            author: 'Helena Duarte',
            role: 'Contratante',
            body: 'O executor cancelou no local e pediu pagamento por fora.',
            sentAt: now.subtract(const Duration(days: 1, hours: 6)),
          ),
          ChatMessage(
            author: 'Moveis Ágeis',
            role: 'Executor',
            body: 'Não havia peças suficientes para concluir.',
            sentAt: now.subtract(const Duration(days: 1, hours: 5)),
          ),
        ],
      ),
      AdminChat(
        id: 'CHT-2044',
        customer: 'Rafaela Prado',
        provider: 'Casa Limpa Pro',
        service: 'Faxina recorrente',
        proposal: 'Pacote quinzenal por R\$ 220,00',
        paymentId: 'PAY-8672',
        status: ChatStatus.revisado,
        flagged: false,
        reported: false,
        updatedAt: now.subtract(const Duration(days: 3)),
        messages: [
          ChatMessage(
            author: 'Rafaela Prado',
            role: 'Contratante',
            body: 'Obrigada, ficou tudo certo.',
            sentAt: now.subtract(const Duration(days: 3, hours: 2)),
          ),
        ],
      ),
    ];
  }
}
