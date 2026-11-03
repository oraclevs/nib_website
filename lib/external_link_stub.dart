import 'package:flutter/services.dart';

// The website opens links in the browser; native test hosts copy the address.
void openExternalLink(String url) {
  if (Uri.tryParse(url)?.scheme != 'https') {
    throw ArgumentError.value(url, 'url', 'Expected HTTPS');
  }
  Clipboard.setData(ClipboardData(text: url));
}
