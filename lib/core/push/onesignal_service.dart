import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'onesignal_web_stub.dart'
    if (dart.library.js_interop) 'onesignal_web_interop.dart' as web_push;

/// OneSignal init + per-user external_id binding.
///
/// Two very different backends:
///  • Mobile / desktop → the `onesignal_flutter` plugin (native SDK).
///  • Web / PWA        → the OneSignal Web SDK v16, loaded in index.html and
///    reached through the `web_push` bridge. The Flutter plugin has no web
///    support, so we must not call it when `kIsWeb`.
class OneSignalService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    if (_initialized) return;
    const appId = String.fromEnvironment('ONESIGNAL_APP_ID');
    if (appId.isEmpty || appId.startsWith('REPLACE')) {
      return;
    }
    OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    OneSignal.initialize(appId);
    await OneSignal.Notifications.requestPermission(true);
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) return web_push.requestPermission();
    return OneSignal.Notifications.requestPermission(true);
  }

  static Future<bool> isPushSupported() async {
    if (kIsWeb) return web_push.isSupported();
    return true;
  }

  static Future<bool> hasPermission() async {
    if (kIsWeb) return web_push.hasPermission();
    return OneSignal.Notifications.permission;
  }

  static Future<void> bindUser(String userId) async {
    if (kIsWeb) {
      web_push.login(userId);
      return;
    }
    if (!_initialized) return;
    await OneSignal.login(userId);
  }

  static Future<void> unbindUser() async {
    if (kIsWeb) {
      web_push.logout();
      return;
    }
    if (!_initialized) return;
    await OneSignal.logout();
  }
}
