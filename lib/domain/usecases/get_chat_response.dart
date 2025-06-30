import 'package:mind_flow/domain/repositories/chat_bot_repository.dart';

class GetChatResponse {
  final ChatBotRepository repository;

  GetChatResponse(this.repository);

  Future<String> call(String userText, String modelKey) {
    return repository.chatResponse(userText, modelKey);
  }
}