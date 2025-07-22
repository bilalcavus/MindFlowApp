import 'package:mind_flow/core/mixins/repository_error_handling.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/domain/repositories/chat_bot_repository.dart';

class ChatbotRepositoryImpl with RepositoryHandling implements ChatBotRepository {
  final RemoteDataSource _remoteDataSource;

  ChatbotRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> chatResponse(String userMessage, String modelKey, {bool isPremiumUser = false}) {
    return handleRepositoryOperation(
      operation: () => _remoteDataSource.getChatResponse(userMessage, modelKey: modelKey, isPremiumUser: isPremiumUser),
      errorMessage: 'Failed to get chat response',
    );
  }
}