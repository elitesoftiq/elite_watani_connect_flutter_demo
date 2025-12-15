import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';

class WebviewPage extends StatefulWidget {
  final String alwataniUrl;

  const WebviewPage({super.key, required this.alwataniUrl});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  @override
  Widget build(BuildContext context) {
    Future<NavigationActionPolicy?> onRedirection(
      InAppWebViewController _,
      NavigationAction navigationAction,
    ) async {
      final uri = navigationAction.request.url!;

      final isStatusUrl = uri.toString().contains("tabadul-payment-status");
      if (isStatusUrl) {
        final status = StatusUrl.fromUrl(uri.toString());
        log(status.toString());
      }

      return NavigationActionPolicy.ALLOW;
    }

    return Scaffold(
      appBar: AppBar(title: Text("Payment")),

      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.alwataniUrl)),
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
          useOnDownloadStart: true,
          horizontalScrollBarEnabled: false,
          disableHorizontalScroll: true,
          iframeAllowFullscreen: true,
          maximumZoomScale: 0,
          supportZoom: false,
          preferredContentMode: UserPreferredContentMode.MOBILE,
          userAgent: kIsWeb
              ? 'Mozilla/5.0 (Linux; Android 13) '
                    'AppleWebKit/537.36 (KHTML, like Gecko) '
                    'Chrome/116.0.5845.163 '
                    'Mobile Safari/537.36'
              : Platform.isIOS
              ? "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) "
                    "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 "
                    "Mobile/15E148 Safari/604.1"
              : 'Mozilla/5.0 (Linux; Android 13) '
                    'AppleWebKit/537.36 (KHTML, like Gecko) '
                    'Chrome/116.0.5845.163 '
                    'Mobile Safari/537.36',
        ),
        onWebViewCreated: (controller) {},
        shouldOverrideUrlLoading: onRedirection,
      ),
    );
  }
}

class StatusUrl {
  final String? opId;
  final int status;
  final String url;

  StatusUrl(this.opId, this.status, this.url);

  bool get isSuccess => status == 0;

  factory StatusUrl.fromUrl(String url) {
    Uri uri = Uri.parse(url);

    return StatusUrl(
      uri.queryParameters["OpId"],
      int.parse(uri.queryParameters["Status"]!),
      url,
    );
  }

  @override
  String toString() {
    return 'StatusUrl(opId: $opId, status: $status, url: $url)';
  }
}
