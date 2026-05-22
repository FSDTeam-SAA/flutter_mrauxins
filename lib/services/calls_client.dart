import 'package:flutter/widgets.dart';

import 'api_client.dart';

class CallsClient {
  CallsClient(this._apiClient);

  final ApiClient _apiClient;

  Future<dynamic> getAppIdForAgora() => _apiClient.getAppIdForAgora();

  Future<dynamic> requestCall({
    required String chatId,
    required Map<String, dynamic> data,
    required BuildContext context,
  }) =>
      _apiClient.requestCall(
        chatId: chatId,
        data: data,
        context: context,
      );

  Future<dynamic> getAllCallsHistory(
    int page,
    int limit,
    BuildContext context,
  ) =>
      _apiClient.getAllCallsHistory(page, limit, context);

  Future<dynamic> clearCallLogs(List<String> callIdList) =>
      _apiClient.clearCallLogs(callIdList);
}
