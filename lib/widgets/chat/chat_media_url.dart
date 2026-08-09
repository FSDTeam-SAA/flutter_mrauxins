import 'package:two_one_two_messenger/services/api_config.dart';

/// Applies only where the legacy code guarded the `Urls.mediaUrl` prefix with
/// an `https:` check (image/gif thumbnails and their full-screen preview
/// navigation). Other call sites in the chat bubble UI prefix unconditionally
/// and must keep doing so verbatim - do not widen this helper's use without
/// checking against the original `chat_bubble.dart` call site first.
String resolveChatMediaUrl(String? url) {
  final value = url ?? '';
  if (value.isEmpty) return '';
  return value.startsWith('https:') ? value : '${Urls.mediaUrl}$value';
}
