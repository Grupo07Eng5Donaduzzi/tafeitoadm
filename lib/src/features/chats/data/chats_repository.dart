import '../../../core/result/result.dart';
import '../domain/chat_models.dart';
import 'chats_remote_data_source.dart';

class ChatsRepository {
  const ChatsRepository(this.remoteDataSource);

  final ChatsRemoteDataSource remoteDataSource;

  Future<Result<List<AdminChat>>> fetchChats() {
    return remoteDataSource.fetchChats();
  }

  Future<Result<List<ChatMessage>>> fetchMessages(String chatId) {
    return remoteDataSource.fetchMessages(chatId);
  }

  Future<Result<AdminChat>> markReviewed(String chatId) {
    return remoteDataSource.markReviewed(chatId);
  }

  Future<Result<AdminChat>> flagChat(String chatId) {
    return remoteDataSource.flagChat(chatId);
  }

  Future<Result<AdminChat>> openIncident(String chatId, String reason) {
    return remoteDataSource.openIncident(chatId, reason);
  }
}
