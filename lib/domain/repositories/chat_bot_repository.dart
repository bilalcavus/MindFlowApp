import 'package:mind_flow/domain/repositories/base_repository.dart';

abstract class ChatBotRepository extends BaseRepository {
  Future<String> chatResponse(String userMessage, String modelKey);
}