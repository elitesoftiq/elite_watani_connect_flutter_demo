import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:elite_watani_connect_demo/webview_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool isProduction = false;

    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text('Hello!')),

                ElevatedButton(
                  onPressed: () async {
                    final token = await _getToken(isProduction);

                    if (token == null) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebviewPage(
                          alwataniUrl: isProduction
                              ? 'https://alwatani.elitesoft.iq/web/?agentId=[YOUR_AGENT_ID]&portalToken=$token'
                              : 'https://dev.elitesoft.iq:8888/web/?agentId=[YOUR_AGENT_ID]&portalToken=$token',
                        ),
                      ),
                    );
                  },
                  child: Text('start'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Dio provideDio(bool isProduction) {
  final dio = Dio();
  dio.options.baseUrl = isProduction
      ? 'https://alwatani.elitesoft.iq/'
      : 'https://dev.elitesoft.iq:8088/';
  dio.options.headers = {
    'Content-Type': 'application/json',
    'x-auth-type': 'self_auth',
    'X-API-Key': isProduction
        ? 'YOUR_API_KEY_HERE' // Replace with your prod API key
        : 'f4e1c7b8d23f6eaf4e1c7b8d23f6ea',
  };
  dio.interceptors.add(LogInterceptor());
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );
  return dio;
}

Future<String?> _getToken(bool isProduction) async {
  try {
    final dio = provideDio(isProduction);
    final response = await dio.post(
      'cnct/user/get_token',
      data: {
        // Add any required request body parameters here if needed
        // For example: 'username': 'testuser', 'password': 'testpassword'
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      final accessToken = response.data['data']['access_token'];
      log('Access Token: $accessToken');
      return accessToken;
    } else {
      log('Failed to get token: ${response.statusCode}');
      log('Response data: ${response.data}');
      return null;
    }
  } on DioException catch (e) {
    log('Error getting token: ${e.message}');
    if (e.response != null) {
      log('Error response data: ${e.response?.data}');
    }
    return null;
  }
}
