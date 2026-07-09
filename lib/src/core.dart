import 'dart:async';
import 'dart:math';

import 'package:sz_core/src/api_caller.dart';
import 'package:sz_core/src/show.dart';
import 'package:sz_core/sz_core_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class SZCore {
  static Function()? logoutCallback;
  static double widthScale = 1;
  static double heightScale = 1;
  static double textScale = 1;

  /// Initializes SZ Core and configures global settings.
  ///
  /// This method should be called once during application startup,
  /// typically before running the app.
  ///
  /// The optional [baseURL] parameter can be used to configure the
  /// default API base URL used throughout the application.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   SZCore.init(
  ///     baseURL: 'https://api.example.com',
  ///   );
  ///
  ///   runApp(const MyApp());
  /// }
  /// ```
  static void init({String? baseURL}) async {
    if (baseURL != null) {
      SZApiSetting.init(baseURL);
    }
    var size = await getScreenSize();
    printLog("W : ${size.width}");
    printLog("H : ${size.height}");
    // printLog("T : $textScale");

    const designWidth = 360.0;
    const designHeight = 690.0;

    widthScale = (size.width / designWidth);
    heightScale = (size.height / designHeight);

    // widthScale = (1.0 + ((widthScale.floor() - 1) * 0.05)).clamp(0.85, 1.30);;
    // heightScale = (1.0 + ((heightScale.floor() - 1) * 0.05)).clamp(0.85, 1.30);;

    textScale = min(widthScale, heightScale).clamp(0.85, 1.30);

    printLog("W : $widthScale");
    printLog("H : $heightScale");
    printLog("T : $textScale");
  }

  /// Returns the physical screen size of the device.
  ///
  /// The returned values represent the screen width and height in logical pixels.
  ///
  /// Returns:
  /// - `width` : Device screen width.
  /// - `height` : Device screen height.
  ///
  /// Example:
  /// ```dart
  /// final size = await SZCore.getScreenSize();
  ///
  /// SZCore.printLog('Width: ${size.width}');
  /// SZCore.printLog('Height: ${size.height}');
  /// ```
  static Future<({double width, double height})> getScreenSize() async {
    return SzCorePlatform.instance.getScreenSize();
  }

  /// Generates and returns a random dark color.
  ///
  /// The generated color uses low RGB values (`0-99`) to ensure the
  /// resulting color remains visually dark.
  ///
  /// Example:
  /// ```dart
  /// final color = SZCore.getRandomDarkColor();
  ///
  /// Container(
  ///   color: color,
  /// );
  /// ```
  static Color getRandomDarkColor() {
    final random = Random();
    return Color.fromARGB(
      255, // full opacity
      random.nextInt(100), // Red: 0–99
      random.nextInt(100), // Green: 0–99
      random.nextInt(100), // Blue: 0–99
    );
  }

  /// Formats a [DateTime] into a readable or server-friendly date string.
  ///
  /// By default, the date is formatted for server communication using
  /// the `yyyy-MM-dd` format.
  ///
  /// When [server] is set to `false`, the date is formatted in a
  /// user-friendly format such as `9 Jul 2026`.
  ///
  /// Example:
  /// ```dart
  /// final apiDate = SZCore.formattedDate(DateTime.now());
  /// // 2026-07-09
  ///
  /// final displayDate = SZCore.formattedDate(
  ///   DateTime.now(),
  ///   server: false,
  /// );
  /// // 9 Jul 2026
  /// ```
  static String formattedDate(DateTime selectedDate, {bool server = true}) {
    final intl.DateFormat formatter = intl.DateFormat(
      server ? 'yyyy-MM-dd' : 'd MMM yyyy',
    );
    final String formatted = formatter.format(selectedDate);
    return formatted;
  }

  /// Formats a [DateTime] into a server-friendly or human-readable date and time string.
  ///
  /// By default, the date and time are formatted for server communication using
  /// the `yyyy-MM-dd HH:mm:ss` format.
  ///
  /// When [server] is set to `false`, the date and time are formatted in a
  /// user-friendly format such as `9 Jul 2026 12:30 PM`.
  ///
  /// Example:
  /// ```dart
  /// final apiDateTime = SZCore.formattedDateTime(DateTime.now());
  /// // 2026-07-09 12:30:00
  ///
  /// final displayDateTime = SZCore.formattedDateTime(
  ///   DateTime.now(),
  ///   server: false,
  /// );
  /// // 9 Jul 2026 12:30 PM
  /// ```
  static String formattedDateTime(DateTime selectedDateTime, {bool server = true}) {
    final intl.DateFormat formatter = intl.DateFormat(
      server ? 'yyyy-MM-dd HH:mm:ss' : 'd MMM yyyy h:mm a',
    );
    final String formatted = formatter.format(selectedDateTime);
    return formatted;
  }

  /// Formats a [DateTime] into a server-friendly or human-readable time string.
  ///
  /// By default, the time is formatted for server communication using
  /// the `HH:mm:ss` format.
  ///
  /// When [server] is set to `false`, the time is formatted in a
  /// user-friendly format such as `2:30 PM`.
  ///
  /// Example:
  /// ```dart
  /// final apiTime = SZCore.formattedTime(DateTime.now());
  /// // 14:30:00
  ///
  /// final displayTime = SZCore.formattedTime(
  ///   DateTime.now(),
  ///   server: false,
  /// );
  /// // 2:30 PM
  /// ```
  static String formattedTime(DateTime selectedTime, {bool server = true}) {
    final formatter = intl.DateFormat(server ? 'HH:mm:ss' : 'h:mm a');
    return formatter.format(selectedTime);
  }

  /// Prints debug messages to the console.
  ///
  /// Logs are only printed when the application is running in
  /// debug mode (`kDebugMode == true`). No output is generated
  /// in profile or release builds.
  ///
  /// This method is useful for development-time debugging without
  /// affecting production performance.
  ///
  /// Example:
  /// ```dart
  /// SZCore.printLog('API Request Started');
  /// SZCore.printLog(responseBody);
  /// ```
  static void printLog(dynamic a) {
    if (kDebugMode) {
      print(a.toString());
    }
  }

  /// Opens the device dialer with the provided phone number.
  ///
  /// Displays an error toast if the dialer application cannot be opened.
  ///
  /// Example:
  /// ```dart
  /// await SZCore.openCall('9876543210');
  /// ```
  static Future<void> openCall(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await ul.canLaunchUrl(callUri)) {
      await ul.launchUrl(callUri);
    } else {
      SZShow.toast('Could not launch $number');
    }
  }

  /// Opens a website URL in an external browser application.
  ///
  /// Displays an error toast if the URL cannot be opened.
  ///
  /// Example:
  /// ```dart
  /// await SZCore.openWebsite('https://example.com');
  /// ```
  static Future<void> openWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
    } catch (e) {
      SZShow.toast('Could not launch $url');
    }
  }

  /// Opens a WhatsApp chat with the specified phone number.
  ///
  /// An optional [message] can be provided which will be pre-filled
  /// in the chat input field.
  ///
  /// Displays an error toast if WhatsApp cannot be opened.
  ///
  /// Example:
  /// ```dart
  /// await SZCore.openWhatsApp(
  ///   '919876543210',
  ///   message: 'Hello from SZ Core!',
  /// );
  /// ```
  static Future<void> openWhatsApp(String phone, {String message = ''}) async {
    final Uri uri = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    try {
      await ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
    } catch (e) {
      SZShow.toast('Could not launch Whatsapp');
    }
  }

  /// Hides the currently focused keyboard input.
  ///
  /// Useful when dismissing the keyboard after form submission
  /// or when tapping outside input fields.
  ///
  /// Example:
  /// ```dart
  /// SZCore.hideKeyboard(context);
  /// ```
  static void hideKeyboard(BuildContext context) {
    // FocusScope.of(context).unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Opens a new activity (screen).
  ///
  /// By default, the new activity is pushed onto the navigation stack.
  ///
  /// Use [finish] to close the current activity before opening the new one.
  ///
  /// Use [onlyOne] to clear the entire navigation stack and make the new
  /// activity the only active activity.
  ///
  /// Returns the value passed to `Navigator.pop()` when the opened activity
  /// is closed.
  ///
  /// Example:
  /// ```dart
  /// await SZCore.open(
  ///   context,
  ///   const HomeActivity(),
  /// );
  ///
  /// await SZCore.open(
  ///   context,
  ///   const DashboardActivity(),
  ///   finish: true,
  /// );
  ///
  /// await SZCore.open(
  ///   context,
  ///   const LoginActivity(),
  ///   onlyOne: true,
  /// );
  /// ```
  static Future<T?> open<T extends Widget>(
    BuildContext context,
    T dyClass, {
    bool finish = false,
    bool onlyOne = false,
  }) {
    if (onlyOne) {
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => dyClass),
        (route) => false,
      );
    } else {
      if (finish) {
        Navigator.pop(context);
      }
      return Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => dyClass),
      );
    }
  }

  /// Opens a named activity (route).
  ///
  /// By default, the named route is pushed onto the navigation stack.
  ///
  /// Use [finish] to close the current activity before opening the new one.
  ///
  /// Use [onlyOne] to clear the entire navigation stack and make the new
  /// route the only active activity.
  ///
  /// Returns the value passed to `Navigator.pop()` when the opened route
  /// is closed.
  ///
  /// Example:
  /// ```dart
  /// await SZCore.openName(
  ///   context,
  ///   '/home',
  /// );
  ///
  /// await SZCore.openName(
  ///   context,
  ///   '/dashboard',
  ///   finish: true,
  /// );
  ///
  /// await SZCore.openName(
  ///   context,
  ///   '/login',
  ///   onlyOne: true,
  /// );
  /// ```
  static Future openName<T extends Widget>(
    BuildContext context,
    String dyClass, {
    bool finish = false,
    bool onlyOne = false,
  }) {
    if (onlyOne) {
      return Navigator.pushNamedAndRemoveUntil(
        context,
        dyClass,
        (route) => false,
      );
    } else {
      if (finish) {
        Navigator.pop(context);
      }
      return Navigator.pushNamed(
        context,
        dyClass,
      );
    }
  }
}

