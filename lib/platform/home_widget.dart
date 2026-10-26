import 'package:flutter/services.dart';

class HomeWidget {
  static Future<bool> pin() async =>
      await const MethodChannel('rp_music/system')
          .invokeMethod<bool>('pinWidget') ??
      false;
}
