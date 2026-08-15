import 'package:flutter/services.dart';
import 'package:sz_core/src/model.dart';

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

  @override
  Future<Map<String, String>> getDefaultHeader() async {
    final info = await _methodChannel.invokeMethod<Map>('getDeviceInfo');

    final device = Map<String, String>.from(info ?? {});

    final appName = device["app_name"] ?? "Unknown";
    final appVersion = device["app_version"] ?? "0.0.0";
    final appBuild = device["app_build"] ?? "0";
    final platform = device["platform"] ?? "Unknown";
    final model = device["model"] ?? "Unknown";

    final systemVersion =
        device["system_version"] ??
            device["android_version"] ??
            "Unknown";

    return {
      "User-Agent":
      "$appName/$appVersion ($platform $systemVersion; $model; Build $appBuild)",
    };
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final info = await _methodChannel.invokeMethod<Map>('getDeviceInfo');

    return DeviceInfo.fromMap(info ?? {});
  }

}
