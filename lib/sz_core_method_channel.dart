import 'package:flutter/services.dart';

import 'sz_core_platform_interface.dart';

/// An implementation of [SzCorePlatform] that uses method channels.
class MethodChannelSzCore extends SzCorePlatform {
  /// The method channel used to interact with the native platform.
  final _methodChannel = const MethodChannel('sz_core');

  @override
  Future<String?> showToast(String message,Color bg,Color color,double size,double duration) async {
    final version = await _methodChannel.invokeMethod(
      'showToast',{
      "message": message,
      "backgroundColor": bg.toARGB32(),
      "textColor": color.toARGB32(),
      "fontSize": size,
      "duration": duration,
    }
    );
    return version;
  }

  @override
  Future<({double width, double height})> getScreenSize() async {
    final Map data = await _methodChannel.invokeMethod('getScreenSize');

    return (
    width: (data['width'] as num).toDouble(),
    height: (data['height'] as num).toDouble(),
    );
  }

}
