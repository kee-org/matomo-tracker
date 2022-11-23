import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'matomo_event.dart';

class MatomoDispatcher {
  final String baseUrl;
  final String? tokenAuth;
  final http.Client httpClient;

  final Uri baseUri;

  MatomoDispatcher(this.baseUrl, this.tokenAuth, {http.Client? httpClient})
      : baseUri = Uri.parse(baseUrl),
        httpClient = httpClient ?? http.Client();

  void send(MatomoEvent event) {
    final headers = <String, String>{
      if (!kIsWeb) 'User-Agent': 'Dart Matomo Tracker',
    };

    final queryParameters = Map<String, String>.from(baseUri.queryParameters)
      ..addAll(event.toMap());
    final aTokenAuth = tokenAuth;
    if (aTokenAuth != null) {
      queryParameters.addEntries([MapEntry('token_auth', aTokenAuth)]);
    }

    final uri = baseUri.replace(queryParameters: queryParameters);
    event.tracker.log.fine(' -> ${uri.toString()}');
    httpClient.post(uri, headers: headers).then((response) {
      final statusCode = response.statusCode;
      event.tracker.log.fine(' <- $statusCode');
    }).catchError((e) {
      event.tracker.log.fine(' <- ${e.toString()}');
    });
  }
}
