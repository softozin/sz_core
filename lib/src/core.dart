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

  static Future<({double width, double height})> getScreenSize() async {
    return SzCorePlatform.instance.getScreenSize();
  }

  static Color getRandomDarkColor() {
    final random = Random();
    return Color.fromARGB(
      255, // full opacity
      random.nextInt(100), // Red: 0–99
      random.nextInt(100), // Green: 0–99
      random.nextInt(100), // Blue: 0–99
    );
  }

  static String formattedDate(DateTime selectedDate, {bool server = true}) {
    final intl.DateFormat formatter = intl.DateFormat(
      server ? 'yyyy-MM-dd' : 'd MMM yyyy',
    );
    final String formatted = formatter.format(selectedDate);
    return formatted;
  }

  static String formattedTime(DateTime selectedTime, {bool server = true}) {
    final formatter = intl.DateFormat(server ? 'HH:mm' : 'h:mm a');
    return formatter.format(selectedTime);
  }

  static void printLog(dynamic a) {
    if (kDebugMode) {
      print(a);
    }
  }

  static Future<void> openCall(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await ul.canLaunchUrl(callUri)) {
      await ul.launchUrl(callUri);
    } else {
      SZShow.toast('Could not launch $number');
    }
  }

  static Future<void> openWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
    } catch (e) {
      SZShow.toast('Could not launch $url');
    }
  }

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

  static void hideKeyboard(BuildContext context) {
    // FocusScope.of(context).unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Future<T?> open<T extends Widget>(BuildContext context, T dyClass) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => dyClass),
    );
  }
}

extension HexColor on String {
  Color toColor() {
    var h = replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }
}

extension SizeExtension on num {
  double get w => this * SZCore.widthScale;

  double get h => this * SZCore.heightScale;

  double get r => this * ((SZCore.widthScale + SZCore.heightScale) / 2);

  double get sp => this * SZCore.textScale;
}