/// Extension methods for converting hexadecimal color strings to Flutter [Color] objects.
///
/// Supported formats:
/// - `#RRGGBB`
/// - `RRGGBB`
/// - `#AARRGGBB`
/// - `AARRGGBB`
extension HexColor on String {
  /// Converts the hexadecimal color string into a Flutter [Color].
  ///
  /// If the alpha channel is not provided, `FF` (fully opaque) is added
  /// automatically.
  ///
  /// Example:
  /// ```dart
  /// '#FF0000'.toColor();    // Red
  /// '00FF00'.toColor();     // Green
  /// '#800000FF'.toColor();  // Semi-transparent Blue
  /// ```
  Color toColor() {
    var h = replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }
}

/// Extension methods for responsive sizing based on the current screen scale.
///
/// These helpers automatically scale values according to the screen size
/// configured by `SZCore`.
///
/// Example:
/// ```dart
/// Container(
///   width: 100.w,
///   height: 50.h,
///   borderRadius: BorderRadius.circular(12.r),
///   child: Text(
///     'Hello',
///     style: TextStyle(fontSize: 14.sp),
///   ),
/// )
/// ```
extension SizeExtension on num {
  /// Returns the value scaled according to the screen width.
  ///
  /// Commonly used for widget widths and horizontal spacing.
  double get w => this * SZCore.widthScale;

  /// Returns the value scaled according to the screen height.
  ///
  /// Commonly used for widget heights and vertical spacing.
  double get h => this * SZCore.heightScale;

  /// Returns the value scaled using the average of width and height scales.
  ///
  /// Commonly used for border radius, icon sizes, and square dimensions.
  double get r => this * ((SZCore.widthScale + SZCore.heightScale) / 2);

  /// Returns the value scaled according to the text scale factor.
  ///
  /// Commonly used for font sizes.
  double get sp => this * SZCore.textScale;
}
