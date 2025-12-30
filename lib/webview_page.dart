import 'dart:developer';

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

      body: SizedBox(
        height: double.infinity,
        child: InAppWebView(
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
          ),
          onWebViewCreated: (controller) {},
          shouldOverrideUrlLoading: onRedirection,
        ),
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
