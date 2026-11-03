import 'dart:js_interop';

@JS('window.open')
external JSAny? _open(String url, String target, String features);

void openExternalLink(String url) {
  if (Uri.tryParse(url)?.scheme != 'https') {
    throw ArgumentError.value(url, 'url', 'Expected HTTPS');
  }
  _open(url, '_blank', 'noopener,noreferrer');
}
