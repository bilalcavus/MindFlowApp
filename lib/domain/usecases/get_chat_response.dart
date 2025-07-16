import 'package:mind_flow/data/datasources/remote_datasource.dart';

class GetChatResponse {
  final RemoteDataSource _dataSource;

  GetChatResponse(this._dataSource);

  Future<String> call(String message, String selectedModel) async {
    return await _dataSource.getChatResponse(message, modelKey: selectedModel);
  }

  Future<String> callWithContext(List<Map<String, String>> messages, String selectedModel, {String? chatType}) async {
    return await _dataSource.getChatResponseWithContext(messages, modelKey: selectedModel, chatType: chatType);
  }
}