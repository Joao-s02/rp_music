import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidNotifications extends ChangeNotifier {
  static const _channel = MethodChannel('rp_music/system');
  bool? enabled;
  bool get supported => Platform.isAndroid;
  Future<void> request({bool firstLaunch = false}) async {
    if (!supported) return;
    try {
      enabled = await _channel.invokeMethod<bool>('requestNotifications', {
        'firstLaunch': firstLaunch,
      });
      notifyListeners();
    } on PlatformException {
      enabled = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!supported) return;
    try {
      enabled = await _channel.invokeMethod<bool>('notificationsEnabled');
      notifyListeners();
    } on PlatformException {
      enabled = false;
      notifyListeners();
    }
  }

  Future<void> openSettings() =>
      _channel.invokeMethod<void>('notificationSettings');
}
