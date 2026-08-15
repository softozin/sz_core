/// Represents a simple key-value pair with an optional extra value.
///
/// Commonly used for dropdowns, selections, and lookup lists where an
/// integer identifier is associated with a display name.
///
/// Equality is based on the [id] field.
class Pair {
  /// Unique identifier of the pair.
  int id;

  /// Display name of the pair.
  String name;

  /// Optional additional information associated with the pair.
  Object? extra;

  /// Creates a new [Pair] instance.
  ///
  /// Example:
  /// ```dart
  /// final item = Pair(1, 'Apple');
  /// final user = Pair(101, 'John', extra: 'Admin');
  /// ```
  Pair(this.id, this.name, {this.extra});

  /// Returns the display name of the pair.
  @override
  String toString() {
    return name;
  }

  /// Compares two [Pair] objects by their [id].
  @override
  bool operator ==(Object other) {
    if (other is Pair) {
      return id == other.id;
    }
    return false;
  }

  /// Returns the hash code based on the [id].
  @override
  int get hashCode => id;
}

/// Represents a simple string key-value pair with an optional extra value.
///
/// Commonly used for dropdowns, selections, API responses, and lookup lists
/// where a string identifier is associated with a display name.
///
/// Equality is based on the [id] field.
class SPair {
  /// Unique string identifier of the pair.
  String id;

  /// Display name of the pair.
  String name;

  /// Optional additional information associated with the pair.
  Object? extra;

  /// Creates a new [SPair] instance.
  ///
  /// Example:
  /// ```dart
  /// final country = SPair('IN', 'India');
  /// final user = SPair('1001', 'John', extra: 'Admin');
  /// ```
  SPair(this.id, this.name, {this.extra});

  /// Returns the display name of the pair.
  @override
  String toString() {
    return name;
  }

  /// Compares two [SPair] objects by their [id].
  @override
  bool operator ==(Object other) {
    if (other is SPair) {
      return id == other.id;
    }
    return false;
  }

  /// Returns the hash code based on the [id].
  @override
  int get hashCode => id.hashCode;
}


/// Contains application, operating system, and device information.
class DeviceInfo {
  /// Platform name, e.g. Android or iOS.
  final String platform;

  /// Application display name.
  final String appName;

  /// Application version, e.g. 1.2.0.
  final String appVersion;

  /// Application build number.
  final String appBuild;

  /// Device model, e.g. SM-S928B or iPhone.
  final String model;

  /// Device manufacturer, e.g. Samsung or Apple.
  final String manufacturer;

  /// Device brand, e.g. Samsung.
  final String brand;

  /// Android device code name.
  final String device;

  /// Android product name.
  final String product;

  /// Operating system name, e.g. Android or iOS.
  final String osName;

  /// Operating system version, e.g. Android 15 or iOS 18.6.
  final String osVersion;

  /// Android SDK/API level.
  ///
  /// This will generally be empty on iOS.
  final String sdk;

  /// Supported CPU architectures.
  ///
  /// Example: arm64-v8a, armeabi-v7a.
  final String abis;

  /// User-visible device name.
  ///
  /// For example, the name configured on an iPhone.
  final String deviceName;

  /// Platform-provided application/device identifier.
  ///
  /// This may be empty depending on the platform and implementation.
  final String identifier;

  const DeviceInfo({
    this.platform = "",
    this.appName = "",
    this.appVersion = "",
    this.appBuild = "",
    this.model = "",
    this.manufacturer = "",
    this.brand = "",
    this.device = "",
    this.product = "",
    this.osName = "",
    this.osVersion = "",
    this.sdk = "",
    this.abis = "",
    this.deviceName = "",
    this.identifier = "",
  });

  /// Creates a DeviceInfo object from the Map returned
  /// by the native Android/iOS MethodChannel.
  factory DeviceInfo.fromMap(Map<dynamic, dynamic> map) {
    return DeviceInfo(
      platform: map["platform"]?.toString() ?? "",
      appName: map["app_name"]?.toString() ?? "",
      appVersion: map["app_version"]?.toString() ?? "",
      appBuild: map["app_build"]?.toString() ?? "",

      model: map["model"]?.toString() ?? "",
      manufacturer: map["manufacturer"]?.toString() ?? "",
      brand: map["brand"]?.toString() ?? "",
      device: map["device"]?.toString() ?? "",
      product: map["product"]?.toString() ?? "",

      osName: map["system_name"]?.toString() ??
          map["os_name"]?.toString() ??
          "",

      osVersion: map["system_version"]?.toString() ??
          map["android_version"]?.toString() ??
          map["os_version"]?.toString() ??
          "",

      sdk: map["sdk"]?.toString() ?? "",
      abis: map["abis"]?.toString() ?? "",

      deviceName: map["name"]?.toString() ?? "",
      identifier: map["identifier"]?.toString() ?? "",
    );
  }

  /// Converts the DeviceInfo object into a String Map.
  Map<String, String> toMap() {
    return {
      "platform": platform,
      "app_name": appName,
      "app_version": appVersion,
      "app_build": appBuild,
      "model": model,
      "manufacturer": manufacturer,
      "brand": brand,
      "device": device,
      "product": product,
      "os_name": osName,
      "os_version": osVersion,
      "sdk": sdk,
      "abis": abis,
      "device_name": deviceName,
      "identifier": identifier,
    };
  }

  /// Creates a copy of this object with the specified fields replaced.
  DeviceInfo copyWith({
    String? platform,
    String? appName,
    String? appVersion,
    String? appBuild,
    String? model,
    String? manufacturer,
    String? brand,
    String? device,
    String? product,
    String? osName,
    String? osVersion,
    String? sdk,
    String? abis,
    String? deviceName,
    String? identifier,
  }) {
    return DeviceInfo(
      platform: platform ?? this.platform,
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      appBuild: appBuild ?? this.appBuild,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      brand: brand ?? this.brand,
      device: device ?? this.device,
      product: product ?? this.product,
      osName: osName ?? this.osName,
      osVersion: osVersion ?? this.osVersion,
      sdk: sdk ?? this.sdk,
      abis: abis ?? this.abis,
      deviceName: deviceName ?? this.deviceName,
      identifier: identifier ?? this.identifier,
    );
  }

  @override
  String toString() {
    return 'DeviceInfo('
        'platform: $platform, '
        'appName: $appName, '
        'appVersion: $appVersion, '
        'appBuild: $appBuild, '
        'model: $model, '
        'manufacturer: $manufacturer, '
        'brand: $brand, '
        'device: $device, '
        'product: $product, '
        'osName: $osName, '
        'osVersion: $osVersion, '
        'sdk: $sdk, '
        'abis: $abis, '
        'deviceName: $deviceName, '
        'identifier: $identifier'
        ')';
  }
}
