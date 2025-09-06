import 'package:mind_flow/data/datasources/remote_datasource.dart';

class GetChatResponse {
  final RemoteDataSource _dataSource;

  GetChatResponse(this._dataSource);



  Future<String> callWithContext(List<Map<String, String>> messages, String selectedModel, {String? chatType, bool isPremiumUser = false}) async {
    return await _dataSource.getChatResponseWithContext(messages, modelKey: selectedModel, chatType: chatType, isPremiumUser: isPremiumUser);
  }

}