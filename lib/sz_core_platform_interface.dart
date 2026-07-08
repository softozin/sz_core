import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sz_core_method_channel.dart';

abstract class SzCorePlatform extends PlatformInterface {
  /// Constructs a SzCorePlatform.
  SzCorePlatform() : super(token: _token);

  static final Object _token = Object();

  static SzCorePlatform _instance = MethodChannelSzCore();

  /// The default instance of [SzCorePlatform] to use.
  ///
  /// Defaults to [MethodChannelSzCore].
  static SzCorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SzCorePlatform] when
  /// they register themselves.
  static set instance(SzCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> showToast(String message,Color bg,Color color,double size,double duration) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<({double width, double height})> getScreenSize() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
